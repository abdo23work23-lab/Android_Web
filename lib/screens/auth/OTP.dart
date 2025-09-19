import 'package:flutter/material.dart';
import 'package:untitled1/widgets/otp_widget.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';

class OTPPage extends StatefulWidget {
  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/image5.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              color: Colors.black.withOpacity(0.5), // Transparent black color
              child: Consumer<AppProvider>(
                builder: (context, authProvider, _) {
                  return  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Enter OTP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      OTPWidget(otpController: otpController),
                      const SizedBox(height: 20),
                      authProvider.isLoading?const Center(child: CircularProgressIndicator(color: Colors.red,)):
                      ElevatedButton(
                        onPressed: () {
                          authProvider.signInWithPhoneNumber(otpController.text, context);
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(200, 35),
                          backgroundColor: Colors.red.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Verify',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
