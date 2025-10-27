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

  // --- بداية الإضافة: الدالة المفقودة ---
  Future<Map<String, dynamic>> getRequestsPaginated({
    required String userType,
    required String userId,
    required int limit,
    String? professionName,
    String? primaryCity,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query;

    if (userType == 'craftsman' && professionName != null && primaryCity != null) {
      query = _firestore
          .collection('requests')
          .where('profession', isEqualTo: professionName)
          .where('city', isEqualTo: primaryCity) // البحث في مدينة العمل الأساسية فقط
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true);
    } else {
      query = _firestore
          .collection('requests')
          .where('clientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);
    }

    query = query.limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final requests = snapshot.docs.map((doc) => RequestModel.fromFirestore(doc)).toList();
    final newLastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return {
      'requests': requests,
      'lastDocument': newLastDocument,
    };
  }
  // --- نهاية الإضافة ---

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
