import 'package:cloud_firestore/cloud_firestore.dart';

enum SeatStatus {
  available,
  occupied,
  reserved,
  maintenance,
}

enum SeatType {
  standard,
  premium,
  vip,
}

class SeatModel {
  final String id;
  final String shopId;
  final String name;
  final String? description;
  final SeatStatus status;
  final SeatType type;
  final double pricePerHour;
  final bool hasPricing; // Toggle for enabling/disabling price display
  final int seatNumber;
  final String? currentCustomerId;
  final DateTime? occupiedSince;
  final DateTime createdAt;

  SeatModel({
    required this.id,
    required this.shopId,
    required this.name,
    this.description,
    this.status = SeatStatus.available,
    this.type = SeatType.standard,
    this.pricePerHour = 0.0,
    this.hasPricing = false,
    required this.seatNumber,
    this.currentCustomerId,
    this.occupiedSince,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'description': description,
      'status': status.name,
      'type': type.name,
      'pricePerHour': pricePerHour,
      'hasPricing': hasPricing,
      'seatNumber': seatNumber,
      'currentCustomerId': currentCustomerId,
      'occupiedSince': occupiedSince != null ? Timestamp.fromDate(occupiedSince!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SeatModel.fromMap(Map<String, dynamic> map, String docId) {
    return SeatModel(
      id: docId,
      shopId: map['shopId'] ?? '',
      name: map['name'] ?? 'Unknown Seat',
      description: map['description'],
      status: SeatStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'available'),
        orElse: () => SeatStatus.available,
      ),
      type: SeatType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'standard'),
        orElse: () => SeatType.standard,
      ),
      pricePerHour: (map['pricePerHour'] ?? 0.0).toDouble(),
      hasPricing: map['hasPricing'] ?? false,
      seatNumber: map['seatNumber'] ?? 0,
      currentCustomerId: map['currentCustomerId'],
      occupiedSince: (map['occupiedSince'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  SeatModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? description,
    SeatStatus? status,
    SeatType? type,
    double? pricePerHour,
    bool? hasPricing,
    int? seatNumber,
    String? currentCustomerId,
    DateTime? occupiedSince,
    DateTime? createdAt,
  }) {
    return SeatModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      type: type ?? this.type,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      hasPricing: hasPricing ?? this.hasPricing,
      seatNumber: seatNumber ?? this.seatNumber,
      currentCustomerId: currentCustomerId ?? this.currentCustomerId,
      occupiedSince: occupiedSince ?? this.occupiedSince,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isAvailable => status == SeatStatus.available;
  bool get isOccupied => status == SeatStatus.occupied;
  bool get isReserved => status == SeatStatus.reserved;
}
