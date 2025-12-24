// import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final double rating;
  final int totalSeats;

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.rating = 0.0,
    this.totalSeats = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalSeats': totalSeats,
    };
  }

  factory ShopModel.fromMap(Map<String, dynamic> map, String docId) {
    return ShopModel(
      id: docId,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? 'Unnamed Shop',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalSeats: map['totalSeats'] ?? 0,
    );
  }
}
