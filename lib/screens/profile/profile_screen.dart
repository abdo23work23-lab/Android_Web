import 'package:flutter/material.dart';
import 'package:untitled1/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.isPhone});

  final bool isPhone;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _image;
  late AppProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AppProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      authProvider.getUserData(isPhone: true).then((_) {
          if (!widget.isPhone) {
            _firstNameController.text =
                authProvider.userSnapshot!['first_name'];
            _lastNameController.text = authProvider.userSnapshot!['last_name'];
            _phoneController.text = authProvider.userSnapshot!['phone_number'];
          } else {
            _firstNameController.text = authProvider.phoneUser!['first_name'];
            _lastNameController.text = authProvider.phoneUser!['last_name'];
            _phoneController.text = authProvider.phoneUser!['phone_number'];
          }
      });
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, authProvider, _) {
          return  authProvider.phoneUser == null && authProvider.userSnapshot == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(widget.isPhone?authProvider.phoneUser['profile_pic']:
                                authProvider.userSnapshot!['profile_pic']),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _firstNameController,
                          decoration: InputDecoration(labelText: 'First Name'),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _lastNameController,
                          decoration: InputDecoration(labelText: 'Last Name'),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
                        ),
                        const SizedBox(height: 50),
                        authProvider.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                color: Colors.red,
                              ))
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(250, 35),
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  String? profilePicUrl;
                                  if (_image != null) {
                                    profilePicUrl = await authProvider
                                        .uploadProfilePicture(_image!);
                                  }
                                  await authProvider
                                      .updateUserData(
                                    phoneLogin: widget.isPhone,
                                    firstName: _firstNameController.text,
                                    lastName: _lastNameController.text,
                                    phoneNumber: _phoneController.text,
                                    profilePicUrl: profilePicUrl,
                                  )
                                      .then((value) {
                                    showToast(
                                        msg: 'Updated Successfully',
                                        color: Colors.green);
                                  });
                                },
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
