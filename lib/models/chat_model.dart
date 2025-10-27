// lib/models/chat_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final Map<String, dynamic> participantNames;
  final Map<String, dynamic> participantPhones; // <-- الحقل الجديد
  final DateTime lastMessageTime;
  final String lastMessageContent;
  final String lastMessageSenderId;
  final int messageCount;

  ChatModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantPhones, // <-- مطلوب الآن في المُنشئ
    required this.lastMessageTime,
    required this.lastMessageContent,
    required this.lastMessageSenderId,
    this.messageCount = 0,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: Map<String, dynamic>.from(data['participantNames'] ?? {}),
      participantPhones: Map<String, dynamic>.from(data['participantPhones'] ?? {}), // <-- قراءة الحقل الجديد
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastMessageContent: data['lastMessageContent'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      messageCount: data['messageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'participantPhones': participantPhones, // <-- إضافة الحقل الجديد عند الكتابة
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageContent': lastMessageContent,
      'lastMessageSenderId': lastMessageSenderId,
      'messageCount': messageCount,
    };
  }
}
