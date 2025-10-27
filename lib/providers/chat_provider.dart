import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  String? _successMessage;
  
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  Future<String> getOrCreateChat({
    required String user1Id,
    required String user1Name,
    required String user2Id,
    required String user2Name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final chatId = await _chatService.getOrCreateChat(
        user1Id: user1Id,
        user1Name: user1Name,
        user2Id: user2Id,
        user2Name: user2Name,
      );

      _isLoading = false;
      notifyListeners();
      return chatId;
    } catch (e) {
      _isLoading = false;
      _error = 'فشل في إنشاء المحادثة: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    required MessageType type,
  }) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      await _chatService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: type,
      );

      _isSending = false;
    } catch (e) {
      _isSending = false;
      _error = 'فشل في إرسال الرسالة: ${e.toString()}';
    }
    notifyListeners();
  }

  Stream<List<ChatModel>> getUserChats(String userId) {
    return _chatService.getUserChats(userId);
  }

  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _chatService.getChatMessages(chatId);
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}

