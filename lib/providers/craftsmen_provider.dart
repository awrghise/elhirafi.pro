// lib/providers/craftsmen_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class CraftsmenProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserModel> _craftsmen = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  List<UserModel> get craftsmen => _craftsmen;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  CraftsmenProvider() {
    fetchCraftsmen();
  }

  Future<void> fetchCraftsmen({bool isRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    if (isRefresh) {
      _craftsmen = [];
      _lastDocument = null;
      _hasMore = true;
    }
    notifyListeners();

    try {
      Query query = _firestore
          .collection('users')
          .where('userType', isEqualTo: 'craftsman')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10);

      if (_lastDocument != null && !isRefresh) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.last;
        _craftsmen.addAll(snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
      }
    } catch (e) {
      print("Error fetching craftsmen: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
