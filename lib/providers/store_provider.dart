import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/store_item_model.dart';
import '../models/store_model.dart'; // <-- بداية التعديل 1: استيراد نموذج المتجر

class StoreProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- بداية التعديل 2: إضافة قوائم منفصلة للمتاجر والمنتجات ---
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
  // --- نهاية التعديل 2 ---

  // --- بداية التعديل 3: دالة جديدة لجلب المتاجر (لسان "المتاجر") ---
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
  // --- نهاية التعديل 3 ---

  // --- بداية التعديل 4: دوال الـ Pagination للمنتجات (لسان "المنتجات") ---
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
        // ملاحظة: البحث البسيط يتطلب تطابقًا تامًا. للبحث المتقدم ستحتاج لخدمة خارجية مثل Algolia.
        // هنا سنقوم ببحث بسيط على اسم المنتج.
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
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  // --- نهاية التعديل 4 ---

  // دالة لجلب منتجات متجر معين (لشاشة تفاصيل المتجر)
  Future<void> fetchStoreItemsBySupplier(String supplierId) async {
    _setLoading(true);
    _items.clear(); // مسح القائمة القديمة
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

  // دوال إضافة وتعديل وحذف المنتجات تبقى كما هي...
  Future<void> addStoreItem(StoreItem item, File imageFile) async {
    // ... الكود الحالي ...
  }

  Future<void> updateStoreItem(StoreItem item, {File? newImage}) async {
    // ... الكود الحالي ...
  }

  Future<void> deleteStoreItem(String itemId, String supplierId) async {
    // ... الكود الحالي ...
  }

  Future<String> _uploadItemImage(String itemId, File image) async {
    // ... الكود الحالي ...
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
