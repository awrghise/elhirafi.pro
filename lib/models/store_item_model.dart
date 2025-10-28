// lib/models/store_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class StoreItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String supplierId;
  final Timestamp createdAt;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.supplierId,
    required this.createdAt,
  });

  factory StoreItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StoreItem(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      supplierId: data['supplierId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'supplierId': supplierId,
      'createdAt': createdAt,
    };
  }

  StoreItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? supplierId,
    Timestamp? createdAt,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      supplierId: supplierId ?? this.supplierId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
