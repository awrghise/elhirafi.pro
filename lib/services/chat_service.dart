import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على محادثات المستخدم
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

  // الحصول على رسائل محادثة معينة (استماع عند الطلب)
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

  // إرسال رسالة جديدة
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

      // إضافة الرسالة إلى مجموعة الرسائل الفرعية
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toFirestore());

      // تحديث بيانات المحادثة الرئيسية (آخر رسالة ووقتها)
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

  // بدء محادثة جديدة أو الحصول على محادثة موجودة
  Future<String> getOrCreateChat({
    required String user1Id,
    required String user1Name,
    required String user2Id,
    required String user2Name,
  }) async {
    // بناء معرف المحادثة بترتيب أبجدي لضمان التوحيد
    String chatId = user1Id.compareTo(user2Id) < 0
        ? '${user1Id}_${user2Id}'
        : '${user2Id}_${user1Id}';

    final chatDoc = _firestore.collection('chats').doc(chatId);
    final docSnapshot = await chatDoc.get();

    if (!docSnapshot.exists) {
      // إنشاء محادثة جديدة إذا لم تكن موجودة
      final newChat = ChatModel(
        id: chatId,
        participants: [user1Id, user2Id],
        participantNames: {user1Id: user1Name, user2Id: user2Name},
        lastMessageContent: '',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
      );
      await chatDoc.set(newChat.toFirestore());
    }
    return chatId;
  }
}


