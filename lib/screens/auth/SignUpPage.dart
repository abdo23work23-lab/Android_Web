import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool isPasswordVisible = false;
  bool isPasswordVisible2 = false;
  final _formKey = GlobalKey<FormState>();


  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image of Car
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/image5.png"), // Replace with your car background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Transparent Box with Input Fields and Sign up Button
          Center(
            child: Container(

              height: context.read<AppProvider>().isLoading? MediaQuery.of(context).size.height * .4:null,
              width: context.read<AppProvider>().isLoading? MediaQuery.of(context).size.width * .8:null,
              padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(80),
                    bottomLeft: Radius.circular(80),
                  ),
                ),
              child: Consumer<AppProvider>(
                builder: (context, authProvider, _) {
                  return authProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                          const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _image != null ? FileImage(_image!) : null,
                              child: _image == null
                                  ? const Icon(Icons.add_a_photo, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // First Name TextFormField
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
                                  return 'first name required';
                                }
                                return null;
                              },
                              controller: firstNameController,
                              decoration: const InputDecoration(
                                errorStyle: TextStyle(color: Colors.white),
                                hintText: "First Name",
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Last Name TextFormField
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
                                  return 'last name required';
                                }
                                return null;
                              },
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                errorStyle: TextStyle(color: Colors.white),

                                hintText: "Last Name",
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Email TextFormField
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
                          const SizedBox(height: 10),
                          // Password TextFormField
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
                              obscureText: !isPasswordVisible,
                              decoration:  InputDecoration(
                                errorStyle: TextStyle(color: Colors.white),

                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
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
                          // Confirm Password TextFormField
                          Container(
                            width: 320,
                            height: 50,
                            decoration: BoxDecoration(

                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return 'password does not match';
                                }
                                return null;
                              },
                              controller: confirmPasswordController,
                              obscureText: !isPasswordVisible2,
                              decoration:  InputDecoration(
                                errorStyle: TextStyle(color: Colors.white),

                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible2 ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible2 = !isPasswordVisible2;
                                    });
                                  },
                                ),
                                hintText: "Confirm Password",
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Phone Number TextFormField
                          Container(
                            width: 320,
                            height: 50,
                            decoration: BoxDecoration(

                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'phone number required';
                                }
                                return null;
                              },
                              controller: phoneController,
                              decoration: const InputDecoration(
                                errorStyle: TextStyle(color: Colors.white),

                                hintText: "Phone Number",
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Sign up Button
                                                Provider.of<AppProvider>(context, listen: false).isLoading?const Center(child: CircularProgressIndicator(color: Colors.red,)):
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                              Provider.of<AppProvider>(context, listen: false).signUp(
                                context,
                                emailController.text,
                                passwordController.text,
                                firstNameController.text,
                                lastNameController.text,
                                phoneController.text,
                                _image,
                              );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 35),
                              backgroundColor: Colors.red.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18.0, color: Colors.white),
                            ),
                          ),
                                              ],
                                            ),
                        ),
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
