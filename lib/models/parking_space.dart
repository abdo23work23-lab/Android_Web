import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpace {
  final String id;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final int totalSpaces;
  final int availableSpaces;
  final double pricePerHour;
  final String ownerId;
  final List<String> features; // ['covered', 'security', 'electric_charging']
  final String status; // 'active', 'inactive', 'maintenance'
  final DateTime createdAt;
  final DateTime updatedAt;

  ParkingSpace({
    required this.id,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.totalSpaces,
    required this.availableSpaces,
    required this.pricePerHour,
    required this.ownerId,
    required this.features,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firestore document
  factory ParkingSpace.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ParkingSpace(
      id: doc.id,
      location: data['location'] ?? '',
      address: data['address'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      totalSpaces: data['total_spaces'] ?? 0,
      availableSpaces: data['available_spaces'] ?? 0,
      pricePerHour: data['price_per_hour']?.toDouble() ?? 0.0,
      ownerId: data['owner_id'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      status: data['status'] ?? 'active',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'total_spaces': totalSpaces,
      'available_spaces': availableSpaces,
      'price_per_hour': pricePerHour,
      'owner_id': ownerId,
      'features': features,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method for updating
  ParkingSpace copyWith({
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    int? totalSpaces,
    int? availableSpaces,
    double? pricePerHour,
    String? ownerId,
    List<String>? features,
    String? status,
    DateTime? updatedAt,
  }) {
    return ParkingSpace(
      id: id,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalSpaces: totalSpaces ?? this.totalSpaces,
      availableSpaces: availableSpaces ?? this.availableSpaces,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      ownerId: ownerId ?? this.ownerId,
      features: features ?? this.features,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}