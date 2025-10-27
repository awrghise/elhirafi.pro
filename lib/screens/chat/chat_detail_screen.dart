import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserId;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
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
        setState(() {
          _currentlyPlayingAudioUrl = null;
        });
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
        setState(() {
          _currentlyPlayingAudioUrl = audioUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تشغيل الصوت: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
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
        foregroundColor: AppColors.textOnPrimaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: Provider.of<ChatProvider>(context).getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
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
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
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
            bottomLeft: isMe ? const Radius.circular(16.0) : const Radius.circular(4.0),
            bottomRight: isMe ? const Radius.circular(4.0) : const Radius.circular(16.0),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.text)
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? AppColors.textOnPrimaryColor : AppColors.textPrimaryColor,
                ),
              ),
            if (message.type == MessageType.audio)
              GestureDetector(
                onTap: () => _playAudio(message.content),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _currentlyPlayingAudioUrl == message.content ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: isMe ? AppColors.textOnPrimaryColor : AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'رسالة صوتية',
                      style: TextStyle(
                        color: isMe ? AppColors.textOnPrimaryColor : AppColors.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isMe ? AppColors.textOnPrimaryColor.withOpacity(0.7) : AppColors.textSecondaryColor.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Microphone button
          CircleAvatar(
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.mic, color: AppColors.primaryColor, size: 20),
              onPressed: () {
                // TODO: Implement voice recording
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('التسجيل الصوتي قريباً')),
                );
              },
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: AppStrings.typeMessage,
                filled: true,
                fillColor: AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.textOnPrimaryColor, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
