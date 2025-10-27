import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get store by supplier ID
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

  // Create store
  Future<String?> createStore(StoreModel store) async {
    try {
      DocumentReference docRef = await _firestore.collection('stores').add(store.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating store: $e');
      return null;
    }
  }

  // Update store
  Future<bool> updateStore(String storeId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('stores').doc(storeId).update(updates);
      return true;
    } catch (e) {
      print('Error updating store: $e');
      return false;
    }
  }

  // Get products by store
  Stream<List<ProductModel>> getStoreProducts(String supplierId) {
    return _firestore
        .collection('products')
        .where('supplierId', isEqualTo: supplierId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  // Get product count for supplier
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

  // Add product
  Future<String?> addProduct(ProductModel product) async {
    try {
      DocumentReference docRef = await _firestore.collection('products').add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  // Update product
  Future<bool> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection('products').doc(productId).update(updates);
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId, List<String> imageUrls) async {
    try {
      // Delete images from storage
      for (String imageUrl in imageUrls) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }

      // Delete product document
      await _firestore.collection('products').doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Compress and upload image
  Future<String?> uploadProductImage(File imageFile, String supplierId) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return null;

      // Resize if too large (max 1024x1024)
      if (image.width > 1024 || image.height > 1024) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1024 : null,
          height: image.height > image.width ? 1024 : null,
        );
      }

      // Compress to JPEG with quality 85
      final compressedBytes = img.encodeJpg(image, quality: 85);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      // Upload to Firebase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('products/$supplierId/$fileName');
      
      await ref.putFile(tempFile);
      final downloadUrl = await ref.getDownloadURL();

      // Delete temp file
      await tempFile.delete();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Get all stores (for marketplace)
  Stream<List<StoreModel>> getAllStores() {
    return _firestore
        .collection('stores')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoreModel.fromFirestore(doc))
            .toList());
  }

  // Get products by store ID (for marketplace)
  Stream<List<ProductModel>> getProductsByStore(String storeId) {
    return _firestore
        .collection('products')
        .where('supplierId', isEqualTo: storeId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  // Upgrade to premium
  Future<bool> upgradeToPremium(String storeId, int months) async {
    try {
      final expiryDate = DateTime.now().add(Duration(days: months * 30));
      await _firestore.collection('stores').doc(storeId).update({
        'isPremium': true,
        'premiumExpiryDate': Timestamp.fromDate(expiryDate),
        'maxProducts': 50, // Premium: 50 products
      });
      return true;
    } catch (e) {
      print('Error upgrading to premium: $e');
      return false;
    }
  }
}

