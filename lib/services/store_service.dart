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

  // ... (باقي الدوال تبقى كما هي) ...
  
  Future<String?> uploadProductImage(File imageFile, String supplierId) async {
    try {
      // 1. قراءة الصورة
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        print('Failed to decode image.');
        return null;
      }

      // 2. تغيير الحجم إذا كانت الصورة كبيرة (منطق سليم)
      if (image.width > 1024 || image.height > 1024) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1024 : null,
          height: image.height > image.width ? 1024 : null,
        );
      }

      // 3. ضغط الجودة (منطق سليم)
      final compressedBytes = img.encodeJpg(image, quality: 85);

      // 4. استخدام ملف مؤقت للرفع
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(compressedBytes);

      // 5. رفع الملف المضغوط
      final ref = _storage.ref().child('products/$supplierId/$fileName');
      await ref.putFile(tempFile);
      final downloadUrl = await ref.getDownloadURL();

      // 6. حذف الملف المؤقت
      await tempFile.delete();

      return downloadUrl;
    } catch (e) {
      print('Error uploading and compressing product image: $e');
      return null;
    }
  }

  // ... (باقي الدوال تبقى كما هي) ...
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
  
  Future<int> getOrdersCount(String supplierId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 0; 
  }

  Stream<Map<String, int>> getDashboardStats(String supplierId) {
    final productCountStream = _firestore
        .collection('products')
        .where('supplierId', isEqualTo: supplierId)
        .snapshots()
        .map((snapshot) => snapshot.size);

    return productCountStream.map((productCount) {
      return {
        'products': productCount,
        'orders': 0,
        'revenue': 0,
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
