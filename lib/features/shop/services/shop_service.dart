import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/models/seat_model.dart';
import 'package:zyraslot/models/staff_model.dart';
import 'package:zyraslot/models/booking_model.dart';
import 'package:zyraslot/models/service_model.dart';
import 'package:zyraslot/models/notification_model.dart';
import 'package:zyraslot/models/chat_model.dart';

class ShopService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  //  SHOP MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> addShop(ShopModel shop, File? imageFile) async {
    try {
      String imageUrl = shop.imageUrl;

      if (imageFile != null) {
        final ref = _storage
            .ref()
            .child('shop_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final docRef = _firestore.collection('shops').doc();

      final newShop = ShopModel(
        id: docRef.id,
        ownerId: shop.ownerId,
        name: shop.name,
        description: shop.description,
        address: shop.address,
        latitude: shop.latitude,
        longitude: shop.longitude,
        imageUrl: imageUrl,
        totalSeats: shop.totalSeats,
        rating: shop.rating,
      );

      await docRef.set(newShop.toMap());

      // Default services are OFF by default - shop owner enables them manually

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateShop(ShopModel shop, File? imageFile) async {
    try {
      String imageUrl = shop.imageUrl;

      if (imageFile != null) {
        final ref = _storage
            .ref()
            .child('shop_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final updatedShop = ShopModel(
        id: shop.id,
        ownerId: shop.ownerId,
        name: shop.name,
        description: shop.description,
        address: shop.address,
        latitude: shop.latitude,
        longitude: shop.longitude,
        imageUrl: imageUrl,
        totalSeats: shop.totalSeats,
        rating: shop.rating,
      );

      await _firestore.collection('shops').doc(shop.id).update(updatedShop.toMap());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteShop(String shopId) async {
    // Delete all related data
    final batch = _firestore.batch();

    // Delete seats
    final seats = await _firestore.collection('shops').doc(shopId).collection('seats').get();
    for (var doc in seats.docs) {
      batch.delete(doc.reference);
    }

    // Delete staff
    final staff = await _firestore.collection('shops').doc(shopId).collection('staff').get();
    for (var doc in staff.docs) {
      batch.delete(doc.reference);
    }

    // Delete bookings
    final bookings = await _firestore.collection('shops').doc(shopId).collection('bookings').get();
    for (var doc in bookings.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    await _firestore.collection('shops').doc(shopId).delete();
    notifyListeners();
  }

  Stream<List<ShopModel>> getShops() {
    return _firestore.collection('shops').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ShopModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<ShopModel>> getMyShops(String ownerId) {
    return _firestore
        .collection('shops')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShopModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<ShopModel?> getShopById(String shopId) async {
    final doc = await _firestore.collection('shops').doc(shopId).get();
    if (doc.exists) {
      return ShopModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SEAT MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> addSeat(SeatModel seat) async {
    final docRef = _firestore
        .collection('shops')
        .doc(seat.shopId)
        .collection('seats')
        .doc();

    final newSeat = SeatModel(
      id: docRef.id,
      shopId: seat.shopId,
      name: seat.name,
      description: seat.description,
      status: seat.status,
      type: seat.type,
      pricePerHour: seat.pricePerHour,
      seatNumber: seat.seatNumber,
      createdAt: DateTime.now(),
    );

    await docRef.set(newSeat.toMap());

    // Update total seats count
    await _updateSeatCount(seat.shopId);
    notifyListeners();
  }

  Future<void> updateSeat(SeatModel seat) async {
    await _firestore
        .collection('shops')
        .doc(seat.shopId)
        .collection('seats')
        .doc(seat.id)
        .update(seat.toMap());
    notifyListeners();
  }

  Future<void> deleteSeat(String shopId, String seatId) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('seats')
        .doc(seatId)
        .delete();

    await _updateSeatCount(shopId);
    notifyListeners();
  }

  Future<void> updateSeatStatus(String shopId, String seatId, SeatStatus status, {String? customerId}) async {
    final updates = <String, dynamic>{
      'status': status.name,
    };

    if (status == SeatStatus.occupied) {
      updates['currentCustomerId'] = customerId;
      updates['occupiedSince'] = Timestamp.now();
    } else if (status == SeatStatus.available) {
      updates['currentCustomerId'] = null;
      updates['occupiedSince'] = null;
    }

    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('seats')
        .doc(seatId)
        .update(updates);
    notifyListeners();
  }

  Stream<List<SeatModel>> getSeats(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('seats')
        .orderBy('seatNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SeatModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> _updateSeatCount(String shopId) async {
    final seats = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('seats')
        .get();

    await _firestore.collection('shops').doc(shopId).update({
      'totalSeats': seats.docs.length,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  STAFF MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> addStaff(StaffModel staff) async {
    final docRef = _firestore
        .collection('shops')
        .doc(staff.shopId)
        .collection('staff')
        .doc();

    final newStaff = StaffModel(
      id: docRef.id,
      shopId: staff.shopId,
      name: staff.name,
      phone: staff.phone,
      email: staff.email,
      role: staff.role,
      salary: staff.salary,
      isActive: true,
      joinedAt: DateTime.now(),
      imageUrl: staff.imageUrl,
    );

    await docRef.set(newStaff.toMap());
    notifyListeners();
  }

  Future<void> updateStaff(StaffModel staff) async {
    await _firestore
        .collection('shops')
        .doc(staff.shopId)
        .collection('staff')
        .doc(staff.id)
        .update(staff.toMap());
    notifyListeners();
  }

  Future<void> deleteStaff(String shopId, String staffId) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('staff')
        .doc(staffId)
        .delete();
    notifyListeners();
  }

  Future<void> toggleStaffStatus(String shopId, String staffId, bool isActive) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('staff')
        .doc(staffId)
        .update({'isActive': isActive});
    notifyListeners();
  }

  Stream<List<StaffModel>> getStaff(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('staff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StaffModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BOOKING MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> createBooking(BookingModel booking, {bool autoConfirm = false}) async {
    final docRef = _firestore
        .collection('shops')
        .doc(booking.shopId)
        .collection('bookings')
        .doc();

    final newBooking = BookingModel(
      id: docRef.id,
      shopId: booking.shopId,
      seatId: booking.seatId,
      customerId: booking.customerId,
      customerName: booking.customerName,
      customerPhone: booking.customerPhone,
      startTime: booking.startTime,
      endTime: booking.endTime,
      durationHours: booking.durationHours,
      totalAmount: booking.totalAmount,
      status: autoConfirm ? BookingStatus.confirmed : BookingStatus.pending,
      notes: booking.notes,
      createdAt: DateTime.now(),
    );

    await docRef.set(newBooking.toMap());

    // Update seat status to reserved for pending, occupied for confirmed
    await updateSeatStatus(
      booking.shopId,
      booking.seatId,
      autoConfirm ? SeatStatus.occupied : SeatStatus.reserved,
      customerId: booking.customerId,
    );

    notifyListeners();
  }

  // Approve a pending booking
  Future<void> approveBooking(String shopId, String bookingId, String seatId) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('bookings')
        .doc(bookingId)
        .update({
      'status': BookingStatus.confirmed.name,
    });

    // Update seat status to occupied
    await updateSeatStatus(shopId, seatId, SeatStatus.occupied);
    notifyListeners();
  }

  // Check and auto-approve a single pending booking if 30 minutes passed
  Future<bool> checkAndAutoApprove(BookingModel booking) async {
    if (booking.status != BookingStatus.pending) return false;

    final thirtyMinutesAgo = DateTime.now().subtract(const Duration(minutes: 30));
    if (booking.createdAt.isBefore(thirtyMinutesAgo)) {
      await approveBooking(booking.shopId, booking.id, booking.seatId);
      return true;
    }
    return false;
  }

  Future<void> updateBookingStatus(String shopId, String bookingId, BookingStatus status) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('bookings')
        .doc(bookingId)
        .update({
      'status': status.name,
      if (status == BookingStatus.completed) 'endTime': Timestamp.now(),
    });
    notifyListeners();
  }

  Future<void> completeBooking(String shopId, String bookingId, String seatId) async {
    await updateBookingStatus(shopId, bookingId, BookingStatus.completed);
    await updateSeatStatus(shopId, seatId, SeatStatus.available);
    notifyListeners();
  }

  Future<void> cancelBooking(String shopId, String bookingId, String seatId) async {
    await updateBookingStatus(shopId, bookingId, BookingStatus.cancelled);
    await updateSeatStatus(shopId, seatId, SeatStatus.available);
    notifyListeners();
  }

  Stream<List<BookingModel>> getBookings(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<BookingModel>> getTodayBookings(String shopId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('bookings')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<BookingModel>> getActiveBookings(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('bookings')
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get customer's bookings across all shops
  Future<List<Map<String, dynamic>>> getCustomerBookings(String customerId) async {
    final List<Map<String, dynamic>> allBookings = [];

    // Get all shops
    final shopsSnapshot = await _firestore.collection('shops').get();

    for (var shopDoc in shopsSnapshot.docs) {
      final shop = ShopModel.fromMap(shopDoc.data(), shopDoc.id);

      // Get bookings for this customer in this shop
      final bookingsSnapshot = await _firestore
          .collection('shops')
          .doc(shopDoc.id)
          .collection('bookings')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      for (var bookingDoc in bookingsSnapshot.docs) {
        final booking = BookingModel.fromMap(bookingDoc.data(), bookingDoc.id);
        allBookings.add({
          'booking': booking,
          'shop': shop,
        });
      }
    }

    // Sort by createdAt descending
    allBookings.sort((a, b) {
      final bookingA = a['booking'] as BookingModel;
      final bookingB = b['booking'] as BookingModel;
      return bookingB.createdAt.compareTo(bookingA.createdAt);
    });

    return allBookings;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  STATISTICS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getShopStats(String shopId) async {
    final seatsSnapshot = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('seats')
        .get();

    final staffSnapshot = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('staff')
        .where('isActive', isEqualTo: true)
        .get();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final todayBookingsSnapshot = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('bookings')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    int availableSeats = 0;
    int occupiedSeats = 0;

    for (var doc in seatsSnapshot.docs) {
      final status = doc.data()['status'] ?? 'available';
      if (status == 'available') {
        availableSeats++;
      } else if (status == 'occupied') {
        occupiedSeats++;
      }
    }

    double todayRevenue = 0;
    for (var doc in todayBookingsSnapshot.docs) {
      if (doc.data()['status'] == 'completed') {
        todayRevenue += (doc.data()['totalAmount'] ?? 0).toDouble();
      }
    }

    return {
      'totalSeats': seatsSnapshot.docs.length,
      'availableSeats': availableSeats,
      'occupiedSeats': occupiedSeats,
      'activeStaff': staffSnapshot.docs.length,
      'todayBookings': todayBookingsSnapshot.docs.length,
      'todayRevenue': todayRevenue,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SERVICE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> addService(ServiceModel service) async {
    final docRef = _firestore
        .collection('shops')
        .doc(service.shopId)
        .collection('services')
        .doc();

    final newService = ServiceModel(
      id: docRef.id,
      shopId: service.shopId,
      name: service.name,
      description: service.description,
      category: service.category,
      price: service.price,
      durationMinutes: service.durationMinutes,
      isActive: service.isActive,
      imageUrl: service.imageUrl,
      createdAt: DateTime.now(),
    );

    await docRef.set(newService.toMap());
    notifyListeners();
  }

  Future<void> updateService(ServiceModel service) async {
    await _firestore
        .collection('shops')
        .doc(service.shopId)
        .collection('services')
        .doc(service.id)
        .update(service.toMap());
    notifyListeners();
  }

  Future<void> deleteService(String shopId, String serviceId) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('services')
        .doc(serviceId)
        .delete();
    notifyListeners();
  }

  Future<void> toggleServiceStatus(String shopId, String serviceId, bool isActive) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('services')
        .doc(serviceId)
        .update({'isActive': isActive});
    notifyListeners();
  }

  Stream<List<ServiceModel>> getServices(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('services')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<ServiceModel>> getActiveServices(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('services')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add default services when creating a new shop
  Future<void> addDefaultServices(String shopId) async {
    final defaultServices = ServiceModel.getDefaultServices(shopId);

    for (var service in defaultServices) {
      await addService(service);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  NOTIFICATION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> sendNotification(NotificationModel notification) async {
    final docRef = _firestore
        .collection('shops')
        .doc(notification.shopId)
        .collection('notifications')
        .doc();

    final newNotification = NotificationModel(
      id: docRef.id,
      shopId: notification.shopId,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      isRead: false,
      bookingId: notification.bookingId,
      customerId: notification.customerId,
      customerName: notification.customerName,
      createdAt: DateTime.now(),
    );

    await docRef.set(newNotification.toMap());
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String shopId, String notificationId) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead(String shopId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
    notifyListeners();
  }

  Future<void> deleteNotification(String shopId, String notificationId) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
    notifyListeners();
  }

  Stream<List<NotificationModel>> getNotifications(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<int> getUnreadNotificationCount(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Send booking notification to shop
  Future<void> sendBookingNotification({
    required String shopId,
    required String bookingId,
    required String customerName,
    required String customerId,
    required DateTime bookingTime,
    required String seatName,
  }) async {
    final notification = NotificationModel(
      id: '',
      shopId: shopId,
      title: 'New Booking!',
      message: '$customerName booked $seatName for ${_formatDateTime(bookingTime)}',
      type: NotificationType.newBooking,
      bookingId: bookingId,
      customerId: customerId,
      customerName: customerName,
      createdAt: DateTime.now(),
    );

    await sendNotification(notification);
  }

  // Send cancellation notification to shop
  Future<void> sendCancellationNotification({
    required String shopId,
    required String bookingId,
    required String customerName,
    required String customerId,
  }) async {
    final notification = NotificationModel(
      id: '',
      shopId: shopId,
      title: 'Booking Cancelled',
      message: '$customerName cancelled their booking',
      type: NotificationType.bookingCancelled,
      bookingId: bookingId,
      customerId: customerId,
      customerName: customerName,
      createdAt: DateTime.now(),
    );

    await sendNotification(notification);
  }

  String _formatDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${months[dateTime.month - 1]} ${dateTime.day} at $hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CHAT MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  // Get or create a chat room between customer and shop
  Future<ChatRoom> getOrCreateChatRoom({
    required String shopId,
    required String shopName,
    required String customerId,
    required String customerName,
  }) async {
    // Check if chat room already exists
    final existingRoom = await _firestore
        .collection('chatRooms')
        .where('shopId', isEqualTo: shopId)
        .where('customerId', isEqualTo: customerId)
        .limit(1)
        .get();

    if (existingRoom.docs.isNotEmpty) {
      return ChatRoom.fromMap(existingRoom.docs.first.data(), existingRoom.docs.first.id);
    }

    // Create new chat room
    final docRef = _firestore.collection('chatRooms').doc();
    final newRoom = ChatRoom(
      id: docRef.id,
      shopId: shopId,
      shopName: shopName,
      customerId: customerId,
      customerName: customerName,
      createdAt: DateTime.now(),
    );

    await docRef.set(newRoom.toMap());
    return newRoom;
  }

  // Send a message
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String senderType,
    required String message,
  }) async {
    final docRef = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc();

    final newMessage = ChatMessage(
      id: docRef.id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      senderType: senderType,
      message: message,
      timestamp: DateTime.now(),
    );

    await docRef.set(newMessage.toMap());

    // Update chat room with last message
    final updateData = <String, dynamic>{
      'lastMessage': message,
      'lastMessageTime': Timestamp.now(),
      'lastSenderId': senderId,
    };

    // Increment unread count for the other party
    if (senderType == 'customer') {
      updateData['unreadCountShop'] = FieldValue.increment(1);
    } else {
      updateData['unreadCountCustomer'] = FieldValue.increment(1);
    }

    await _firestore.collection('chatRooms').doc(chatRoomId).update(updateData);
    notifyListeners();
  }

  // Get messages for a chat room
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get chat rooms for a shop
  Stream<List<ChatRoom>> getShopChatRooms(String shopId) {
    return _firestore
        .collection('chatRooms')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs
          .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
          .toList();
      // Sort by lastMessageTime descending (in memory to avoid index requirement)
      rooms.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
      return rooms;
    });
  }

  // Get chat rooms for a customer
  Stream<List<ChatRoom>> getCustomerChatRooms(String customerId) {
    return _firestore
        .collection('chatRooms')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs
          .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
          .toList();
      // Sort by lastMessageTime descending (in memory to avoid index requirement)
      rooms.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
      return rooms;
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId, String viewerType) async {
    // Reset unread count for the viewer
    final updateData = <String, dynamic>{};
    if (viewerType == 'shop') {
      updateData['unreadCountShop'] = 0;
    } else {
      updateData['unreadCountCustomer'] = 0;
    }

    await _firestore.collection('chatRooms').doc(chatRoomId).update(updateData);
    notifyListeners();
  }

  // Get total unread count for shop
  Stream<int> getShopUnreadChatCount(String shopId) {
    return _firestore
        .collection('chatRooms')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['unreadCountShop'] ?? 0) as int;
      }
      return total;
    });
  }

  // Get total unread count for customer
  Stream<int> getCustomerUnreadChatCount(String customerId) {
    return _firestore
        .collection('chatRooms')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['unreadCountCustomer'] ?? 0) as int;
      }
      return total;
    });
  }
}
