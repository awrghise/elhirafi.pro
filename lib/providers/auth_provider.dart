import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
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

  bool get isAuthenticated => _user != null;

  Stream<UserModel?> get userStream {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        return null;
      }
      await _fetchUser(firebaseUser.uid);
      return _user;
    });
  }

  Future<void> _fetchUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
        notifyListeners();
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
    String? profession,
    String? primaryWorkCity,
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
        profession: profession ?? '',
        primaryWorkCity: primaryWorkCity ?? '',
        country: country ?? '',
        subscribedCities: primaryWorkCity != null ? [primaryWorkCity] : [],
        isAvailable: userType == AppStrings.craftsman,
        createdAt: DateTime.now(),
        experience: 0,
        rating: 0.0,
        reviewCount: 0,
      );

      await _firestore.collection('users').doc(newUser.id).set(newUser.toFirestore());
      _user = newUser;
      notifyListeners();
      
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

  Future<String> _uploadProfileImage(String userId, File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return '';

      if (image.width > 1024 || image.height > 1024) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1024 : null,
          height: image.height > image.width ? 1024 : null,
        );
      }

      final compressedBytes = img.encodeJpg(image, quality: 85);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$userId.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      await ref.putFile(tempFile);

      await tempFile.delete();

      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading and compressing profile image: $e");
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
        final imageUrl = await _uploadProfileImage(userId, newImage);
        if (imageUrl.isNotEmpty) {
          data['profileImageUrl'] = imageUrl;
        }
      }
      await _firestore.collection('users').doc(userId).update(data);
      await _fetchUser(userId);
      notifyListeners();
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserType(String newUserType) async {
    if (_user == null) return;
    _setLoading(true);
    try {
      await _firestore.collection('users').doc(_user!.id).update({'userType': newUserType});
      _user = _user!.copyWith(userType: newUserType);
      notifyListeners();
    } catch (e) {
      print("Error updating user type: $e");
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
      notifyListeners();
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
