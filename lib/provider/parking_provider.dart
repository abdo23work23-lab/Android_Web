import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/parking_space.dart';
import '../models/parking_reservation.dart';
import '../models/vehicle.dart';
import '../services/firebase_service.dart';

class ParkingProvider with ChangeNotifier {
  // Loading states
  bool _isLoading = false;
  bool _isLoadingSpaces = false;
  bool _isLoadingReservations = false;
  bool _isLoadingVehicles = false;

  // Data lists
  List<ParkingSpace> _parkingSpaces = [];
  List<ParkingReservation> _userReservations = [];
  List<Vehicle> _userVehicles = [];
  
  // Selected items
  ParkingSpace? _selectedParkingSpace;
  Vehicle? _selectedVehicle;
  
  // Location
  Position? _currentLocation;
  
  // Statistics
  Map<String, dynamic> _statistics = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingSpaces => _isLoadingSpaces;
  bool get isLoadingReservations => _isLoadingReservations;
  bool get isLoadingVehicles => _isLoadingVehicles;
  
  List<ParkingSpace> get parkingSpaces => _parkingSpaces;
  List<ParkingReservation> get userReservations => _userReservations;
  List<Vehicle> get userVehicles => _userVehicles;
  
  ParkingSpace? get selectedParkingSpace => _selectedParkingSpace;
  Vehicle? get selectedVehicle => _selectedVehicle;
  
  Position? get currentLocation => _currentLocation;
  Map<String, dynamic> get statistics => _statistics;

  // ================== LOCATION METHODS ==================

