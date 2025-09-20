import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingReservation {
  final String id;
  final String userId;
  final String parkingSpaceId;
  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalCost;
  final String status; // 'pending', 'confirmed', 'active', 'completed', 'cancelled'
  final String paymentMethod; // 'cash', 'card', 'digital_wallet'
  final String paymentStatus; // 'pending', 'paid', 'refunded'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalInfo;

  ParkingReservation({
    required this.id,
    required this.userId,
    required this.parkingSpaceId,
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    required this.totalCost,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.additionalInfo,
  });

  // Convert from Firestore document
  factory ParkingReservation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ParkingReservation(
      id: doc.id,
      userId: data['user_id'] ?? '',
      parkingSpaceId: data['parking_space_id'] ?? '',
      vehicleId: data['vehicle_id'] ?? '',
      startTime: (data['start_time'] as Timestamp).toDate(),
      endTime: (data['end_time'] as Timestamp).toDate(),
      totalCost: data['total_cost']?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
      paymentMethod: data['payment_method'] ?? 'cash',
      paymentStatus: data['payment_status'] ?? 'pending',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      additionalInfo: data['additional_info'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'parking_space_id': parkingSpaceId,
      'vehicle_id': vehicleId,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'total_cost': totalCost,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'additional_info': additionalInfo,
    };
  }

  // Calculate duration in hours
  double get durationInHours {
    return endTime.difference(startTime).inMinutes / 60.0;
  }

  // Check if reservation is active
  bool get isActive {
    final now = DateTime.now();
    return status == 'active' && 
           now.isAfter(startTime) && 
           now.isBefore(endTime);
  }

  // Copy with method for updating
  ParkingReservation copyWith({
    String? userId,
    String? parkingSpaceId,
    String? vehicleId,
    DateTime? startTime,
    DateTime? endTime,
    double? totalCost,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalInfo,
  }) {
    return ParkingReservation(
      id: id,
      userId: userId ?? this.userId,
      parkingSpaceId: parkingSpaceId ?? this.parkingSpaceId,
      vehicleId: vehicleId ?? this.vehicleId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}