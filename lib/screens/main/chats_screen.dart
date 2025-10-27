// lib/screens/main/chats_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialChats();
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialChats() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      await Provider.of<ChatProvider>(context, listen: false).fetchInitialChats(user.id);
    }
  }

  void _onScroll() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !chatProvider.isLoadingMore &&
        chatProvider.hasMore) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        chatProvider.fetchMoreChats(user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('الرجاء تسجيل الدخول لعرض المحادثات')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chats),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading && chatProvider.chats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chatProvider.chats.isEmpty) {
            return Center(
              child: RefreshIndicator(
                onRefresh: _loadInitialChats,
                child: ListView(
                  children: const [
                    SizedBox(height: 150),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('لا توجد محادثات بعد', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final chats = chatProvider.chats;

          return RefreshIndicator(
            onRefresh: _loadInitialChats,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chats.length + (chatProvider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chats.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final chat = chats[index];
                final otherUserId = chat.participants.firstWhere((id) => id != currentUser.id, orElse: () => '');
                final otherUserName = chat.participantNames[otherUserId] ?? 'مستخدم غير معروف';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryColor,
                      child: Text(
                        otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      chat.lastMessageContent,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatTime(chat.lastMessageTime),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatId: chat.id,
                            otherUserId: otherUserId,
                            otherUserName: otherUserName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 0) return '${difference.inDays} يوم';
    if (difference.inHours > 0) return '${difference.inHours} ساعة';
    if (difference.inMinutes > 0) return '${difference.inMinutes} دقيقة';
    return 'الآن';
  }
}
