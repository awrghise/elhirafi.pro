import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String userType;
  final String profileImageUrl;
  final String? professionName;
  final List<String> alertCities;
  final String? primaryWorkCity; // <-- إعادة الحقل المفقود
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
    this.professionName,
    this.alertCities = const [],
    this.primaryWorkCity, // <-- إعادة الحقل المفقود
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
      professionName: data['professionName'],
      alertCities: List<String>.from(data['alertCities'] ?? []),
      primaryWorkCity: data['primaryWorkCity'], // <-- إعادة الحقل المفقود
      country: data['country'],
      isAvailable: data['isAvailable'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'profileImageUrl': profileImageUrl,
      'professionName': professionName,
      'alertCities': alertCities,
      'primaryWorkCity': primaryWorkCity, // <-- إعادة الحقل المفقود
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
    String? professionName,
    List<String>? alertCities,
    String? primaryWorkCity, // <-- إعادة الحقل المفقود
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
      professionName: professionName ?? this.professionName,
      alertCities: alertCities ?? this.alertCities,
      primaryWorkCity: primaryWorkCity ?? this.primaryWorkCity, // <-- إعادة الحقل المفقود
      country: country ?? this.country,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
