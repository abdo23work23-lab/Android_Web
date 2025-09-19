// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
//
// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends State<CameraScreen> {
//   CameraController? _controller;
//   Future<void>? _initializeControllerFuture;
//   late Timer _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     initializeCamera();
//   }
//
//   Future<void> initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;
//
//     _controller = CameraController(
//       firstCamera,
//       ResolutionPreset.medium,
//     );
//
//     _initializeControllerFuture = _controller?.initialize();
//     setState(() {});
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     _timer.cancel();
//     deleteAllImages();
//     super.dispose();
//   }
//
//   Future<void> deleteAllImages() async {
//     final collectionRef = FirebaseFirestore.instance.collection('camera_streams');
//     final snapshot = await collectionRef.get();
//     for (var doc in snapshot.docs) {
//       final url = doc['url'];
//       await FirebaseStorage.instance.refFromURL(url).delete();
//       await collectionRef.doc(doc.id).delete();
//     }
//   }
//
//   void startStreaming() {
//     _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
//       if (_controller != null && _controller!.value.isInitialized) {
//         final image = await _controller!.takePicture();
//         final bytes = await image.readAsBytes();
//
//         final storageRef = FirebaseStorage.instance.ref().child('stream/${DateTime.now().millisecondsSinceEpoch}.jpg');
//         await storageRef.putData(bytes);
//         final url = await storageRef.getDownloadURL();
//
//         await manageImagesInFirestore(url);
//       }
//     });
//   }
//
//   Future<void> manageImagesInFirestore(String url) async {
//     final collectionRef = FirebaseFirestore.instance.collection('camera_streams');
//
//     final snapshot = await collectionRef.get();
//     if (snapshot.docs.length >= 5) {
//       final sortedDocs = snapshot.docs..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
//
//       final oldestDoc = sortedDocs.first;
//       final oldestUrl = oldestDoc['url'];
//       await FirebaseStorage.instance.refFromURL(oldestUrl).delete();
//       await collectionRef.doc(oldestDoc.id).delete();
//     }
//
//     await collectionRef.add({
//       'url': url,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
//
//   Future<bool> _onWillPop() async {
//     await deleteAllImages();
//     Navigator.pop(context, true);
//     return Future.value(false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Camera'),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () => _onWillPop(),
//           ),
//         ),
//         body: FutureBuilder<void>(
//           future: _initializeControllerFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               startStreaming();
//               return CameraPreview(_controller!);
//             } else {
//               return Center(child: CircularProgressIndicator());
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;


import '../../helpers/api_handler.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late Timer _timer;
  String? documentId;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller?.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer.cancel();
    super.dispose();
  }

  void startStreaming() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) async {
      if (_controller != null && _controller!.value.isInitialized) {
        final image = await _controller!.takePicture();
        final bytes = await image.readAsBytes();
        final compressedBytes = compressImage(bytes);
        sendImage(compressedBytes);
      }
    });
  }

  Uint8List compressImage(Uint8List imageBytes) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image != null) {
      img.Image resizedImage = img.copyResize(image, width: 1920,height: 1088); // Adjust the width as needed
      return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85)); // Adjust the quality as needed
    }
    return imageBytes;
  }

  Future<void> sendImage(Uint8List imageBytes) async {
    print('sending...');
    try {
      FormData formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(imageBytes, filename: 'image.jpg'),
      });

      Response response = await ApiHandler.postData(
        url: '/api/test', // Replace with your endpoint
        data: formData,
      );
print('ddddd ${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        String imagePath = response.data['image'];
        await saveImagePathToFirestore(imagePath);
        print('Image uploaded and path saved to Firestore');
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> saveImagePathToFirestore(String imagePath) async {
    final collectionRef = FirebaseFirestore.instance.collection('camera_streams');

    if (documentId == null) {
      DocumentReference docRef = await collectionRef.add({
        'url': imagePath,
        'timestamp': FieldValue.serverTimestamp(),
      });
      documentId = docRef.id;
    } else {
      await collectionRef.doc(documentId).update({
        'url': imagePath,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<bool> _onWillPop() async {
    _timer.cancel();
    Navigator.pop(context, true);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width*.8,
            child: Column(
              children: [
                const SizedBox(height: 10,),
                const Center(child: Text('Camera',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        startStreaming();
                        return SizedBox(height:MediaQuery.of(context).size.height*.85,width: MediaQuery.of(context).size.width*.8 ,child: CameraPreview(_controller!));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
