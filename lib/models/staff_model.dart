import 'package:cloud_firestore/cloud_firestore.dart';

enum StaffRole {
  manager,
  attendant,
  cleaner,
  cashier,
}

class StaffModel {
  final String id;
  final String shopId;
  final String name;
  final String phone;
  final String email;
  final StaffRole role;
  final double salary;
  final bool isActive;
  final DateTime joinedAt;
  final String? imageUrl;

  StaffModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.salary,
    this.isActive = true,
    required this.joinedAt,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.name,
      'salary': salary,
      'isActive': isActive,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'imageUrl': imageUrl,
    };
  }

  factory StaffModel.fromMap(Map<String, dynamic> map, String docId) {
    return StaffModel(
      id: docId,
      shopId: map['shopId'] ?? '',
      name: map['name'] ?? 'Unknown',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      role: StaffRole.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'attendant'),
        orElse: () => StaffRole.attendant,
      ),
      salary: (map['salary'] ?? 0.0).toDouble(),
      isActive: map['isActive'] ?? true,
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }

  StaffModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? phone,
    String? email,
    StaffRole? role,
    double? salary,
    bool? isActive,
    DateTime? joinedAt,
    String? imageUrl,
  }) {
    return StaffModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      salary: salary ?? this.salary,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt ?? this.joinedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
