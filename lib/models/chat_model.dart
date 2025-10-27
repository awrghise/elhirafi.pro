import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants; // UIDs of participants
  final Map<String, dynamic> participantNames; // Map of UID to name
  final DateTime lastMessageTime;
  final String lastMessageContent;
  final String lastMessageSenderId;

  ChatModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessageTime,
    required this.lastMessageContent,
    required this.lastMessageSenderId,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: Map<String, dynamic>.from(data['participantNames'] ?? {}),
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastMessageContent: data['lastMessageContent'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageContent': lastMessageContent,
      'lastMessageSenderId': lastMessageSenderId,
    };
  }
}


