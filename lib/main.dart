import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:untitled1/helpers/shared_pref.dart';
import 'package:untitled1/provider/auth_provider.dart';
import 'package:untitled1/screens/auth/OTP.dart';
import 'package:untitled1/screens/auth/SignUpPage.dart';
import 'package:untitled1/screens/home_screen.dart';
import 'package:untitled1/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'helpers/api_handler.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Preferences.init();
    await ApiHandler.init();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red
      ),
      builder: FToastBuilder(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/otp': (context) => OTPPage(),
        '/home': (context) => const HomeScreen(isPhone: false),
      },
    );
  }
}
