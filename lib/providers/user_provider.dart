// lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  // دالة لتحديث المدن التي يتابعها المستخدم في Firestore
  Future<void> updateUserSubscribedCities(List<String> cities) async {
    if (_user == null) return;

    try {
      // --- بداية التعديل: استخدام الاسم الصحيح للحقل ---
      await _firestore.collection('users').doc(_user!.id).update({
        'subscribedCities': cities,
      });
      // --- نهاية التعديل ---

      // تحديث الحالة المحلية للمستخدم لتعكس التغيير فوراً في الواجهة
      _user = _user!.copyWith(subscribedCities: cities);
      notifyListeners();
    } catch (e) {
      print("Error updating subscribed cities: $e");
      // يمكنك رمي الخطأ مرة أخرى إذا أردت معالجته في الواجهة
      rethrow;
    }
  }

  // دالة لتحديث بيانات المستخدم بشكل عام (يمكن استخدامها لاحقًا)
  Future<void> refreshUserData() async {
    if (_user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_user!.id).get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      print("Error refreshing user data: $e");
    }
  }
}
