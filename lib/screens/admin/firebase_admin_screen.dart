import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import '../../services/firebase_initializer.dart';
import '../../models/parking_space.dart';
import '../../models/parking_reservation.dart';
import '../../models/vehicle.dart';

class FirebaseAdminScreen extends StatefulWidget {
  const FirebaseAdminScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseAdminScreen> createState() => _FirebaseAdminScreenState();
}

class _FirebaseAdminScreenState extends State<FirebaseAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Admin Panel'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.local_parking), text: 'Parking'),
            Tab(icon: Icon(Icons.book_online), text: 'Reservations'),
            Tab(icon: Icon(Icons.directions_car), text: 'Vehicles'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildParkingSpacesTab(),
          _buildReservationsTab(),
          _buildVehiclesTab(),
          _buildUsersTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildParkingSpacesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('parking_spaces').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(data['name'] ?? 'Unknown'),
                subtitle: Text('Available: ${data['available_spaces']}/${data['total_spaces']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editParkingSpace(doc.id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteParkingSpace(doc.id),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${data['description'] ?? 'N/A'}'),
                        Text('Location: ${data['latitude']}, ${data['longitude']}'),
                        Text('Price: \$${data['price_per_hour']}/hour'),
                        Text('Status: ${data['status']}'),
                        Text('Amenities: ${(data['amenities'] as List?)?.join(', ') ?? 'None'}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReservationsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('reservations').orderBy('created_at', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Reservation ${doc.id.substring(0, 8)}...'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User: ${data['user_id'] ?? 'Unknown'}'),
                    Text('Space: ${data['parking_space_id'] ?? 'Unknown'}'),
                    Text('Status: ${data['status'] ?? 'Unknown'}'),
                    Text('Total: \$${data['total_amount'] ?? 0}'),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'confirm', child: Text('Confirm')),
                    const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                    const PopupMenuItem(value: 'complete', child: Text('Complete')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (value) => _handleReservationAction(doc.id, value),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVehiclesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('vehicles').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('${data['make']} ${data['model']} (${data['year']})'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('License: ${data['license_plate']}'),
                    Text('Owner: ${data['user_id']}'),
                    Text('Color: ${data['color']}'),
                    if (data['is_default'] == true) const Text('Default Vehicle', style: TextStyle(color: Colors.green)),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteVehicle(doc.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(data['name'] ?? 'Unknown User'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${data['email'] ?? 'N/A'}'),
                    Text('Phone: ${data['phone'] ?? 'N/A'}'),
                    Text('ID: ${doc.id}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.person_remove, color: Colors.red),
                  onPressed: () => _deleteUser(doc.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Firebase Analytics Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await FirebaseInitializer.initializeDatabase();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database initialized with sample data')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Initialize Sample Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    final tabIndex = _tabController.index;
    switch (tabIndex) {
      case 0:
        _showAddParkingSpaceDialog();
        break;
      case 2:
        _showAddVehicleDialog();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add functionality not available for this tab')),
        );
    }
  }

  void _showAddParkingSpaceDialog() {
    // Implementation for adding parking space
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Parking Space'),
        content: const Text('Parking space creation dialog would be implemented here'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Add')),
        ],
      ),
    );
  }

  void _showAddVehicleDialog() {
    // Implementation for adding vehicle
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Vehicle'),
        content: const Text('Vehicle creation dialog would be implemented here'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Add')),
        ],
      ),
    );
  }

  void _editParkingSpace(String docId, Map<String, dynamic> data) {
    // Implementation for editing parking space
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit parking space: $docId')),
    );
  }

  void _deleteParkingSpace(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Parking Space'),
        content: const Text('Are you sure you want to delete this parking space?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('parking_spaces').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking space deleted')),
      );
    }
  }

  void _handleReservationAction(String docId, String action) async {
    switch (action) {
      case 'confirm':
        await _firestore.collection('reservations').doc(docId).update({'status': 'confirmed'});
        break;
      case 'cancel':
        await _firestore.collection('reservations').doc(docId).update({'status': 'cancelled'});
        break;
      case 'complete':
        await _firestore.collection('reservations').doc(docId).update({'status': 'completed'});
        break;
      case 'delete':
        await _firestore.collection('reservations').doc(docId).delete();
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reservation $action')),
    );
  }

  void _deleteVehicle(String docId) async {
    await _firestore.collection('vehicles').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle deleted')),
    );
  }

  void _deleteUser(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('users').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted')),
      );
    }
  }
}