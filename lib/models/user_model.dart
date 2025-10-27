import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { client, craftsman, supplier }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String userType;
  final String profileImageUrl;
  final String? professionId;
  final String? professionName;
  final List<String> workCities;
  final bool? isAvailable;
  final double rating;
  final int reviewCount;
  final Timestamp createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    this.profileImageUrl = '',
    this.professionId,
    this.professionName,
    this.workCities = const [],
    this.isAvailable,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      userType: data['userType'] ?? 'client',
      profileImageUrl: data['profileImageUrl'] ?? '',
      professionId: data['professionId'],
      professionName: data['professionName'],
      workCities: List<String>.from(data['workCities'] ?? []),
      isAvailable: data['isAvailable'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Getters for compatibility
  String get uid => id;
  String get displayName => name;
  String get profession => professionName ?? '';
  List<String> get cities => workCities;
  int? get yearsOfExperience => null; // TODO: Add this field to Firestore

  // Method to convert a UserModel instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'profileImageUrl': profileImageUrl,
      'professionId': professionId,
      'professionName': professionName,
      'workCities': workCities,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
    };
  }
}
