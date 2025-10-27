// lib/providers/chat_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  // --- بداية الإضافة: متغيرات حالة ترقيم الصفحات ---
  List<ChatModel> _chats = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  
  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  // --- نهاية الإضافة ---

  bool _isSending = false;
  String? _error;
  String? _successMessage;
  
  bool get isSending => _isSending;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  // --- بداية التعديل: دوال جلب المحادثات ---
  Future<void> fetchInitialChats(String userId) async {
    if (_isLoading) return;

    _isLoading = true;
    _hasMore = true;
    _lastDocument = null;
    _chats.clear();
    notifyListeners();

    try {
      final result = await _chatService.getUserChatsPaginated(
        userId: userId,
        limit: 20,
      );

      _chats = result['chats'];
      _lastDocument = result['lastDocument'];
      _hasMore = _chats.length == 20;

    } catch (e) {
      _error = 'فشل في جلب المحادثات: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreChats(String userId) async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _chatService.getUserChatsPaginated(
        userId: userId,
        limit: 20,
        lastDocument: _lastDocument,
      );

      final newChats = result['chats'];
      _chats.addAll(newChats);
      _lastDocument = result['lastDocument'];
      _hasMore = newChats.length == 20;

    } catch (e) {
      _error = 'فشل في جلب المزيد من المحادثات: ${e.toString()}';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  // --- نهاية التعديل ---

  Future<String> getOrCreateChat({
    required String user1Id,
    required String user1Name,
    required String user2Id,
    required String user2Name,
  }) async {
    try {
      return await _chatService.getOrCreateChat(
        user1Id: user1Id,
        user1Name: user1Name,
        user2Id: user2Id,
        user2Name: user2Name,
      );
    } catch (e) {
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
    } catch (e) {
      _error = 'فشل في إرسال الرسالة: ${e.toString()}';
    } finally {
      _isSending = false;
      notifyListeners();
    }
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
