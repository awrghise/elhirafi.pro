// lib/screens/main/chats_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/chat_model.dart';
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
    // --- بداية التعديل ---
    // تأكد من أن المستخدم قد تم تحميله قبل استدعاء أي شيء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        // ربط الـ Provider بالمستخدم الحالي لبدء تحميل المحادثات
        chatProvider.setCurrentUserId(authProvider.user!.id);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
        // ملاحظة: دالة loadMoreChats معقدة مع الـ streams، لذا قد لا تعمل كما هو متوقع الآن.
        // سنتركها للمستقبل إذا احتجنا لتحسين الترقيم.
        // Provider.of<ChatProvider>(context, listen: false).loadMoreChats();
      }
    });
    // --- نهاية التعديل ---
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد محادثات بعد', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: chatProvider.chats.length + (chatProvider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == chatProvider.chats.length) {
                return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
              }

              final chat = chatProvider.chats[index];
              final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
              final otherUserId = chat.participants.firstWhere((id) => id != currentUser?.id, orElse: () => '');
              final otherUserName = chat.participantNames[otherUserId] ?? 'مستخدم غير معروف';
              final otherUserPhone = chat.participantPhones[otherUserId] ?? '';

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
                    if (otherUserPhone.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatId: chat.id,
                            otherUserId: otherUserId,
                            otherUserName: otherUserName,
                            otherUserPhone: otherUserPhone,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('خطأ: رقم هاتف المستخدم الآخر غير متوفر.'))
                      );
                    }
                  },
                ),
              );
            },
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
