import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- بداية التعديل: إضافة دالة لجلب بيانات محادثة واحدة ---
  Stream<ChatModel> getChatDetails(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((doc) => ChatModel.fromFirestore(doc));
  }
  // --- نهاية التعديل ---

  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    required MessageType type,
  }) async {
    try {
      final message = MessageModel(
        id: _firestore.collection('chats').doc(chatId).collection('messages').doc().id,
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: type,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toFirestore());

      // --- بداية التعديل: زيادة عدد الرسائل وتحديث المحادثة ---
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessageContent': content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'lastMessageSenderId': senderId,
        'messageCount': FieldValue.increment(1), // <-- زيادة العداد بواحد
      });
      // --- نهاية التعديل ---
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<String> getOrCreateChat({
    required String user1Id,
    required String user1Name,
    required String user2Id,
    required String user2Name,
  }) async {
    String chatId = user1Id.compareTo(user2Id) < 0
        ? '${user1Id}_${user2Id}'
        : '${user2Id}_${user1Id}';

    final chatDoc = _firestore.collection('chats').doc(chatId);
    final docSnapshot = await chatDoc.get();

    if (!docSnapshot.exists) {
      final newChat = ChatModel(
        id: chatId,
        participants: [user1Id, user2Id],
        participantNames: {user1Id: user1Name, user2Id: user2Name},
        lastMessageContent: 'تم بدء المحادثة', // رسالة أولية
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
        messageCount: 0, // تبدأ المحادثة بصفر رسائل
      );
      await chatDoc.set(newChat.toFirestore());
    }
    return chatId;
  }
}
