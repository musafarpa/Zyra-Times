import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String senderType; // 'customer' or 'shop'
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      chatRoomId: map['chatRoomId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Unknown',
      senderType: map['senderType'] ?? 'customer',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}

class ChatRoom {
  final String id;
  final String shopId;
  final String shopName;
  final String customerId;
  final String customerName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastSenderId;
  final int unreadCountShop;
  final int unreadCountCustomer;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.customerId,
    required this.customerName,
    this.lastMessage,
    this.lastMessageTime,
    this.lastSenderId,
    this.unreadCountShop = 0,
    this.unreadCountCustomer = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'shopName': shopName,
      'customerId': customerId,
      'customerName': customerName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'lastSenderId': lastSenderId,
      'unreadCountShop': unreadCountShop,
      'unreadCountCustomer': unreadCountCustomer,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map, String docId) {
    return ChatRoom(
      id: docId,
      shopId: map['shopId'] ?? '',
      shopName: map['shopName'] ?? 'Unknown Shop',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Unknown Customer',
      lastMessage: map['lastMessage'],
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate(),
      lastSenderId: map['lastSenderId'],
      unreadCountShop: map['unreadCountShop'] ?? 0,
      unreadCountCustomer: map['unreadCountCustomer'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ChatRoom copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? customerId,
    String? customerName,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastSenderId,
    int? unreadCountShop,
    int? unreadCountCustomer,
    DateTime? createdAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      unreadCountShop: unreadCountShop ?? this.unreadCountShop,
      unreadCountCustomer: unreadCountCustomer ?? this.unreadCountCustomer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
