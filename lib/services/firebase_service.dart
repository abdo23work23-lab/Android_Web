import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math' as math;
import '../models/parking_space.dart';
import '../models/parking_reservation.dart';
import '../models/vehicle.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _parkingSpacesCollection = 'parking_spaces';
  static const String _reservationsCollection = 'reservations';
  static const String _vehiclesCollection = 'vehicles';
  static const String _cameraStreamsCollection = 'camera_streams';

  // Current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // ================== PARKING SPACES ==================

  /// Create a new parking space
  static Future<String> createParkingSpace(ParkingSpace parkingSpace) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_parkingSpacesCollection)
          .add(parkingSpace.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create parking space: $e');
    }
  }

  /// Get all parking spaces
  static Stream<List<ParkingSpace>> getAllParkingSpaces() {
    return _firestore
        .collection(_parkingSpacesCollection)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParkingSpace.fromFirestore(doc))
            .toList());
  }

  /// Get parking spaces near a location
  static Stream<List<ParkingSpace>> getNearbyParkingSpaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) {
    // Note: For production, consider using GeoFlutterFire for proper geospatial queries
    return _firestore
        .collection(_parkingSpacesCollection)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ParkingSpace.fromFirestore(doc))
          .where((space) {
        // Simple distance calculation (for demo purposes)
        double distance = _calculateDistance(
          latitude, longitude, space.latitude, space.longitude);
        return distance <= radiusKm;
      }).toList();
    });
  }

  /// Update parking space availability
  static Future<void> updateParkingSpaceAvailability(
      String spaceId, int availableSpaces) async {
    try {
      await _firestore.collection(_parkingSpacesCollection).doc(spaceId).update({
        'available_spaces': availableSpaces,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update parking space availability: $e');
    }
  }

  /// Get parking space by ID
  static Future<ParkingSpace?> getParkingSpaceById(String spaceId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_parkingSpacesCollection)
          .doc(spaceId)
          .get();
      
      if (doc.exists) {
        return ParkingSpace.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get parking space: $e');
    }
  }

  // ================== RESERVATIONS ==================

  /// Create a new reservation
  static Future<String> createReservation(ParkingReservation reservation) async {
    try {
      // Start a transaction to ensure data consistency
      return await _firestore.runTransaction<String>((transaction) async {
        // Get the parking space
        DocumentSnapshot spaceDoc = await transaction.get(
          _firestore.collection(_parkingSpacesCollection).doc(reservation.parkingSpaceId)
        );
        
        if (!spaceDoc.exists) {
          throw Exception('Parking space not found');
        }
        
        ParkingSpace space = ParkingSpace.fromFirestore(spaceDoc);
        
        if (space.availableSpaces <= 0) {
          throw Exception('No available spaces');
        }
        
        // Create reservation
        DocumentReference reservationRef = _firestore
            .collection(_reservationsCollection)
            .doc();
        
        transaction.set(reservationRef, reservation.toFirestore());
        
        // Update available spaces
        transaction.update(spaceDoc.reference, {
          'available_spaces': space.availableSpaces - 1,
          'updated_at': FieldValue.serverTimestamp(),
        });
        
        return reservationRef.id;
      });
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  /// Get user reservations
  static Stream<List<ParkingReservation>> getUserReservations(String userId) {
    return _firestore
        .collection(_reservationsCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParkingReservation.fromFirestore(doc))
            .toList());
  }

  /// Update reservation status
  static Future<void> updateReservationStatus(
      String reservationId, String status) async {
    try {
      await _firestore.collection(_reservationsCollection).doc(reservationId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update reservation status: $e');
    }
  }

  /// Cancel reservation
  static Future<void> cancelReservation(String reservationId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get reservation
        DocumentSnapshot reservationDoc = await transaction.get(
          _firestore.collection(_reservationsCollection).doc(reservationId)
        );
        
        if (!reservationDoc.exists) {
          throw Exception('Reservation not found');
        }
        
        ParkingReservation reservation = ParkingReservation.fromFirestore(reservationDoc);
        
        // Update reservation status
        transaction.update(reservationDoc.reference, {
          'status': 'cancelled',
          'updated_at': FieldValue.serverTimestamp(),
        });
        
        // Restore available space
        DocumentReference spaceRef = _firestore
            .collection(_parkingSpacesCollection)
            .doc(reservation.parkingSpaceId);
            
        DocumentSnapshot spaceDoc = await transaction.get(spaceRef);
        if (spaceDoc.exists) {
          ParkingSpace space = ParkingSpace.fromFirestore(spaceDoc);
          transaction.update(spaceRef, {
            'available_spaces': space.availableSpaces + 1,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  // ================== VEHICLES ==================

  /// Add a new vehicle
  static Future<String> addVehicle(Vehicle vehicle) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_vehiclesCollection)
          .add(vehicle.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  /// Get user vehicles
  static Stream<List<Vehicle>> getUserVehicles(String userId) {
    return _firestore
        .collection(_vehiclesCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('is_default', descending: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vehicle.fromFirestore(doc))
            .toList());
  }

  /// Update vehicle
  static Future<void> updateVehicle(String vehicleId, Vehicle vehicle) async {
    try {
      await _firestore.collection(_vehiclesCollection).doc(vehicleId).update(
        vehicle.toFirestore()
      );
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  /// Delete vehicle
  static Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _firestore.collection(_vehiclesCollection).doc(vehicleId).delete();
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  /// Set default vehicle
  static Future<void> setDefaultVehicle(String userId, String vehicleId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Remove default from all user vehicles
        QuerySnapshot userVehicles = await _firestore
            .collection(_vehiclesCollection)
            .where('user_id', isEqualTo: userId)
            .get();
            
        for (QueryDocumentSnapshot doc in userVehicles.docs) {
          transaction.update(doc.reference, {'is_default': false});
        }
        
        // Set new default
        DocumentReference vehicleRef = _firestore
            .collection(_vehiclesCollection)
            .doc(vehicleId);
        transaction.update(vehicleRef, {'is_default': true});
      });
    } catch (e) {
      throw Exception('Failed to set default vehicle: $e');
    }
  }

  // ================== CAMERA STREAMS ==================

  /// Save camera image to Firebase Storage and Firestore
  static Future<String> saveCameraImage(File imageFile) async {
    try {
      String fileName = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child('camera_streams/$fileName');
      
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Save to Firestore
      await _firestore.collection(_cameraStreamsCollection).add({
        'url': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to save camera image: $e');
    }
  }

  /// Get latest camera streams
  static Stream<QuerySnapshot> getCameraStreams() {
    return _firestore
        .collection(_cameraStreamsCollection)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }

  // ================== UTILITIES ==================

  /// Calculate distance between two coordinates (Haversine formula)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Get statistics for admin dashboard
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      // Get total parking spaces
      QuerySnapshot spacesSnapshot = await _firestore
          .collection(_parkingSpacesCollection)
          .where('status', isEqualTo: 'active')
          .get();
      
      // Get active reservations
      QuerySnapshot activeReservationsSnapshot = await _firestore
          .collection(_reservationsCollection)
          .where('status', isEqualTo: 'active')
          .get();
      
      // Get total users
      QuerySnapshot usersSnapshot = await _firestore
          .collection(_usersCollection)
          .get();
      
      // Get today's reservations
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));
      
      QuerySnapshot todayReservationsSnapshot = await _firestore
          .collection(_reservationsCollection)
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('created_at', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
      
      return {
        'total_parking_spaces': spacesSnapshot.docs.length,
        'active_reservations': activeReservationsSnapshot.docs.length,
        'total_users': usersSnapshot.docs.length,
        'today_reservations': todayReservationsSnapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}