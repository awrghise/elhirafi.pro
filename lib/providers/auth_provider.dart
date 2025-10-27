// lib/providers/auth_provider.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../constants/app_strings.dart';

class AuthProvider with ChangeNotifier {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- بداية التعديل 1: إضافة المتغير المفقود ---
  bool get isAuthenticated => _user != null;
  // --- نهاية التعديل 1 ---

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(auth.User? firebaseUser) async {
    _setLoading(true);
    if (firebaseUser == null) {
      _user = null;
    } else {
      await _fetchUser(firebaseUser.uid);
    }
    _setLoading(false);
  }

  Future<void> _fetchUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print("Error fetching user: $e");
      _user = null;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String userType,
    String? professionName,
    String? primaryCity,
    String? country,
    File? profileImage,
  }) async {
    _setLoading(true);
    try {
      auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String profileImageUrl = '';
      if (profileImage != null) {
        profileImageUrl = await _uploadProfileImage(userCredential.user!.uid, profileImage);
      }

      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        userType: userType,
        profileImageUrl: profileImageUrl,
        professionName: professionName,
        primaryWorkCity: primaryCity,
        country: country,
        alertCities: primaryCity != null ? [primaryCity] : [],
        isAvailable: userType == AppStrings.craftsman ? true : null,
        createdAt: Timestamp.now(),
      );

      await _firestore.collection('users').doc(newUser.id).set(newUser.toFirestore());
      _user = newUser;
      
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _user = null;
    notifyListeners();
  }

  // --- بداية التعديل 2: إضافة الدالة المفقودة ---
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  // --- نهاية التعديل 2 ---

  Future<String> _uploadProfileImage(String userId, File image) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading profile image: $e");
      return '';
    }
  }
  
  Future<void> updateUserProfileWithImage({
    required String userId,
    required Map<String, dynamic> data,
    File? newImage,
  }) async {
    _setLoading(true);
    try {
      if (newImage != null) {
        data['profileImageUrl'] = await _uploadProfileImage(userId, newImage);
      }
      await _firestore.collection('users').doc(userId).update(data);
      await _fetchUser(userId);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- بداية التعديل 3: إضافة الدالة المفقودة ---
  Future<void> updateUserType(String newUserType) async {
    if (_user == null) return;
    _setLoading(true);
    try {
      await _firestore.collection('users').doc(_user!.id).update({'userType': newUserType});
      _user = _user!.copyWith(userType: newUserType);
    } catch (e) {
      print("Error updating user type: $e");
    } finally {
      _setLoading(false);
    }
  }
  // --- نهاية التعديل 3 ---

  Future<void> updateAvailability(bool isAvailable) async {
    if (_user == null) return;
    _setLoading(true);
    try {
      await _firestore.collection('users').doc(_user!.id).update({'isAvailable': isAvailable});
      _user = _user!.copyWith(isAvailable: isAvailable);
    } catch (e) {
      print("Error updating availability: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
