import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../models/user_model.dart' as user_model;

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Publish a new request
  Future<void> createRequest(RequestModel request) async {
    try {
      await _firestore.collection('requests').add(request.toFirestore());
    } catch (e) {
      print('Error creating request: $e');
      rethrow;
    }
  }

  // Listen to requests for a craftsman
  Stream<List<RequestModel>> getCraftsmanRequestsStream({
    required String professionName,
    required List<String> workCities,
  }) {
    // Craftsmen should see requests that match their profession and are in their work cities
    return _firestore
        .collection('requests')
        .where('professionName', isEqualTo: professionName)
        .where('city', whereIn: workCities)
        .where('status', isEqualTo: 'pending') // Only show pending requests
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RequestModel.fromFirestore(doc)).toList();
    });
  }

  // Listen to requests for a client
  Stream<List<RequestModel>> getClientRequestsStream({required String clientId}) {
    // Clients should see all requests they have created
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
        'craftsmanPhone': craftsman.phoneNumber, // <-- تم التصحيح
      });
    } catch (e) {
      print('Error accepting request: $e');
      rethrow;
    }
  }
}
