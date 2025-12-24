import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceCategory {
  hair,
  beard,
  face,
  body,
  other,
}

class ServiceModel {
  final String id;
  final String shopId;
  final String name;
  final String? description;
  final ServiceCategory category;
  final double price;
  final int durationMinutes;
  final bool isActive;
  final String? imageUrl;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.shopId,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    this.durationMinutes = 30,
    this.isActive = true,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'description': description,
      'category': category.name,
      'price': price,
      'durationMinutes': durationMinutes,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceModel(
      id: docId,
      shopId: map['shopId'] ?? '',
      name: map['name'] ?? 'Unknown Service',
      description: map['description'],
      category: ServiceCategory.values.firstWhere(
        (e) => e.name == (map['category'] ?? 'other'),
        orElse: () => ServiceCategory.other,
      ),
      price: (map['price'] ?? 0.0).toDouble(),
      durationMinutes: map['durationMinutes'] ?? 30,
      isActive: map['isActive'] ?? true,
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ServiceModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? description,
    ServiceCategory? category,
    double? price,
    int? durationMinutes,
    bool? isActive,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Default services to add when a new shop is created
  static List<ServiceModel> getDefaultServices(String shopId) {
    return [
      ServiceModel(
        id: '',
        shopId: shopId,
        name: 'Haircut',
        description: 'Classic haircut with styling',
        category: ServiceCategory.hair,
        price: 25.0,
        durationMinutes: 30,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: '',
        shopId: shopId,
        name: 'Beard Trim',
        description: 'Professional beard grooming and shaping',
        category: ServiceCategory.beard,
        price: 15.0,
        durationMinutes: 20,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: '',
        shopId: shopId,
        name: 'Facial',
        description: 'Relaxing facial treatment for skin care',
        category: ServiceCategory.face,
        price: 35.0,
        durationMinutes: 45,
        createdAt: DateTime.now(),
      ),
      ServiceModel(
        id: '',
        shopId: shopId,
        name: 'Massage',
        description: 'Full body relaxation massage',
        category: ServiceCategory.body,
        price: 45.0,
        durationMinutes: 60,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Get icon for category
  static String getCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.hair:
        return 'cut';
      case ServiceCategory.beard:
        return 'face';
      case ServiceCategory.face:
        return 'spa';
      case ServiceCategory.body:
        return 'self_improvement';
      case ServiceCategory.other:
        return 'star';
    }
  }

  // Get category display name
  static String getCategoryName(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.hair:
        return 'Hair';
      case ServiceCategory.beard:
        return 'Beard';
      case ServiceCategory.face:
        return 'Face';
      case ServiceCategory.body:
        return 'Body';
      case ServiceCategory.other:
        return 'Other';
    }
  }
}
