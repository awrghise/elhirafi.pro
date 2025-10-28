// lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel? user) {
    if (_user != user) {
      _user = user;
      notifyListeners();
    }
  }

  /// **الوظيفة الأساسية لتحقيق هدفك**
  /// تقوم هذه الدالة بتحديث قائمة المدن التي يتابعها المستخدم في قاعدة البيانات.
  Future<void> updateUserSubscribedCities(List<String> cities) async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.id).update({
        'subscribedCities': cities,
      });
      // تحديث بيانات المستخدم محليًا بعد النجاح
      _user = _user!.copyWith(subscribedCities: cities);
      notifyListeners();
      print("User subscribed cities updated successfully.");
    } catch (e) {
      print("Error updating subscribed cities: $e");
      // يمكنك هنا إظهار رسالة خطأ للمستخدم إذا أردت
      rethrow;
    }
  }

  // دالة لتحديث بيانات المستخدم بشكل عام إذا احتجنا إليها لاحقًا
  Future<void> refreshUserData() async {
    if (_user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_user!.id).get();
      if (doc.exists) {
        setUser(UserModel.fromFirestore(doc));
      }
    } catch (e) {
      print("Error refreshing user data: $e");
    }
  }
}
