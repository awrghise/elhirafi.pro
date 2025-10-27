// lib/services/store_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<StoreModel?> getStoreBySupplier(String supplierId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('stores')
          .where('supplierId', isEqualTo: supplierId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return StoreModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting store: $e');
      return null;
    }
  }

  Future<String?> createStore(StoreModel store) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('stores').add(store.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating store: $e');
      return null;
    }
  }

  Future<bool> updateStore(String storeId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('stores').doc(storeId).update(updates);
      return true;
    } catch (e) {
      print('Error updating store: $e');
      return false;
    }
  }

  Stream<List<ProductModel>> getStoreProducts(String supplierId) {
    return _firestore
        .collection('products')
        .where('supplierId', isEqualTo: supplierId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  Future<int> getProductCount(String supplierId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('supplierId', isEqualTo: supplierId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting product count: $e');
      return 0;
    }
  }
  
  // --- بداية الدالة المضافة لإصلاح الخطأ ---
  // دالة لحساب عدد الطلبات (قيمة وهمية حاليًا)
  Future<int> getOrdersCount(String supplierId) async {
    // TODO: Implement actual order counting logic when the orders feature is built.
    // For now, we return a placeholder value to prevent build errors.
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    return 0; 
  }
  // --- نهاية الدالة المضافة ---

  Stream<Map<String, int>> getDashboardStats(String supplierId) {
    final productCountStream = _firestore
        .collection('products')
        .where('supplierId', isEqualTo: supplierId)
        .snapshots()
        .map((snapshot) => snapshot.size);

    return productCountStream.map((productCount) {
      return {
        'products': productCount,
        'orders': 0, // قيمة وهمية حاليًا
        'revenue': 0, // قيمة وهمية حاليًا
      };
    });
  }

  Future<String?> addProduct(ProductModel product) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('products').add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  Future<bool> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection('products').doc(productId).update(updates);
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId, List<String> imageUrls) async {
    try {
      for (String imageUrl in imageUrls) {
        try {
          if (imageUrl.startsWith('gs://') || imageUrl.startsWith('https://')) {
            await _storage.refFromURL(imageUrl).delete();
          }
        } catch (e) {
          print('Error deleting image from storage: $e');
        }
      }
      await _firestore.collection('products').doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  Future<String?> uploadProductImage(File imageFile, String supplierId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return null;

      if (image.width > 1024 || image.height > 1024) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1024 : null,
          height: image.height > image.width ? 1024 : null,
        );
      }

      final compressedBytes = img.encodeJpg(image, quality: 85);

      final tempDir = await getTemporaryDirectory();
      final tempFile =
          File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('products/$supplierId/$fileName');

      await ref.putFile(tempFile);
      final downloadUrl = await ref.getDownloadURL();

      await tempFile.delete();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Stream<List<StoreModel>> getAllStores() {
    return _firestore
        .collection('stores')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => StoreModel.fromFirestore(doc)).toList());
  }

  Stream<List<ProductModel>> getProductsByStore(String storeId) {
    return _firestore
        .collection('products')
        .where('supplierId', isEqualTo: storeId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  Future<bool> upgradeToPremium(String storeId, int months) async {
    try {
      final expiryDate = DateTime.now().add(Duration(days: months * 30));
      await _firestore.collection('stores').doc(storeId).update({
        'isPremium': true,
        'premiumExpiryDate': Timestamp.fromDate(expiryDate),
        'maxProducts': 50,
      });
      return true;
    } catch (e) {
      print('Error upgrading to premium: $e');
      return false;
    }
  }
}
