// lib/services/request_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../models/user_model.dart' as user_model;

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createRequest(RequestModel request) async {
    try {
      await _firestore.collection('requests').add(request.toFirestore());
    } catch (e) {
      print('Error creating request: $e');
      rethrow;
    }
  }

  Stream<List<RequestModel>> getCraftsmanRequestsStream({
    required String professionName,
    // --- بداية التعديل ---
    required List<String> alertCities,
    // --- نهاية التعديل ---
  }) {
    return _firestore
        .collection('requests')
        .where('professionName', isEqualTo: professionName)
        // --- بداية التعديل ---
        .where('city', whereIn: alertCities)
        // --- نهاية التعديل ---
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RequestModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<RequestModel>> getClientRequestsStream({required String clientId}) {
    return _firestore
        .collection('requests')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RequestModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> acceptRequest(String requestId, user_model.UserModel craftsman) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'accepted',
        'craftsmanId': craftsman.id,
        'craftsmanName': craftsman.name,
        'craftsmanPhone': craftsman.phoneNumber,
      });
    } catch (e) {
      print('Error accepting request: $e');
      rethrow;
    }
  }
}
