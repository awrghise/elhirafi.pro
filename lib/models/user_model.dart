// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String userType;
  final String profileImageUrl;
  final String? professionId;
  final String? professionName;
  // --- بداية التعديل ---
  final String? primaryCity;       // مدينة العمل الأساسية (واحدة)
  final List<String> alertCities; // مدن تلقي التنبيهات (متعددة)
  // --- نهاية التعديل ---
  final String? country;
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
    // --- بداية التعديل ---
    this.primaryCity,
    this.alertCities = const [],
    // --- نهاية التعديل ---
    this.country,
    this.isAvailable,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

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
      // --- بداية التعديل ---
      primaryCity: data['primaryCity'],
      alertCities: List<String>.from(data['alertCities'] ?? []),
      // --- نهاية التعديل ---
      country: data['country'],
      isAvailable: data['isAvailable'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Getters للتوافق مع الكود القديم (سيتم إزالتها لاحقًا)
  String get uid => id;
  String get displayName => name;
  String get profession => professionName ?? '';
  List<String> get cities => alertCities; // توجيه Getter القديم للحقل الجديد
  int? get yearsOfExperience => null;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'profileImageUrl': profileImageUrl,
      'professionId': professionId,
      'professionName': professionName,
      // --- بداية التعديل ---
      'primaryCity': primaryCity,
      'alertCities': alertCities,
      // --- نهاية التعديل ---
      'country': country,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? userType,
    String? profileImageUrl,
    String? professionId,
    String? professionName,
    // --- بداية التعديل ---
    String? primaryCity,
    List<String>? alertCities,
    // --- نهاية التعديل ---
    String? country,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    Timestamp? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      professionId: professionId ?? this.professionId,
      professionName: professionName ?? this.professionName,
      // --- بداية التعديل ---
      primaryCity: primaryCity ?? this.primaryCity,
      alertCities: alertCities ?? this.alertCities,
      // --- نهاية التعديل ---
      country: country ?? this.country,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
