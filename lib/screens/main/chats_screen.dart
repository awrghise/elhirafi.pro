import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_room_model.dart';
import 'settings_screen.dart';
import 'chat_detail_screen.dart';

// --- بداية التعديل 1: استيراد ويدجت إعلان البانر ---
import '../../widgets/banner_ad_widget.dart';
// --- نهاية التعديل 1 ---

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chatsLabel),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share('تواصل بسهولة مع الحرفيين والعملاء عبر تطبيق الصانع الحرفي! [رابط التطبيق]');
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      // --- بداية التعديل 2: تغيير هيكل body لإضافة البانر ---
      body: Column(
        children: [
          Expanded(
            child: userId == null
                ? const Center(child: Text('الرجاء تسجيل الدخول لعرض المحادثات.'))
                : StreamBuilder<List<ChatRoom>>(
                    stream: chatProvider.getChatRooms(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('لا توجد محادثات حتى الآن.'));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                      }

                      final chatRooms = snapshot.data!;

                      return ListView.builder(
                        itemCount: chatRooms.length,
                        itemBuilder: (context, index) {
                          final chatRoom = chatRooms[index];
                          final otherParticipant = chatRoom.participants.firstWhere((p) => p['id'] != userId);

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: otherParticipant['profileImageUrl'] != null && otherParticipant['profileImageUrl'].isNotEmpty
                                    ? NetworkImage(otherParticipant['profileImageUrl'])
                                    : const AssetImage('assets/images/placeholder_icon.png') as ImageProvider,
                              ),
                              title: Text(otherParticipant['name'] ?? 'مستخدم'),
                              subtitle: Text(
                                chatRoom.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                // Format timestamp if needed
                                chatRoom.lastMessageTimestamp?.toDate().toString() ?? '',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailScreen(
                                      chatRoomId: chatRoom.id,
                                      otherUserId: otherParticipant['id'],
                                      otherUserName: otherParticipant['name'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          // العنصر الثاني: إعلان البانر الخاص بهذه الشاشة
          const BannerAdWidget(screenName: 'ChatsScreen'),
        ],
      ),
      // --- نهاية التعديل 2 ---
    );
  }
}
