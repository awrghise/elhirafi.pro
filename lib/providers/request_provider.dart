// lib/providers/request_provider.dart

import 'dart:async'; // <-- تصحيح الخطأ الإملائي هنا
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../models/user_model.dart' as user_model;
import '../services/request_service.dart';

// ... باقي الكود يبقى كما هو بدون أي تغيير ...
class RequestProvider with ChangeNotifier {
  final RequestService _requestService = RequestService();
  
  List<RequestModel> _requests = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  StreamSubscription? _requestsSubscription;
  
  List<RequestModel> get requests => _requests;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  Future<void> createNewRequest(RequestModel request) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _requestService.createRequest(request);
    } catch (e) {
      print('Error in RequestProvider creating request: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptExistingRequest(String requestId, user_model.UserModel craftsman) async {
    try {
      await _requestService.acceptRequest(requestId, craftsman);
    } catch (e) {
      print('Error in RequestProvider accepting request: $e');
      rethrow;
    }
  }

  Future<void> fetchInitialRequests({
    required String userType,
    required String userId,
    String? professionName,
    String? primaryCity,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _hasMore = true;
    _lastDocument = null;
    _requests.clear();
    notifyListeners();

    try {
      final result = await _requestService.getRequestsPaginated(
        userType: userType,
        userId: userId,
        professionName: professionName,
        primaryCity: primaryCity,
        limit: 15,
      );

      _requests = result['requests'];
      _lastDocument = result['lastDocument'];
      _hasMore = _requests.length == 15;

    } catch (e) {
      print('Error fetching initial requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreRequests({
    required String userType,
    required String userId,
    String? professionName,
    String? primaryCity,
  }) async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _requestService.getRequestsPaginated(
        userType: userType,
        userId: userId,
        professionName: professionName,
        primaryCity: primaryCity,
        limit: 15,
        lastDocument: _lastDocument,
      );

      final newRequests = result['requests'];
      _requests.addAll(newRequests);
      _lastDocument = result['lastDocument'];
      _hasMore = newRequests.length == 15;

    } catch (e) {
      print('Error fetching more requests: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    super.dispose();
  }
}
