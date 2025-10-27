import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- استيراد مهم
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../models/chat_model.dart'; // <-- استيراد مهم
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/chat_service.dart'; // <-- استيراد مهم

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserId;
  final String otherUserPhone; // <-- إضافة رقم هاتف الطرف الآخر

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
    required this.otherUserPhone, // <-- إضافة رقم هاتف الطرف الآخر
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ChatService _chatService = ChatService(); // <-- إنشاء نسخة من الخدمة
  String? _currentlyPlayingAudioUrl;

  @override
  void dispose() {
    _messageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final UserModel? currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    if (currentUser == null || _messageController.text.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    await chatProvider.sendMessage(
      chatId: widget.chatId,
      senderId: currentUser.id,
      receiverId: widget.otherUserId,
      content: _messageController.text.trim(),
      type: MessageType.text,
    );
    _messageController.clear();
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      if (_currentlyPlayingAudioUrl == audioUrl) {
        await _audioPlayer.stop();
        setState(() => _currentlyPlayingAudioUrl = null);
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
        setState(() => _currentlyPlayingAudioUrl = audioUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تشغيل الصوت: $e')));
      }
    }
  }

  // --- دالة جديدة لفتح واتساب ---
  void _openWhatsApp() async {
    String phone = widget.otherUserPhone.replaceAll('+', ''); // إزالة علامة +
    final url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent("مرحباً، تواصلت معك من تطبيق الصانع الحرفي.")}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح واتساب')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? currentUser = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: AppColors.primaryColor,
      ),
      // --- بداية التعديل الرئيسي: استخدام StreamBuilder لعرض المحتوى ---
      body: StreamBuilder<ChatModel>(
        stream: _chatService.getChatDetails(widget.chatId),
        builder: (context, chatSnapshot) {
          if (!chatSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatData = chatSnapshot.data!;
          final messageLimit = 3;

          // إذا تم تجاوز حد الرسائل، اعرض واجهة واتساب
          if (chatData.messageCount >= messageLimit) {
            return _buildWhatsAppRedirect();
          }

          // إذا لم يتم تجاوز الحد، اعرض واجهة المحادثة العادية
          return Column(
            children: [
              Expanded(
                child: StreamBuilder<List<MessageModel>>(
                  stream: Provider.of<ChatProvider>(context).getChatMessages(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text(AppStrings.noMessages));
                    }
                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUser?.id;
                        return _buildMessageBubble(message, isMe);
                      },
                    );
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          );
        },
      ),
      // --- نهاية التعديل الرئيسي ---
    );
  }

  // --- واجهة جديدة لعرض زر واتساب ---
  Widget _buildWhatsAppRedirect() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.whatsapp, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'لقد وصلتم إلى الحد الأقصى للرسائل',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'لإكمال المحادثة وتوفير تكاليف التطبيق، يرجى المتابعة عبر واتساب.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openWhatsApp,
              icon: const Icon(Icons.open_in_new),
              label: Text('متابعة المحادثة في واتساب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    // ... (هذه الدالة تبقى كما هي بدون تغيير)
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryLightColor : AppColors.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: isMe ? const Radius.circular(16.0) : Radius.circular(4.0),
            bottomRight: isMe ? Radius.circular(4.0) : const Radius.circular(16.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.text)
              Text(
                message.content,
                style: TextStyle(color: isMe ? Colors.white : Colors.black),
              ),
            if (message.type == MessageType.audio)
              GestureDetector(
                onTap: () => _playAudio(message.content),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _currentlyPlayingAudioUrl == message.content ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: isMe ? Colors.white : AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'رسالة صوتية',
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    // ... (هذه الدالة تبقى كما هي بدون تغيير)
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration.collapsed(hintText: AppStrings.typeMessage),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
