import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/store_item_model.dart';
import '../models/store_model.dart';

class StoreProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- قوائم منفصلة للمتاجر والمنتجات ---
  List<StoreModel> _stores = []; // قائمة لتخزين المتاجر
  List<StoreItem> _items = []; // قائمة لتخزين المنتجات (سواء لمتجر واحد أو للجميع)
  
  bool _isLoading = false;
  bool _isLoadingMore = false; // للـ Pagination
  bool _hasMore = true;      // للـ Pagination
  DocumentSnapshot? _lastDocument; // للـ Pagination

  List<StoreModel> get stores => _stores;
  List<StoreItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  // --- دالة جديدة لجلب المتاجر (لسان "المتاجر") ---
  Future<void> fetchStores() async {
    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('stores')
          .orderBy('createdAt', descending: true)
          .get();
      _stores = snapshot.docs.map((doc) => StoreModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching stores: $e');
      _stores = [];
    } finally {
      _setLoading(false);
    }
  }

  // --- دوال الـ Pagination للمنتجات (لسان "المنتجات") ---
  Future<void> fetchInitialPaginatedItems({String? searchTerm}) async {
    if (_isLoading) return;

    _setLoading(true);
    _hasMore = true;
    _lastDocument = null;
    _items.clear();
    notifyListeners();

    try {
      Query query = _firestore
          .collection('storeItems')
          .orderBy('createdAt', descending: true);

      // تطبيق البحث إذا كان موجودًا
      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.where('name', isGreaterThanOrEqualTo: searchTerm)
                     .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff');
      }

      final snapshot = await query.limit(15).get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }
      
      _items = snapshot.docs.map((doc) => StoreItem.fromFirestore(doc)).toList();
      _hasMore = _items.length == 15;

    } catch (e) {
      print('Error fetching initial items: $e');
      // في حالة حدوث خطأ في البحث، حاول الجلب بدون بحث
      if (searchTerm != null && searchTerm.isNotEmpty) {
        print('Retrying fetch without search term due to error.');
        await fetchInitialPaginatedItems(); // استدعاء بدون مصطلح البحث
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMorePaginatedItems({String? searchTerm}) async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('storeItems')
          .orderBy('createdAt', descending: true);

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.where('name', isGreaterThanOrEqualTo: searchTerm)
                     .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff');
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.limit(15).get();
      
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      final newItems = snapshot.docs.map((doc) => StoreItem.fromFirestore(doc)).toList();
      _items.addAll(newItems);
      _hasMore = newItems.length == 15;

    } catch (e) {
      print('Error fetching more items: $e');
      _hasMore = false; // إيقاف المحاولات المستقبلية عند حدوث خطأ
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // --- دالة لجلب منتجات متجر معين (لشاشة تفاصيل المتجر) ---
  Future<void> fetchStoreItemsBySupplier(String supplierId) async {
    _setLoading(true);
    _items.clear(); // مسح القائمة القديمة
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('storeItems')
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('createdAt', descending: true)
          .get();
      _items = snapshot.docs.map((doc) => StoreItem.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching store items by supplier: $e');
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  // --- دوال إدارة المنتجات (من الكود الأصلي لديك) ---
  Future<void> addStoreItem(StoreItem item, File imageFile) async {
    _setLoading(true);
    try {
      DocumentReference docRef = _firestore.collection('storeItems').doc();
      final imageUrl = await _uploadItemImage(docRef.id, imageFile);
      final newItem = item.copyWith(id: docRef.id, imageUrl: imageUrl);
      await docRef.set(newItem.toFirestore());
      _items.insert(0, newItem);
    } catch (e) {
      print('Error adding store item: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStoreItem(StoreItem item, {File? newImage}) async {
    _setLoading(true);
    try {
      String imageUrl = item.imageUrl;
      if (newImage != null) {
        imageUrl = await _uploadItemImage(item.id, newImage);
      }
      
      final updatedItem = item.copyWith(imageUrl: imageUrl);

      await _firestore
          .collection('storeItems')
          .doc(item.id)
          .update(updatedItem.toFirestore());
      
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = updatedItem;
      }
    } catch (e) {
      print('Error updating store item: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteStoreItem(String itemId) async {
    // تم إزالة supplierId لأنه غير ضروري للحذف
    _setLoading(true);
    try {
      await _firestore.collection('storeItems').doc(itemId).delete();
      _items.removeWhere((item) => item.id == itemId);
    } catch (e) {
      print('Error deleting store item: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> _uploadItemImage(String itemId, File image) async {
    try {
      final ref = _storage.ref().child('store_items').child('$itemId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading item image: $e");
      return '';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
