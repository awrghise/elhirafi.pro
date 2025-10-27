// lib/providers/chat_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<ChatModel> _chats = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  StreamSubscription? _chatsSubscription;
  final int _pageSize = 20;

  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  String? _currentUserId;

  void setCurrentUserId(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      loadInitialChats();
    }
  }

  void loadInitialChats() {
    if (_currentUserId == null || _isLoading) return;

    _isLoading = true;
    _hasMore = true;
    _lastDocument = null;
    _chats = [];
    notifyListeners();

    _chatsSubscription?.cancel();
    _chatsSubscription = _chatService
        .getUserChatsPaginated(userId: _currentUserId!, limit: _pageSize)
        .listen((newChats) {
      _chats = newChats;
      if (newChats.isNotEmpty) {
        // This is tricky with streams, so we might need to fetch the last doc separately if pagination fails
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("Error loading initial chats: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  // Note: True stream-based pagination is complex.
  // This is a simplified version. A more robust solution might use Future-based fetching instead.
  void loadMoreChats() {
    // This functionality is complex to implement with streams and might be omitted for now
    // or replaced with a Future-based approach if needed.
    // For now, we'll keep it simple.
  }

  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _chatService.getChatMessages(chatId);
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    required MessageType type,
  }) async {
    await _chatService.sendMessage(
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
    );
    // No need to notify listeners as the stream will update the UI
  }

  Future<String> getOrCreateChat({
    required String user1Id,
    required String user1Name,
    required String user1Phone, // Added
    required String user2Id,
    required String user2Name,
    required String user2Phone, // Added
  }) async {
    return await _chatService.getOrCreateChat(
      user1Id: user1Id,
      user1Name: user1Name,
      user1Phone: user1Phone, // Pass it down
      user2Id: user2Id,
      user2Name: user2Name,
      user2Phone: user2Phone, // Pass it down
    );
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    super.dispose();
  }
}
