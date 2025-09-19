// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class UserScreen extends StatefulWidget {
//   @override
//   _UserScreenState createState() => _UserScreenState();
// }
//
// class _UserScreenState extends State<UserScreen> {
//   String latestImageUrl = '';
//   String previousImageUrl = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text('Parking name', style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 20
//         ),),
//       ),
//       body:Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.red,),
//             SizedBox(height: 16),
//             Text('Waiting for camera...',style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20
//             ),),
//           ],
//         ),
//       ),
//       // Stack(
//       //   children: [
//       //     StreamBuilder(
//       //       stream: FirebaseFirestore.instance.collection('camera_streams').orderBy('timestamp', descending: true).snapshots(),
//       //       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//       //         if (snapshot.connectionState == ConnectionState.active) {
//       //           if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//       //             var doc = snapshot.data!.docs.first;
//       //             var url = doc['url'];
//       //             if (latestImageUrl != url) {
//       //               previousImageUrl = latestImageUrl;
//       //               latestImageUrl = url;
//       //             }
//       //             return Stack(
//       //               children: [
//       //                 if (previousImageUrl.isNotEmpty)
//       //                   Positioned.fill(
//       //                     child: FadeInImage.assetNetwork(
//       //                       placeholder: '',
//       //                       image: previousImageUrl,
//       //                       fit: BoxFit.cover,
//       //                     ),
//       //                   ),
//       //                 Positioned.fill(
//       //                   child: FadeInImage.assetNetwork(
//       //                     placeholder: '',
//       //                     image: latestImageUrl,
//       //                     fit: BoxFit.cover,
//       //                   ),
//       //                 ),
//       //               ],
//       //             );
//       //           } else {
//       //             return Center(
//       //               child: Column(
//       //                 mainAxisAlignment: MainAxisAlignment.center,
//       //                 children: [
//       //                   CircularProgressIndicator(),
//       //                   SizedBox(height: 16),
//       //                   Text('Waiting for camera...'),
//       //                 ],
//       //               ),
//       //             );
//       //           }
//       //         } else {
//       //           return Center(child: CircularProgressIndicator());
//       //         }
//       //       },
//       //     ),
//       //     Positioned(
//       //       top: 16,
//       //       left: 16,
//       //       child: Text(
//       //         'Camera 1',
//       //         style: TextStyle(
//       //           color: Colors.white,
//       //           fontSize: 24,
//       //           fontWeight: FontWeight.bold,
//       //           shadows: [
//       //             Shadow(
//       //               offset: Offset(0, 1),
//       //               blurRadius: 6,
//       //               color: Colors.black,
//       //             ),
//       //           ],
//       //         ),
//       //       ),
//       //     ),
//       //     Positioned(
//       //       top: 16,
//       //       right: 16,
//       //       child: Row(
//       //         children: [
//       //           Icon(
//       //             Icons.live_tv,
//       //             color: Colors.red,
//       //             size: 24,
//       //           ),
//       //           SizedBox(width: 4),
//       //           Text(
//       //             'Live',
//       //             style: TextStyle(
//       //               color: Colors.red,
//       //               fontSize: 24,
//       //               fontWeight: FontWeight.bold,
//       //               shadows: [
//       //                 Shadow(
//       //                   offset: Offset(0, 1),
//       //                   blurRadius: 6,
//       //                   color: Colors.black,
//       //                 ),
//       //               ],
//       //             ),
//       //           ),
//       //         ],
//       //       ),
//       //     ),
//       //   ],
//       // ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String latestImageUrl = '';
  String previousImageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'AAST Parking',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('camera_streams')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              var doc = snapshot.data!.docs.first;
              var url = doc['url'];
              if (latestImageUrl != url) {
                previousImageUrl = latestImageUrl;
                latestImageUrl = url;
              }
              return Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .6,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      if (previousImageUrl.isNotEmpty)
                        Positioned.fill(
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/loading.gif',
                            image: previousImageUrl,
                            fit: BoxFit.fill,
                            imageErrorBuilder: (context, error, _) =>
                                const Center(
                                    child: CircularProgressIndicator()),
                          ),
                        ),
                      Positioned.fill(
                        child: FadeInImage.assetNetwork(
                          imageErrorBuilder: (context, error, _) =>
                              const Center(child: CircularProgressIndicator()),
                          placeholder: 'assets/images/loading.gif',
                          image: latestImageUrl,
                          fit: BoxFit.fill,
                        ),
                      ),
                      const Positioned(
                        top: 16,
                        left: 16,
                        child: Text(
                          'Camera',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 6,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Icon(
                              Icons.live_tv,
                              color: Colors.red,
                              size: 24,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Live',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 6,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Waiting for camera...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
