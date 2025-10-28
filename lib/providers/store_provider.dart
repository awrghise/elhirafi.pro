// lib/providers/store_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/store_item_model.dart';

class StoreProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<StoreItem> _items = [];
  bool _isLoading = false;

  List<StoreItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchStoreItems(String supplierId) async {
    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('storeItems')
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('createdAt', descending: true)
          .get();
      _items = snapshot.docs.map((doc) => StoreItem.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching store items: $e');
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addStoreItem(StoreItem item, File imageFile) async {
    _setLoading(true);
    try {
      // Create a document reference first to get the ID
      DocumentReference docRef = _firestore.collection('storeItems').doc();
      
      // Upload the image
      final imageUrl = await _uploadItemImage(docRef.id, imageFile);

      // Create the new item with the correct ID and imageUrl
      final newItem = item.copyWith(id: docRef.id, imageUrl: imageUrl);
      
      // Set the data in Firestore
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

  Future<void> deleteStoreItem(String itemId, String supplierId) async {
    _setLoading(true);
    try {
      // Optional: Delete the image from storage first
      // This requires knowing the image path, which can be derived from the URL
      // For simplicity, we'll skip this for now.

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
