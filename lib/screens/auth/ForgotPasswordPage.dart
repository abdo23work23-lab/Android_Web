import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, authProvider, _) => Scaffold(
        body: Stack(
          children: [
            // Background Image of Car
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
            // Transparent Box with Forgot Password Fields and Buttons
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width*.9,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(80),
                    bottomLeft: Radius.circular(80),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Forgot Password",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email TextField
                    Container(
                      width: 320, // Adjust width to enlarge the box
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                            0.3), // Transparent black color for text field
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Send Button
                    !authProvider.isLoading
                        ? ElevatedButton(
                            onPressed: () {
                              authProvider
                                  .resetPassword(emailController.text)
                                  .then((value) {
                                Navigator.pop(context);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(230, 35),
                              backgroundColor: Colors.red
                                  .withOpacity(0.8), // Adjust opacity here
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Send',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.white),
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                            color: Colors.red,
                          )),
                    const SizedBox(height: 20),
                    // Back to Login Button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Back to Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
