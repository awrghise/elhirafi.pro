// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- بداية التعديل: دالة جديدة لجلب المحادثات مع ترقيم الصفحات ---
  Future<Map<String, dynamic>> getUserChatsPaginated({
    required String userId,
    required int limit,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true) // سنعتمد الترتيب التنازلي (الأحدث أولاً)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    final chats = snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
    
    // إرجاع آخر مستند إذا كانت القائمة غير فارغة
    final newLastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return {
      'chats': chats,
      'lastDocument': newLastDocument,
    };
  }
  // --- نهاية التعديل ---

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

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessageContent': content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'lastMessageSenderId': senderId,
      });
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
        lastMessageContent: 'تم إنشاء المحادثة',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
      );
      await chatDoc.set(newChat.toFirestore());
    }
    return chatId;
  }
}
