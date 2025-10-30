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
  final List<String> subscribedCities;

  UserModel({
    required this.id,
    required this.email,
    this.name = '',
    this.phoneNumber = '',
    this.userType = 'عميل',
    this.profileImageUrl = '',
    this.profession = '',
    this.experience = 0,
    this.primaryWorkCity = '',
    this.country = '',
    this.isAvailable = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    this.subscribedCities = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // توحيد قيمة userType عند القراءة من Firestore
    String rawUserType = data['userType'] ?? 'عميل';
    String normalizedUserType = _normalizeUserType(rawUserType);
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      userType: normalizedUserType,
      profileImageUrl: data['profileImageUrl'] ?? '',
      profession: data['profession'] ?? '',
      experience: data['experience'] ?? 0,
      primaryWorkCity: data['primaryWorkCity'] ?? '',
      country: data['country'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subscribedCities: List<String>.from(data['subscribedCities'] ?? []),
    );
  }

  // دالة مساعدة لتوحيد نوع المستخدم
  static String _normalizeUserType(String userType) {
    final normalized = userType.trim().toLowerCase();
    if (normalized == 'client' || normalized == 'عميل') {
      return 'عميل';
    } else if (normalized == 'craftsman' || normalized == 'حرفي') {
      return 'حرفي';
    } else if (normalized == 'supplier' || normalized == 'مورد') {
      return 'مورد';
    }
    return 'عميل'; // القيمة الافتراضية
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
      'subscribedCities': subscribedCities,
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
    List<String>? subscribedCities,
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
      subscribedCities: subscribedCities ?? this.subscribedCities,
    );
  }
}
