const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Firestore trigger: When a new user is created, add them to a 'users' collection
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  const userData = {
    email: user.email,
    displayName: user.displayName || "",
    photoURL: user.photoURL || "",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    userType: "client", // Default user type
    isAvailable: true,
  };
  await admin.firestore().collection("users").doc(user.uid).set(userData);
  console.log(`User ${user.uid} created and added to Firestore.`);
  return null;
});

// Firestore trigger: When a new request is added, send a notification to relevant craftsmen
exports.onRequestCreate = functions.firestore
  .document("requests/{requestId}")
  .onCreate(async (snap, context) => {
    const request = snap.data();
    const requestId = context.params.requestId;

    // Example: Find craftsmen matching the profession and city
    const craftsmenSnapshot = await admin
      .firestore()
      .collection("users")
      .where("userType", "==", "craftsman")
      .where("profession", "==", request.professionConceptKey)
      .where("workCities", "array-contains", request.city) // Assuming workCities is an array
      .get();

    const tokens = [];
    craftsmenSnapshot.forEach((doc) => {
      const craftsman = doc.data();
      if (craftsman.fcmToken) {
        tokens.push(craftsman.fcmToken);
      }
    });

    if (tokens.length > 0) {
      const payload = {
        notification: {
          title: "طلب جديد!",
          body: `يوجد طلب جديد لـ ${request.professionDialectName} في ${request.city}.`, // Use dialect name
        },
        data: {
          type: "new_request",
          requestId: requestId,
          profession: request.professionConceptKey,
        },
      };
      await admin.messaging().sendToDevice(tokens, payload);
      console.log(`Notification sent for request ${requestId} to ${tokens.length} craftsmen.`);
    } else {
      console.log(`No craftsmen found or no FCM tokens for request ${requestId}.`);
    }

    return null;
  });

// HTTP callable function: Example of a simple API endpoint
exports.helloWorld = functions.https.onCall((data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }
  const name = data.name || "World";
  return { message: `Hello, ${name} from Cloud Functions!` };
});

// Firestore trigger: When a message is sent in chat, update lastMessage and timestamp in chat document
exports.onMessageCreate = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const chatId = context.params.chatId;

    await admin.firestore().collection("chats").doc(chatId).update({
      lastMessage: message.content,
      lastMessageTimestamp: message.timestamp,
      lastMessageSenderId: message.senderId,
    });
    console.log(`Chat ${chatId} updated with last message.`);
    return null;
  });

// Firestore trigger: Clean up user data when user is deleted
exports.onUserDelete = functions.auth.user().onDelete(async (user) => {
  // Delete user's Firestore document
  await admin.firestore().collection("users").doc(user.uid).delete();

  // Optionally, delete user's storage data (e.g., profile pictures, audio recordings)
  const bucket = admin.storage().bucket();
  await bucket.deleteFiles({
    prefix: `profiles/${user.uid}/`,
  });
  await bucket.deleteFiles({
    prefix: `requests/${user.uid}/`,
  });

  console.log(`User ${user.uid} data deleted.`);
  return null;
});


