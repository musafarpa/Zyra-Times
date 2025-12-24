import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  newBooking,
  bookingCancelled,
  bookingCompleted,
  newReview,
  general,
}

class NotificationModel {
  final String id;
  final String shopId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String? bookingId;
  final String? customerId;
  final String? customerName;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.shopId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.bookingId,
    this.customerId,
    this.customerName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'bookingId': bookingId,
      'customerId': customerId,
      'customerName': customerName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      shopId: map['shopId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'general'),
        orElse: () => NotificationType.general,
      ),
      isRead: map['isRead'] ?? false,
      bookingId: map['bookingId'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? shopId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    String? bookingId,
    String? customerId,
    String? customerName,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
