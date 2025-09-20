import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Initialize Firebase collections with sample data for testing
  static Future<void> initializeDatabase() async {
    try {
      print('Starting Firebase database initialization...');
      
      // Create sample parking spaces
      await _createSampleParkingSpaces();
      
      // Set up Firestore security rules (this would typically be done in Firebase Console)
      await _setupFirestoreIndexes();
      
      print('Firebase database initialization completed successfully!');
    } catch (e) {
      print('Error initializing Firebase database: $e');
      throw Exception('Failed to initialize Firebase database: $e');
    }
  }

  /// Create sample parking spaces for testing
  static Future<void> _createSampleParkingSpaces() async {
    try {
      // Sample parking spaces data
      List<Map<String, dynamic>> sampleSpaces = [
        {
          'location': 'AAST Main Campus',
          'address': 'Arab Academy for Science, Technology & Maritime Transport, Miami, Alex-Cairo Desert Rd',
          'latitude': 31.2090,
          'longitude': 29.9187,
          'total_spaces': 50,
          'available_spaces': 45,
          'price_per_hour': 5.0,
          'owner_id': 'system',
          'features': ['covered', 'security', 'cctv'],
          'status': 'active',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'location': 'Alexandria Library',
          'address': 'Bibliotheca Alexandrina, As Shatby, Alexandria Governorate',
          'latitude': 31.2084,
          'longitude': 29.9094,
          'total_spaces': 30,
          'available_spaces': 25,
          'price_per_hour': 8.0,
          'owner_id': 'system',
          'features': ['covered', 'security', 'electric_charging'],
          'status': 'active',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'location': 'City Center Alexandria',
          'address': 'City Centre Alexandria, Alexandria Governorate',
          'latitude': 31.2156,
          'longitude': 29.9553,
          'total_spaces': 200,
          'available_spaces': 180,
          'price_per_hour': 10.0,
          'owner_id': 'system',
          'features': ['covered', 'security', 'valet_service'],
          'status': 'active',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'location': 'Montaza Palace',
          'address': 'Montaza Palace, Montaza, Alexandria Governorate',
          'latitude': 31.2905,
          'longitude': 30.0144,
          'total_spaces': 100,
          'available_spaces': 85,
          'price_per_hour': 6.0,
          'owner_id': 'system',
          'features': ['outdoor', 'security'],
          'status': 'active',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'location': 'Alexandria Port',
          'address': 'Alexandria Port, Alexandria Governorate',
          'latitude': 31.2001,
          'longitude': 29.8869,
          'total_spaces': 75,
          'available_spaces': 60,
          'price_per_hour': 12.0,
          'owner_id': 'system',
          'features': ['covered', 'security', 'premium'],
          'status': 'active',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
      ];

      // Check if parking spaces already exist
      QuerySnapshot existingSpaces = await _firestore
          .collection('parking_spaces')
          .where('owner_id', isEqualTo: 'system')
          .get();

      if (existingSpaces.docs.isEmpty) {
        print('Creating sample parking spaces...');
        
        WriteBatch batch = _firestore.batch();
        
        for (Map<String, dynamic> spaceData in sampleSpaces) {
          DocumentReference docRef = _firestore.collection('parking_spaces').doc();
          batch.set(docRef, spaceData);
        }
        
        await batch.commit();
        print('Sample parking spaces created successfully!');
      } else {
        print('Sample parking spaces already exist, skipping creation.');
      }
    } catch (e) {
      print('Error creating sample parking spaces: $e');
      throw e;
    }
  }

  /// Set up Firestore composite indexes (these need to be created in Firebase Console)
  static Future<void> _setupFirestoreIndexes() async {
    print('''
IMPORTANT: Please create the following composite indexes in Firebase Console:

Collection: parking_spaces
Fields: status (Ascending), latitude (Ascending), longitude (Ascending)

Collection: reservations  
Fields: user_id (Ascending), created_at (Descending)
Fields: user_id (Ascending), status (Ascending), start_time (Ascending)

Collection: vehicles
Fields: user_id (Ascending), is_default (Descending), created_at (Descending)

Collection: camera_streams
Fields: timestamp (Descending)

To create these indexes:
1. Go to Firebase Console > Firestore Database > Indexes
2. Click "Add Index" and add each field combination above
3. Wait for indexes to build (usually takes a few minutes)
    ''');
  }

  /// Create sample user profile for testing (call this after user registration)
  static Future<void> createSampleUserData(String userId) async {
    try {
      // Create sample vehicles for the user
      List<Map<String, dynamic>> sampleVehicles = [
        {
          'user_id': userId,
          'plate_number': 'ABC123',
          'brand': 'Toyota',
          'model': 'Camry',
          'color': 'White',
          'type': 'car',
          'year': 2020,
          'is_default': true,
          'image_url': null,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'user_id': userId,
          'plate_number': 'XYZ789',
          'brand': 'Honda',
          'model': 'Civic',
          'color': 'Black',
          'type': 'car',
          'year': 2019,
          'is_default': false,
          'image_url': null,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
      ];

      // Check if user vehicles already exist
      QuerySnapshot existingVehicles = await _firestore
          .collection('vehicles')
          .where('user_id', isEqualTo: userId)
          .get();

      if (existingVehicles.docs.isEmpty) {
        print('Creating sample vehicles for user...');
        
        WriteBatch batch = _firestore.batch();
        
        for (Map<String, dynamic> vehicleData in sampleVehicles) {
          DocumentReference docRef = _firestore.collection('vehicles').doc();
          batch.set(docRef, vehicleData);
        }
        
        await batch.commit();
        print('Sample vehicles created successfully!');
      }
    } catch (e) {
      print('Error creating sample user data: $e');
    }
  }

  /// Verify Firebase setup
  static Future<bool> verifyFirebaseSetup() async {
    try {
      print('Verifying Firebase setup...');
      
      // Test Firestore connection
      await _firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected'
      });
      
      // Test Authentication
      User? currentUser = _auth.currentUser;
      print('Current user: ${currentUser?.email ?? 'Not authenticated'}');
      
      // Test Storage
      try {
        ListResult storageList = await _storage.ref().listAll();
        print('Storage connection successful');
      } catch (e) {
        print('Storage connection test failed: $e');
      }
      
      // Clean up test document
      await _firestore.collection('test').doc('connection').delete();
      
      print('Firebase setup verification completed successfully!');
      return true;
    } catch (e) {
      print('Firebase setup verification failed: $e');
      return false;
    }
  }

  /// Get Firebase project information
  static Future<Map<String, String>> getProjectInfo() async {
    try {
      Map<String, String> info = {
        'project_id': 'parking-7f439',
        'auth_domain': 'parking-7f439.firebaseapp.com',
        'storage_bucket': 'parking-7f439.appspot.com',
        'web_app_id': '1:22459400961:web:d4407d352766069eb11100',
        'android_app_id': '1:22459400961:android:550c14c5aeed1c20b11100',
        'ios_app_id': '1:22459400961:ios:0d2babd6c1c4eccdb11100',
      };
      
      return info;
    } catch (e) {
      print('Error getting project info: $e');
      return {};
    }
  }

  /// Reset database (DANGER: This will delete all data!)
  static Future<void> resetDatabase() async {
    print('WARNING: This will delete all data from the database!');
    print('This operation cannot be undone.');
    
    try {
      // Delete all collections (be very careful with this!)
      List<String> collections = [
        'parking_spaces',
        'reservations', 
        'vehicles',
        'camera_streams'
      ];
      
      for (String collectionName in collections) {
        QuerySnapshot snapshot = await _firestore.collection(collectionName).get();
        WriteBatch batch = _firestore.batch();
        
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
        print('Deleted all documents from $collectionName');
      }
      
      print('Database reset completed!');
    } catch (e) {
      print('Error resetting database: $e');
      throw e;
    }
  }
}