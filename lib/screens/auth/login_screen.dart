

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/provider/auth_provider.dart';
import 'package:untitled1/screens/auth/ForgotPasswordPage.dart';
import 'package:untitled1/screens/auth/SignUpPage.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
              height: context.read<AppProvider>().isLoading
                  ? MediaQuery.of(context).size.height * .45
                  : null,
              width: context.read<AppProvider>().isLoading
                  ? MediaQuery.of(context).size.width * .8
                  : null,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(60),
                  bottomLeft: Radius.circular(60),
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Consumer<AppProvider>(
                builder: (context, authProvider, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: authProvider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : authProvider.isPhoneLogin
                            ? buildPhoneLogin(context, authProvider)
                            : buildEmailLogin(context, authProvider),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage()),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmailLogin(BuildContext screenCtx, AppProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('emailLogin'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Welcome Parking Area",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 320,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'email required';
                }
                return null;
              },
              controller: emailController,
              decoration: const InputDecoration(
                errorStyle: TextStyle(color: Colors.white),

                hintText: "Email",
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 320,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'password required';
                }
                return null;
              },
              controller: passwordController,
              obscureText: !authProvider.isPasswordVisible,
              decoration: InputDecoration(
                errorStyle: const TextStyle(color: Colors.white),

                suffixIcon: IconButton(
                  // Add this IconButton
                  icon: Icon(
                    authProvider.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    authProvider.toggle();
                  },
                ),
                hintText: "Password",
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                authProvider.signInWithEmailAndPassword(
                  screenCtx,
                  emailController.text,
                  passwordController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(250, 35),
              backgroundColor: Colors.red.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => authProvider.toggleLoginMethod(),
            child: const Text(
              "Login with Phone",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                screenCtx,
                MaterialPageRoute(builder: (context) => SignUpPage()),
              );
            },
            child: const Text(
              "Don't have an account? Sign Up now",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPhoneLogin(BuildContext context, AppProvider authProvider) {
    return Column(
      key: const ValueKey('phoneLogin'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Welcome Parking Area",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 320,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              hintText: "Phone Number",
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            authProvider.verifyPhoneNumber(phoneController.text, context,false);
          },
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(250, 35),
            backgroundColor: Colors.red.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Verify Phone Number',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => authProvider.toggleLoginMethod(),
          child: const Text(
            "Login with Email",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
