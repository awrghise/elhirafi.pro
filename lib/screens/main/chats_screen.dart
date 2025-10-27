import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppStrings.now;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${AppStrings.minutesAgo}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${AppStrings.hoursAgo}';
    } else {
      return '${difference.inDays} ${AppStrings.daysAgo}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthProvider>(context);
    final UserModel? user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chats),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: Provider.of<ChatProvider>(context).getUserChats(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppColors.textSecondaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppStrings.noChatsFound,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ابدأ محادثة جديدة من خلال الرد على طلب عمل',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textHintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          final chats = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate and refetch
            },
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatTile(context, chat, user.id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatModel chat, String currentUserId) {
    final otherUserId = chat.participants.firstWhere((id) => id != currentUserId, orElse: () => '');
    final otherUserName = chat.participantNames[otherUserId] ?? 'مستخدم';
    final isLastMessageFromMe = chat.lastMessageSenderId == currentUserId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryColor,
        child: Text(
          otherUserName.isNotEmpty ? otherUserName.substring(0, 1).toUpperCase() : 'U',
          style: const TextStyle(
            color: AppColors.textOnPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        otherUserName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryColor,
        ),
      ),
      subtitle: Row(
        children: [
          if (isLastMessageFromMe) ...[
            const Icon(
              Icons.done,
              size: 16,
              color: AppColors.textSecondaryColor,
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              chat.lastMessageContent.isEmpty 
                  ? 'لا توجد رسائل' 
                  : chat.lastMessageContent,
              style: const TextStyle(
                color: AppColors.textSecondaryColor,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimeAgo(chat.lastMessageTime),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          // TODO: Add unread message count indicator
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatId: chat.id,
              otherUserName: otherUserName,
              otherUserId: otherUserId,
            ),
          ),
        );
      },
    );
  }
}
