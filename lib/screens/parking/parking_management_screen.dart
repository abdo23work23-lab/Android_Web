import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/parking_provider.dart';
import '../../provider/auth_provider.dart';
import '../../models/parking_space.dart';
import '../../models/parking_reservation.dart';
import '../../models/vehicle.dart';

class ParkingManagementScreen extends StatefulWidget {
  @override
  _ParkingManagementScreenState createState() => _ParkingManagementScreenState();
}

class _ParkingManagementScreenState extends State<ParkingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    final parkingProvider = Provider.of<ParkingProvider>(context, listen: false);
    final authProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Load current location
    parkingProvider.getCurrentLocation().catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $error')),
      );
    });
    
    // Load parking spaces
    parkingProvider.loadParkingSpaces();
    
    // Load user data if authenticated
    if (authProvider.currentUser != null) {
      parkingProvider.loadUserReservations(authProvider.currentUser!.uid);
      parkingProvider.loadUserVehicles(authProvider.currentUser!.uid);
    }
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
        title: Text('Parking Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.local_parking), text: 'Spaces'),
            Tab(icon: Icon(Icons.book_online), text: 'Reservations'),
            Tab(icon: Icon(Icons.directions_car), text: 'Vehicles'),
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildParkingSpacesTab(),
          _buildReservationsTab(),
          _buildVehiclesTab(),
          _buildDashboardTab(),
        ],
      ),
    );
  }

  // ================== PARKING SPACES TAB ==================
  Widget _buildParkingSpacesTab() {
    return Consumer<ParkingProvider>(
      builder: (context, parkingProvider, child) {
        if (parkingProvider.isLoadingSpaces) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search parking spaces...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _showFilterDialog(),
                    icon: Icon(Icons.filter_list),
                  ),
                  IconButton(
                    onPressed: () => parkingProvider.loadNearbyParkingSpaces(),
                    icon: Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
            // Parking Spaces List
            Expanded(
              child: ListView.builder(
                itemCount: parkingProvider.parkingSpaces.length,
                itemBuilder: (context, index) {
                  ParkingSpace space = parkingProvider.parkingSpaces[index];
                  return _buildParkingSpaceCard(space);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParkingSpaceCard(ParkingSpace space) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: space.availableSpaces > 0 ? Colors.green : Colors.red,
          child: Text(
            '${space.availableSpaces}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          space.location,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(space.address),
            SizedBox(height: 4),
            Text('${space.pricePerHour} EGP/hour'),
            SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: space.features
                  .map((feature) => Chip(
                        label: Text(
                          feature,
                          style: TextStyle(fontSize: 10),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              space.availableSpaces > 0 ? Icons.check_circle : Icons.cancel,
              color: space.availableSpaces > 0 ? Colors.green : Colors.red,
            ),
            Text(
              '${space.availableSpaces}/${space.totalSpaces}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () => _showParkingSpaceDetails(space),
      ),
    );
  }

  // ================== RESERVATIONS TAB ==================
  Widget _buildReservationsTab() {
    return Consumer<ParkingProvider>(
      builder: (context, parkingProvider, child) {
        if (parkingProvider.isLoadingReservations) {
          return Center(child: CircularProgressIndicator());
        }

        List<ParkingReservation> reservations = parkingProvider.userReservations;
        
        if (reservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_online, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No reservations found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            ParkingReservation reservation = reservations[index];
            return _buildReservationCard(reservation);
          },
        );
      },
    );
  }

  Widget _buildReservationCard(ParkingReservation reservation) {
    Color statusColor = _getReservationStatusColor(reservation.status);
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            _getReservationStatusIcon(reservation.status),
            color: Colors.white,
          ),
        ),
        title: Text('Reservation #${reservation.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start: ${_formatDateTime(reservation.startTime)}'),
            Text('End: ${_formatDateTime(reservation.endTime)}'),
            Text('Cost: ${reservation.totalCost} EGP'),
            Text('Status: ${reservation.status.toUpperCase()}'),
          ],
        ),
        isThreeLine: true,
        trailing: reservation.status == 'confirmed' || reservation.status == 'pending'
            ? IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () => _cancelReservation(reservation),
              )
            : null,
        onTap: () => _showReservationDetails(reservation),
      ),
    );
  }

  // ================== VEHICLES TAB ==================
  Widget _buildVehiclesTab() {
    return Consumer<ParkingProvider>(
      builder: (context, parkingProvider, child) {
        if (parkingProvider.isLoadingVehicles) {
          return Center(child: CircularProgressIndicator());
        }

        List<Vehicle> vehicles = parkingProvider.userVehicles;

        return Column(
          children: [
            // Add Vehicle Button
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddVehicleDialog(),
                icon: Icon(Icons.add),
                label: Text('Add Vehicle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            // Vehicles List
            Expanded(
              child: vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No vehicles added',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        Vehicle vehicle = vehicles[index];
                        return _buildVehicleCard(vehicle);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: vehicle.isDefault ? Colors.blue : Colors.grey,
          child: Icon(
            Icons.directions_car,
            color: Colors.white,
          ),
        ),
        title: Text(
          vehicle.displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${vehicle.color} ${vehicle.type}'),
            Text('Year: ${vehicle.year}'),
            if (vehicle.isDefault)
              Text(
                'Default Vehicle',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!vehicle.isDefault)
              PopupMenuItem(
                value: 'default',
                child: Text('Set as Default'),
              ),
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) => _handleVehicleAction(vehicle, value.toString()),
        ),
        onTap: () => _showVehicleDetails(vehicle),
      ),
    );
  }

  // ================== DASHBOARD TAB ==================
  Widget _buildDashboardTab() {
    return Consumer<ParkingProvider>(
      builder: (context, parkingProvider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Active Reservations',
                      '${parkingProvider.activeReservations.length}',
                      Icons.book_online,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Vehicles',
                      '${parkingProvider.userVehicles.length}',
                      Icons.directions_car,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Available Spaces',
                      '${parkingProvider.parkingSpaces.fold(0, (sum, space) => sum + space.availableSpaces)}',
                      Icons.local_parking,
                      Colors.orange,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Upcoming',
                      '${parkingProvider.upcomingReservations.length}',
                      Icons.schedule,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickActionCard(
                    'Find Parking',
                    Icons.search,
                    Colors.blue,
                    () => _tabController.animateTo(0),
                  ),
                  _buildQuickActionCard(
                    'Book Now',
                    Icons.book_online,
                    Colors.green,
                    () => _showQuickBookDialog(),
                  ),
                  _buildQuickActionCard(
                    'Add Vehicle',
                    Icons.add_circle,
                    Colors.orange,
                    () => _showAddVehicleDialog(),
                  ),
                  _buildQuickActionCard(
                    'View History',
                    Icons.history,
                    Colors.purple,
                    () => _tabController.animateTo(1),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== HELPER METHODS ==================
  
  Color _getReservationStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getReservationStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'active':
        return Icons.play_circle;
      case 'completed':
        return Icons.check;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // ================== DIALOG METHODS ==================
  
  void _showFilterDialog() {
    // TODO: Implement filter dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filter dialog coming soon!')),
    );
  }

  void _showParkingSpaceDetails(ParkingSpace space) {
    // TODO: Implement parking space details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Parking space details for ${space.location}')),
    );
  }

  void _showReservationDetails(ParkingReservation reservation) {
    // TODO: Implement reservation details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reservation details for ${reservation.id}')),
    );
  }

  void _showVehicleDetails(Vehicle vehicle) {
    // TODO: Implement vehicle details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vehicle details for ${vehicle.displayName}')),
    );
  }

  void _showAddVehicleDialog() {
    // TODO: Implement add vehicle dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add vehicle dialog coming soon!')),
    );
  }

  void _showQuickBookDialog() {
    // TODO: Implement quick book dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quick book dialog coming soon!')),
    );
  }

  void _cancelReservation(ParkingReservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Reservation'),
        content: Text('Are you sure you want to cancel this reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<ParkingProvider>(context, listen: false)
                    .cancelReservation(reservation.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reservation cancelled successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to cancel reservation: $e')),
                );
              }
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _handleVehicleAction(Vehicle vehicle, String action) {
    final parkingProvider = Provider.of<ParkingProvider>(context, listen: false);
    
    switch (action) {
      case 'default':
        parkingProvider.setDefaultVehicle(vehicle.id).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to set default vehicle: $error')),
          );
        });
        break;
      case 'edit':
        // TODO: Implement edit vehicle
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit vehicle coming soon!')),
        );
        break;
      case 'delete':
        _confirmDeleteVehicle(vehicle);
        break;
    }
  }

  void _confirmDeleteVehicle(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<ParkingProvider>(context, listen: false)
                    .deleteVehicle(vehicle.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vehicle deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete vehicle: $e')),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}