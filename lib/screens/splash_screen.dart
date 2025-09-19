import 'package:flutter/material.dart';
import 'package:untitled1/screens/home_screen.dart';
import 'package:untitled1/screens/parking/camera_screen.dart';
import 'dart:async';

import '../helpers/shared_pref.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});


  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  bool cameraBool = false;


  @override
  void initState() {
String? uId = Preferences.getData(key: 'uid');
    super.initState();
      bool isPhone = Preferences.getData(key: 'phone') != null;
    Timer(const Duration(seconds: 2), () {
      if(cameraBool){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CameraScreen()),
        );
      }else {
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => uId != null ? HomeScreen(isPhone: isPhone,): LoginPage()),
      );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircleAvatar(
          radius: 120,
          backgroundImage: AssetImage("assets/images/icon.png"), // Replace with your splash image
        ),
        ),
    );
  }
}
