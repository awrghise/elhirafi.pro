// ... (باقي الكود كما هو)

  Future<String> getOrCreateChat({
    required String user1Id,
    required String user1Name,
    required String user1Phone, // <-- إضافة
    required String user2Id,
    required String user2Name,
    required String user2Phone, // <-- إضافة
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
        participantPhones: {user1Id: user1Phone, user2Id: user2Phone}, // <-- إضافة
        lastMessageContent: 'تم بدء المحادثة',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
        messageCount: 0,
      );
      await chatDoc.set(newChat.toFirestore());
    }
    return chatId;
  }
// ... (باقي الكود كما هو)
