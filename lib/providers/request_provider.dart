import 'dart:async';
import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../models/user_model.dart' as user_model;
import '../services/request_service.dart';

class RequestProvider with ChangeNotifier {
  final RequestService _requestService = RequestService();
  List<RequestModel> _requests = [];
  bool _isLoading = false;
  StreamSubscription? _requestsSubscription;

  List<RequestModel> get requests => _requests;
  bool get isLoading => _isLoading;

  // دالة لإنشاء طلب جديد
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

  // دالة لقبول طلب
  Future<void> acceptExistingRequest(String requestId, user_model.UserModel craftsman) async {
    try {
      await _requestService.acceptRequest(requestId, craftsman);
    } catch (e) {
      print('Error in RequestProvider accepting request: $e');
      rethrow;
    }
  }

  // دالة لجلب الطلبات والاستماع لتحديثاتها
  void listenToRequests({
    required String userType,
    required String userId,
    String? professionName,
    List<String>? workCities,
  }) {
    _isLoading = true;
    notifyListeners();

    // إلغاء الاشتراك القديم قبل إنشاء واحد جديد
    _requestsSubscription?.cancel();

    Stream<List<RequestModel>> stream;

    if (userType == 'أنا حرفي' && professionName != null && workCities != null) {
      stream = _requestService.getCraftsmanRequestsStream(
        professionName: professionName,
        workCities: workCities,
      );
    } else {
      stream = _requestService.getClientRequestsStream(clientId: userId);
    }

    _requestsSubscription = stream.listen((requestsData) {
      _requests = requestsData;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error listening to requests: $error');
      _isLoading = false;
      _requests = [];
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    super.dispose();
  }
}
