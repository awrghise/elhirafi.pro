// lib/providers/auth_provider.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../constants/app_strings.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _user != null;

  StreamSubscription<User?>? _authStateSubscription;

  AuthProvider() {
    _authStateSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      await _fetchUser(firebaseUser.uid);
    }
    notifyListeners();
  }

  Future<void> _fetchUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      } else {
        _user = null;
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
    File? profileImage,
    String? professionName,
    List<String>? workCities,
    String? country,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? profileImageUrl;
      if (profileImage != null) {
        final ref = _storage.ref().child('user_images').child('${userCredential.user!.uid}.jpg');
        await ref.putFile(profileImage);
        profileImageUrl = await ref.getDownloadURL();
      }

      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        userType: userType,
        profileImageUrl: profileImageUrl ?? '',
        professionName: professionName,
        workCities: workCities ?? [],
        country: country ?? 'المغرب',
        isAvailable: userType == AppStrings.craftsman ? true : false,
        createdAt: Timestamp.now(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toFirestore());
      _user = newUser;

    } catch (e) {
      print("Registration failed: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        await _fetchUser(userCredential.user!.uid);
      } else {
        _user = null;
      }
    } catch (e) {
      print("Login failed: $e");
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
  
  Future<void> updateAvailability(bool isAvailable) async {
    if (_user != null) {
      try {
        await _firestore.collection('users').doc(_user!.id).update({'isAvailable': isAvailable});
        _user = _user!.copyWith(isAvailable: isAvailable);
        notifyListeners();
      } catch (e) {
        print("Failed to update availability: $e");
      }
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Failed to send password reset email: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- بداية الدوال التي تم إصلاحها وإعادتها ---
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(userId).update(data);
      await _fetchUser(userId); // إعادة جلب بيانات المستخدم المحدثة
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserType(String userId, String newUserType) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(userId).update({'userType': newUserType});
      await _fetchUser(userId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // --- نهاية الدوال التي تم إصلاحها ---
}
