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

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      await _fetchUser(firebaseUser.uid);
    }
    notifyListeners();
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
    // We notify listeners in _onAuthStateChanged
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String userType,
    String? professionName,
    String? primaryCity, // This is the incoming parameter
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

      // --- بداية التعديل ---
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        userType: userType,
        profileImageUrl: profileImageUrl,
        professionName: professionName,
        primaryWorkCity: primaryCity, // <-- استخدام الحقل الصحيح 'primaryWorkCity'
        country: country,
        alertCities: primaryCity != null ? [primaryCity] : [],
        isAvailable: userType == AppStrings.craftsman ? true : null,
        createdAt: Timestamp.now(),
      );
      // --- نهاية التعديل ---

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
      await _fetchUser(userId); // Refresh user data
      notifyListeners(); // Notify after fetching new data
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

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
