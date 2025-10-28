// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String userType;
  final String profileImageUrl;
  final String profession;
  final int experience;
  final String primaryWorkCity;
  final String country;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  // --- بداية الإضافة: إضافة حقل مدن التنبيهات ---
  final List<String> subscribedCities;
  // --- نهاية الإضافة ---

  UserModel({
    required this.id,
    required this.email,
    this.name = '',
    this.phoneNumber = '',
    this.userType = 'client',
    this.profileImageUrl = '',
    this.profession = '',
    this.experience = 0,
    this.primaryWorkCity = '',
    this.country = '',
    this.isAvailable = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    // --- بداية الإضافة ---
    this.subscribedCities = const [],
    // --- نهاية الإضافة ---
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      userType: data['userType'] ?? 'client',
      profileImageUrl: data['profileImageUrl'] ?? '',
      profession: data['profession'] ?? '',
      experience: data['experience'] ?? 0,
      primaryWorkCity: data['primaryWorkCity'] ?? '',
      country: data['country'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // --- بداية الإضافة: قراءة الحقل من Firestore ---
      subscribedCities: List<String>.from(data['subscribedCities'] ?? []),
      // --- نهاية الإضافة ---
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'profileImageUrl': profileImageUrl,
      'profession': profession,
      'experience': experience,
      'primaryWorkCity': primaryWorkCity,
      'country': country,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      // --- بداية الإضافة: كتابة الحقل في Firestore ---
      'subscribedCities': subscribedCities,
      // --- نهاية الإضافة ---
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? userType,
    String? profileImageUrl,
    String? profession,
    int? experience,
    String? primaryWorkCity,
    String? country,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    // --- بداية الإضافة ---
    List<String>? subscribedCities,
    // --- نهاية الإضافة ---
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profession: profession ?? this.profession,
      experience: experience ?? this.experience,
      primaryWorkCity: primaryWorkCity ?? this.primaryWorkCity,
      country: country ?? this.country,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      // --- بداية الإضافة ---
      subscribedCities: subscribedCities ?? this.subscribedCities,
      // --- نهاية الإضافة ---
    );
  }
}