  /// Get current location
  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to get location: $e');
    }
  }

  // ================== PARKING SPACE METHODS ==================

  /// Load all parking spaces
  void loadParkingSpaces() {
    _isLoadingSpaces = true;
    notifyListeners();

    FirebaseService.getAllParkingSpaces().listen(
      (spaces) {
        _parkingSpaces = spaces;
        _isLoadingSpaces = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoadingSpaces = false;
        notifyListeners();
        throw Exception('Failed to load parking spaces: $error');
      },
    );
  }

  /// Load nearby parking spaces
  void loadNearbyParkingSpaces({double radiusKm = 5.0}) {
    if (_currentLocation == null) {
      throw Exception('Current location not available');
    }

    _isLoadingSpaces = true;
    notifyListeners();

    FirebaseService.getNearbyParkingSpaces(
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      radiusKm: radiusKm,
    ).listen(
      (spaces) {
        _parkingSpaces = spaces;
        _isLoadingSpaces = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoadingSpaces = false;
        notifyListeners();
        throw Exception('Failed to load nearby parking spaces: $error');
      },
    );
  }

  /// Select a parking space
  void selectParkingSpace(ParkingSpace space) {
    _selectedParkingSpace = space;
    notifyListeners();
  }

  /// Clear selected parking space
  void clearSelectedParkingSpace() {
    _selectedParkingSpace = null;
    notifyListeners();
  }

  /// Create a new parking space
  Future<String> createParkingSpace({
    required String location,
    required String address,
    required double latitude,
    required double longitude,
    required int totalSpaces,
    required double pricePerHour,
    required List<String> features,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String? currentUserId = FirebaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      ParkingSpace newSpace = ParkingSpace(
        id: '', // Will be set by Firestore
        location: location,
        address: address,
        latitude: latitude,
        longitude: longitude,
        totalSpaces: totalSpaces,
        availableSpaces: totalSpaces,
        pricePerHour: pricePerHour,
        ownerId: currentUserId,
        features: features,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      String spaceId = await FirebaseService.createParkingSpace(newSpace);
      
      _isLoading = false;
      notifyListeners();
      
      return spaceId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to create parking space: $e');
    }
  }

  // ================== RESERVATION METHODS ==================

  /// Load user reservations
  void loadUserReservations(String userId) {
    _isLoadingReservations = true;
    notifyListeners();

    FirebaseService.getUserReservations(userId).listen(
      (reservations) {
        _userReservations = reservations;
        _isLoadingReservations = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoadingReservations = false;
        notifyListeners();
        throw Exception('Failed to load reservations: $error');
      },
    );
  }

  /// Create a new reservation
  Future<String> createReservation({
    required String parkingSpaceId,
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalCost,
    required String paymentMethod,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String? currentUserId = FirebaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      ParkingReservation newReservation = ParkingReservation(
        id: '', // Will be set by Firestore
        userId: currentUserId,
        parkingSpaceId: parkingSpaceId,
        vehicleId: vehicleId,
        startTime: startTime,
        endTime: endTime,
        totalCost: totalCost,
        status: 'confirmed',
        paymentMethod: paymentMethod,
        paymentStatus: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      String reservationId = await FirebaseService.createReservation(newReservation);
      
      _isLoading = false;
      notifyListeners();
      
      return reservationId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to create reservation: $e');
    }
  }

  /// Cancel a reservation
  Future<void> cancelReservation(String reservationId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseService.cancelReservation(reservationId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  /// Update reservation status
  Future<void> updateReservationStatus(String reservationId, String status) async {
    try {
      await FirebaseService.updateReservationStatus(reservationId, status);
    } catch (e) {
      throw Exception('Failed to update reservation status: $e');
    }
  }

  // ================== VEHICLE METHODS ==================

  /// Load user vehicles
  void loadUserVehicles(String userId) {
    _isLoadingVehicles = true;
    notifyListeners();

    FirebaseService.getUserVehicles(userId).listen(
      (vehicles) {
        _userVehicles = vehicles;
        
        // Set default vehicle if none selected
        if (_selectedVehicle == null && vehicles.isNotEmpty) {
          _selectedVehicle = vehicles.firstWhere(
            (v) => v.isDefault,
            orElse: () => vehicles.first,
          );
        }
        
        _isLoadingVehicles = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoadingVehicles = false;
        notifyListeners();
        throw Exception('Failed to load vehicles: $error');
      },
    );
  }

  /// Add a new vehicle
  Future<String> addVehicle({
    required String plateNumber,
    required String brand,
    required String model,
    required String color,
    required String type,
    required int year,
    bool isDefault = false,
    String? imageUrl,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String? currentUserId = FirebaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      Vehicle newVehicle = Vehicle(
        id: '', // Will be set by Firestore
        userId: currentUserId,
        plateNumber: plateNumber,
        brand: brand,
        model: model,
        color: color,
        type: type,
        year: year,
        isDefault: isDefault,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      String vehicleId = await FirebaseService.addVehicle(newVehicle);
      
      if (isDefault) {
        await FirebaseService.setDefaultVehicle(currentUserId, vehicleId);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return vehicleId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to add vehicle: $e');
    }
  }

  /// Select a vehicle
  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  /// Set default vehicle
  Future<void> setDefaultVehicle(String vehicleId) async {
    try {
      String? currentUserId = FirebaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await FirebaseService.setDefaultVehicle(currentUserId, vehicleId);
      
      // Update local state
      for (var vehicle in _userVehicles) {
        if (vehicle.id == vehicleId) {
          _selectedVehicle = vehicle;
          break;
        }
      }
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to set default vehicle: $e');
    }
  }

  /// Delete a vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await FirebaseService.deleteVehicle(vehicleId);
      
      // Clear selected vehicle if it was deleted
      if (_selectedVehicle?.id == vehicleId) {
        _selectedVehicle = null;
      }
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  // ================== STATISTICS METHODS ==================

  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await FirebaseService.getStatistics();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load statistics: $e');
    }
  }

  // ================== UTILITY METHODS ==================

  /// Calculate cost for parking duration
  double calculateParkingCost(ParkingSpace space, DateTime startTime, DateTime endTime) {
    double hours = endTime.difference(startTime).inMinutes / 60.0;
    return hours * space.pricePerHour;
  }

  /// Get active reservations
  List<ParkingReservation> get activeReservations {
    return _userReservations.where((r) => r.isActive).toList();
  }

  /// Get upcoming reservations
  List<ParkingReservation> get upcomingReservations {
    final now = DateTime.now();
    return _userReservations
        .where((r) => r.startTime.isAfter(now) && r.status == 'confirmed')
        .toList();
  }

  /// Get past reservations
  List<ParkingReservation> get pastReservations {
    final now = DateTime.now();
    return _userReservations
        .where((r) => r.endTime.isBefore(now) || r.status == 'completed')
        .toList();
  }

  /// Clear all data
  void clearData() {
    _parkingSpaces.clear();
    _userReservations.clear();
    _userVehicles.clear();
    _selectedParkingSpace = null;
    _selectedVehicle = null;
    _currentLocation = null;
    _statistics.clear();
    notifyListeners();
  }
}