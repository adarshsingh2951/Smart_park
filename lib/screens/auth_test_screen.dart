// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
//
// import '../models/app_user.dart';
// import '../services/auth_service.dart';
//
// class AuthTestScreen extends StatefulWidget {
//   const AuthTestScreen({super.key});
//   @override
//   State<AuthTestScreen> createState() => _AuthTestScreenState();
// }
//
// class _AuthTestScreenState extends State<AuthTestScreen> {
//   final AuthService _authService = AuthService();
//   AppUser? _user;
//   String _status = 'Not signed in';
//
//   String? _bookingInfo;
//   String? _parkingInfo;
//
//   // Firebase RTDB reference
//   final _db = FirebaseDatabase.instance.ref();
//
//   Future<void> _signIn(bool isOwner) async {
//     setState(() {
//       _status = 'Signing in...';
//     });
//     try {
//       final user = await _authService.signInWithGoogle(User.isOwner: isOwner);
//       if (user != null) {
//         setState(() {
//           _user = user;
//           _status = 'Signed in as ${user.displayName} (${user.isOwner ? "Owner" : "User"})';
//         });
//       } else {
//         setState(() {
//           _status = 'Sign-in failed';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _status = 'Error: ${e.toString()}';
//       });
//     }
//   }
//
//   Future<void> _signOut() async {
//     await _authService.signOut();
//     setState(() {
//       _user = null;
//       _status = 'Not signed in';
//       _bookingInfo = null;
//       _parkingInfo = null;
//     });
//   }
//
//   // Test: Write a sample ParkingSpace to DB
//   Future<void> _saveParkingSpace() async {
//     final parkingSpace = {
//       'id': 'test-ps-1',
//       'ownerId': _user!.uid,
//       'address': '123 Main St',
//       'latitude': 28.6139,
//       'longitude': 77.2090,
//       'pricePerHour': 50.0,
//       'availableSpots': 3,
//       'photoUrl': '',
//     };
//     await _db.child('parking_spaces').child(parkingSpace['id']! as String).set(parkingSpace);
//     setState(() {
//       _parkingInfo = 'ParkingSpace saved!';
//     });
//   }
//
//   // Test: Read a sample ParkingSpace from DB
//   Future<void> _readParkingSpace() async {
//     final snapshot = await _db.child('parking_spaces').child('test-ps-1').get();
//     setState(() {
//       _parkingInfo = snapshot.exists ? snapshot.value.toString() : 'No data found';
//     });
//   }
//
//   // Test: Write a sample Booking to DB
//   Future<void> _saveBooking() async {
//     final booking = {
//       'id': 'test-booking-1',
//       'userId': _user!.uid,
//       'parkingSpaceId': 'test-ps-1',
//       'startTime': DateTime.now().toIso8601String(),
//       'endTime': null,
//       'totalCost': 100.0,
//     };
//     await _db.child('bookings').child(booking['id']! as String).set(booking);
//     setState(() {
//       _bookingInfo = 'Booking saved!';
//     });
//   }
//
//   // Test: Read a sample Booking from DB
//   Future<void> _readBooking() async {
//     final snapshot = await _db.child('bookings').child('test-booking-1').get();
//     setState(() {
//       _bookingInfo = snapshot.exists ? snapshot.value.toString() : 'No data found';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ParkEasy Auth & DB Test'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(_status, style: const TextStyle(fontSize: 18)),
//                 const SizedBox(height: 24),
//                 if (_user == null) ...[
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.person),
//                     label: const Text('Sign in as User'),
//                     onPressed: () => _signIn(false),
//                   ),
//                   const SizedBox(height: 12),
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.business),
//                     label: const Text('Sign in as Owner'),
//                     onPressed: () => _signIn(true),
//                   ),
//                 ] else ...[
//                   CircleAvatar(
//                     backgroundImage: NetworkImage(_user!.photoUrl),
//                     radius: 32,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(_user!.displayName, style: const TextStyle(fontSize: 20)),
//                   Text(_user!.email),
//                   Text(_user!.isOwner ? 'Owner' : 'User'),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: _signOut,
//                     child: const Text('Sign Out'),
//                   ),
//                   const Divider(height: 32),
//                   Text('ParkingSpace:', style: const TextStyle(fontWeight: FontWeight.bold)),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         onPressed: _saveParkingSpace,
//                         child: const Text('Save'),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: _readParkingSpace,
//                         child: const Text('Read'),
//                       ),
//                     ],
//                   ),
//                   if (_parkingInfo != null) Text(_parkingInfo!),
//                   const SizedBox(height: 24),
//                   Text('Booking:', style: const TextStyle(fontWeight: FontWeight.bold)),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         onPressed: _saveBooking,
//                         child: const Text('Save'),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: _readBooking,
//                         child: const Text('Read'),
//                       ),
//                     ],
//                   ),
//                   if (_bookingInfo != null) Text(_bookingInfo!),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }