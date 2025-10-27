import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String? id;
  final String clientId;
  final String clientName;
  final String profession; // <-- الاسم الصحيح
  final String city;
  final String? details; // <-- الاسم الصحيح
  final String? audioUrl;
  final String status;
  final DateTime createdAt; // <-- النوع الصحيح
  final String? craftsmanId;
  final String? craftsmanName;
  final String? craftsmanPhone;

  RequestModel({
    this.id,
    required this.clientId,
    required this.clientName,
    required this.profession,
    required this.city,
    this.details,
    this.audioUrl,
    this.status = 'pending',
    required this.createdAt,
    this.craftsmanId,
    this.craftsmanName,
    this.craftsmanPhone,
  });

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      clientId: data['clientId'],
      clientName: data['clientName'],
      profession: data['profession'],
      city: data['city'],
      details: data['details'],
      audioUrl: data['audioUrl'],
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      craftsmanId: data['craftsmanId'],
      craftsmanName: data['craftsmanName'],
      craftsmanPhone: data['craftsmanPhone'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'profession': profession,
      'city': city,
      'details': details,
      'audioUrl': audioUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
