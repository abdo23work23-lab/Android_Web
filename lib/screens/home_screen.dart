import 'dart:ui' as ui;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled1/helpers/shared_pref.dart';
import 'package:untitled1/provider/auth_provider.dart';
import 'package:untitled1/screens/profile/profile_screen.dart';
import 'package:untitled1/screens/parking/user_screen.dart';
import 'package:untitled1/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key,required this.isPhone,this.newUser = false});
final bool isPhone;
final bool newUser;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  Location _location = Location();
  LatLng? _currentPosition;
  bool _isLoading = true;
 late BitmapDescriptor customIcon1;
 late BitmapDescriptor customIcon2;
 late BitmapDescriptor customIcon3;
  late AppProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AppProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadCustomIcons();
    _initializeLocation();
    authProvider.getUserData(isPhone: widget.isPhone).then((value) async{
    });
    });
  }

  ///handle states in app bar user image + handle loading in rest password

  void _loadCustomIcons() async {
    customIcon1 = await _resizeImageAsset('assets/icons/parking.png', 80);
    setState(() {});
  }

  Future<BitmapDescriptor> _resizeImageAsset(
      String assetPath, int width) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    ByteData? resizedData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(resizedData!.buffer.asUint8List());
  }

  Future<void> _initializeLocation() async {
    try {
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final locationData = await _location.getLocation();
      setState(() {
        _currentPosition =
            LatLng(locationData.latitude!, locationData.longitude!);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error getting location: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 14.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder:(context,provider,_)=> Scaffold(
        key: sKey,
        appBar: AppBar(
          title: const Center(child: Text('Parking App')),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              sKey.currentState!.openDrawer();
            },
          ),
          actions: [
            if (provider.userSnapshot != null || provider.phoneUser != null)
              CircleAvatar(
                backgroundImage: NetworkImage(!widget.isPhone ?provider.userSnapshot!['profile_pic']!:provider.phoneUser['profile_pic']!),
              ),
            const SizedBox(width: 10),
          ],
        ),
        drawer:  Drawer(
            child: Column(
              children: [
                provider.userSnapshot!=null || provider.phoneUser != null?
                UserAccountsDrawerHeader(
                  accountName: Text(widget.isPhone? provider.phoneUser['first_name']??'':provider.userSnapshot!['first_name'] ?? ''),
                  accountEmail:
                      Text(widget.isPhone? provider.phoneUser['email']??'':provider.userSnapshot!['email'] ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(
                        widget.isPhone? provider.phoneUser['profile_pic']??'https://via.placeholder.com/150':provider.userSnapshot!['profile_pic'] ?? 'https://via.placeholder.com/150'),
                  ),
                ):const Center(child: CircularProgressIndicator(color: Colors.red,)),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(isPhone: widget.isPhone,)));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    // Navigate to Settings screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut().then((value) {
                    Preferences.removeData(key: 'uid');
                    Preferences.removeData(key: 'phone');
                    Navigator.of(context).pushReplacementNamed('/login');
                      showToast(msg: 'Logout successful', color: Colors.black.withOpacity(.5));
                    });
                  },
                ),
              ],
            ),
          ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: _currentPosition ?? const LatLng(0, 0), zoom: 14.0),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: _onMapCreated,
                markers: _createMarkers(),
              ),
      ),
    );
  }

  Set<Marker> _createMarkers() {
    double lat = 24.046994;
    double lng = 32.881974;
    return {
      Marker(
        markerId: const MarkerId('marker_1'),
        position: LatLng(lat , lng ),
        infoWindow: const InfoWindow(
          title: 'Parking',
        ),
        icon: customIcon1,
        onTap: () => _onMarkerTapped('Marker 1'),
      ),
    };
  }

  void _onMarkerTapped(String markerId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheetContent(markerId: markerId);
      },
    );
  }
}

class BottomSheetContent extends StatelessWidget {
  final String markerId;

  BottomSheetContent({required this.markerId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'AAST Parking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const Text(" Parking location :\n Aga Al Karur, Sheyakhah Thaneyah, Aswan 1,\n Aswan Governorate", style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600),),
          const Text(" Parking price per hour \$ : Free", style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600),),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserScreen()));
                },
                child: const Text(
                  'View parking camera',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
