import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String supplierId;
  final String name;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String category;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.supplierId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.category,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      supplierId: data['supplierId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from(data['imageUrls']) 
          : [],
      category: data['category'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'supplierId': supplierId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'category': category,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProductModel copyWith({
    String? id,
    String? supplierId,
    String? name,
    String? description,
    double? price,
    List<String>? imageUrls,
    String? category,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class StoreModel {
  final String id;
  final String supplierId;
  final String storeName;
  final String description;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final String address;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  final int maxProducts;
  final DateTime createdAt;

  StoreModel({
    required this.id,
    required this.supplierId,
    required this.storeName,
    required this.description,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.maxProducts = 10, // Free tier: 10 products
    required this.createdAt,
  });

  factory StoreModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StoreModel(
      id: doc.id,
      supplierId: data['supplierId'] ?? '',
      storeName: data['storeName'] ?? '',
      description: data['description'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      isPremium: data['isPremium'] ?? false,
      premiumExpiryDate: data['premiumExpiryDate'] != null
          ? (data['premiumExpiryDate'] as Timestamp).toDate()
          : null,
      maxProducts: data['maxProducts'] ?? 10,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'supplierId': supplierId,
      'storeName': storeName,
      'description': description,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate != null
          ? Timestamp.fromDate(premiumExpiryDate!)
          : null,
      'maxProducts': maxProducts,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isActive {
    if (!isPremium) return true;
    if (premiumExpiryDate == null) return false;
    return premiumExpiryDate!.isAfter(DateTime.now());
  }

  int get actualMaxProducts {
    return isActive ? maxProducts : 10;
  }
}

