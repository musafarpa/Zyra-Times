import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class BookingModel {
  final String id;
  final String shopId;
  final String seatId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationHours;
  final double totalAmount;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.shopId,
    required this.seatId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.startTime,
    this.endTime,
    required this.durationHours,
    required this.totalAmount,
    this.status = BookingStatus.pending,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'seatId': seatId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationHours': durationHours,
      'totalAmount': totalAmount,
      'status': status.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    return BookingModel(
      id: docId,
      shopId: map['shopId'] ?? '',
      seatId: map['seatId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Unknown',
      customerPhone: map['customerPhone'] ?? '',
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate(),
      durationHours: map['durationHours'] ?? 1,
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => BookingStatus.pending,
      ),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  BookingModel copyWith({
    String? id,
    String? shopId,
    String? seatId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    DateTime? startTime,
    DateTime? endTime,
    int? durationHours,
    double? totalAmount,
    BookingStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      seatId: seatId ?? this.seatId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isInProgress => status == BookingStatus.inProgress;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
}
