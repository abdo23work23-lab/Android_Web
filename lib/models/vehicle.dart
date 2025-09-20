import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String userId;
  final String plateNumber;
  final String brand;
  final String model;
  final String color;
  final String type; // 'car', 'motorcycle', 'truck', 'van'
  final int year;
  final bool isDefault;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.userId,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.color,
    required this.type,
    required this.year,
    required this.isDefault,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firestore document
  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      userId: data['user_id'] ?? '',
      plateNumber: data['plate_number'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      color: data['color'] ?? '',
      type: data['type'] ?? 'car',
      year: data['year'] ?? 2020,
      isDefault: data['is_default'] ?? false,
      imageUrl: data['image_url'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'plate_number': plateNumber,
      'brand': brand,
      'model': model,
      'color': color,
      'type': type,
      'year': year,
      'is_default': isDefault,
      'image_url': imageUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Get display name
  String get displayName => '$brand $model ($plateNumber)';

  // Copy with method for updating
  Vehicle copyWith({
    String? userId,
    String? plateNumber,
    String? brand,
    String? model,
    String? color,
    String? type,
    int? year,
    bool? isDefault,
    String? imageUrl,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id,
      userId: userId ?? this.userId,
      plateNumber: plateNumber ?? this.plateNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      type: type ?? this.type,
      year: year ?? this.year,
      isDefault: isDefault ?? this.isDefault,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}