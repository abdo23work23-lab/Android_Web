import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:untitled1/helpers/shared_pref.dart';
import 'package:untitled1/screens/home_screen.dart';
import 'package:untitled1/widgets/widgets.dart';

import '../screens/auth/OTP.dart';

class AppProvider with ChangeNotifier {
  bool isPhoneLogin = false;
  bool isLoading = false;
  String verificationId = '';
  bool otpSent = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isPasswordVisible = false;


  toggle(){
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;
  Map<String, dynamic>? userSnapshot;
  var phoneUser;

  Future<void> getUserData({bool isPhone = false}) async {
    if (currentUser != null) {
      if (isPhone) {
        await _firestore
            .collection('users')
            .where('phone_number', isEqualTo: Preferences.getData(key: 'phone'))
            .get()
            .then((value) {
          phoneUser = value.docs.first;
        });
      } else {
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .get()
            .then((value) {
          userSnapshot = value.data();
        });
      }
      notifyListeners();
    }
  }

  void toggleLoginMethod() {
    isPhoneLogin = !isPhoneLogin;
    notifyListeners();
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber, BuildContext context, bool newUser) async {
    isLoading = true;
    notifyListeners();
    checkPhoneNumberExists(phoneNumber).then((value) async {
      if (value) {
        Preferences.saveData(key: 'phone', value: phoneNumber);
        await _auth.verifyPhoneNumber(
          phoneNumber: '+2$phoneNumber',
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.currentUser?.linkWithCredential(credential);
            isLoading = false;
            notifyListeners();
            await getUserData(isPhone: true);
            Get.offAll(() =>  HomeScreen(
              isPhone: true,
              newUser: newUser,
            ));

          },
          verificationFailed: (FirebaseAuthException e) {
            isLoading = false;
            notifyListeners();
            print(e.message);
          },
          codeSent: (String verificationId, int? resendToken) {
            this.verificationId = verificationId;
Get.to(() => OTPPage());
            otpSent = true;
            isLoading = false;
            notifyListeners();
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            this.verificationId = verificationId;
            isLoading = false;
            notifyListeners();
          },
        );
      } else {
        isLoading = false;
        notifyListeners();
        showToast(
            msg: 'Invalid phone number\nTry to signup', color: Colors.red);
      }
    });
  }

  Future<void> signInWithPhoneNumber(
      String smsCode, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await Preferences.saveData(key: 'uid', value: userCredential.user!.uid);
        await getUserData(isPhone: true);
        isLoading = false;
        notifyListeners();
        Get.off(()=>const HomeScreen(
          isPhone: true,
        ));
      }
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      showToast(msg: e.message!, color: Colors.red);
      notifyListeners();
      print(e.toString());
    }
  }

  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
    String firstName,
    String lastName,
    String phoneNumber,
    File? image,
  ) async {
    isLoading = true;
    notifyListeners();
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String profilePicUrl = '';
      if (image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pics/${userCredential.user!.uid}.jpg');
        await storageRef.putFile(image);
        profilePicUrl = await storageRef.getDownloadURL();
      }

      // Save user data to Firebase with UID
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'phone_number': phoneNumber,
        'profile_pic': profilePicUrl,
        'first_name': firstName,
        'last_name': lastName,
        'phone_verified': false,
      });
      Preferences.saveData(key: 'emailUid', value: userCredential.user!.uid);
      // Trigger phone number verification
      await verifyPhoneNumber(phoneNumber, context, true);
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      showToast(msg: e.message!, color: Colors.red);
      notifyListeners();
      debugPrint(e.toString());
    }
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await Preferences.saveData(key: 'uid', value: userCredential.user!.uid);
          Get.to(() => const HomeScreen(isPhone: false,));
        // await getUserData();
        isLoading = false;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      showToast(msg: e.message ?? 'Unknown error occurred', color: Colors.red);
      notifyListeners();
      print(e.toString());
    }
  }


  Future<void> updateUserData({
    required String firstName,
    required String lastName,
    required bool phoneLogin,
    String? phoneNumber,
    String? profilePicUrl,
  }) async {
    if (currentUser != null) {
      isLoading = true;
      Map<String, dynamic> updatedData = {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'profile_pic': profilePicUrl,
      };
      if (profilePicUrl == null) {
        updatedData.remove('profile_pic');
      }
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(updatedData);
      if (phoneLogin) {
        await _firestore
            .collection('users')
            .doc(Preferences.getData(key: 'emailUid') ??
                'yKrFbMVH8xNYkavIeGDaHjFN2du2')
            .update(updatedData);
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<String?> uploadProfilePicture(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child(currentUser!.uid);
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    isLoading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email).then((value) {
        showToast(msg: 'Message sent\nCheck your email', color: Colors.green);
      });
      print('Password reset email sent.');
    } catch (e) {
      print('Error sending password reset email: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('phone_number', isEqualTo: phoneNumber)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
