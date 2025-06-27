import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Needed for Firebase.app()
import '../models/app_user.dart';
import '../models/booking_model.dart';
import '../models/parking_space_model.dart';

class DatabaseFunctions {
  // IMPORTANT: If your Firebase Realtime Database is NOT in the US,
  // you MUST specify the databaseURL here!
  //
  // 1. Go to Firebase Console → Realtime Database → Data tab.
  // 2. Copy your database URL, e.g.:
  //    https://parkeasy2-xxxxx-xxxx.europe-west1.firebasedatabase.app/
  // 3. Replace the URL below with YOUR database URL.

  static final DatabaseReference db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://parkeasy2-4f0ef-default-rtdb.asia-southeast1.firebasedatabase.app/", // <-- PUT YOUR URL HERE!
  ).ref();

  // --- AppUser CRUD ---
  Future<void> addAppUser(AppUser user) async {
    try {
      print('Adding AppUser: ${user.uid}');
      await db.child('users').child(user.uid).set(user.toMap());
    } catch (e) {
      print('Error adding AppUser: $e');
    }
  }

  Future<void> editAppUser(AppUser user) async {
    try {
      await db.child('users').child(user.uid).update(user.toMap());
    } catch (e) {
      print('Error editing AppUser: $e');
    }
  }

  Future<void> deleteAppUser(String uid) async {
    try {
      await db.child('users').child(uid).remove();
    } catch (e) {
      print('Error deleting AppUser: $e');
    }
  }

  // --- Booking CRUD ---
  Future<void> addBooking(Booking booking) async {
    try {
      print('Adding Booking: ${booking.id}');
      await db.child('bookings').child(booking.id).set(booking.toMap());
    } catch (e) {
      print('Error adding Booking: $e');
    }
  }

  Future<void> editBooking(Booking booking) async {
    try {
      await db.child('bookings').child(booking.id).update(booking.toMap());
    } catch (e) {
      print('Error editing Booking: $e');
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      await db.child('bookings').child(bookingId).remove();
    } catch (e) {
      print('Error deleting Booking: $e');
    }
  }

  // --- ParkingSpace CRUD ---
  Future<void> addParkingSpace(ParkingSpace space) async {
    try {
      print('Adding ParkingSpace for ownerId: ${space.ownerId}');
      await db.child('parking_spaces').child(space.id).set(space.toMap());
    } catch (e) {
      print('Error adding ParkingSpace: $e');
    }
  }

  Future<void> editParkingSpace(ParkingSpace space) async {
    try {
      await db.child('parking_spaces').child(space.id).update(space.toMap());
    } catch (e) {
      print('Error editing ParkingSpace: $e');
    }
  }

  Future<void> deleteParkingSpace(String spaceId) async {
    try {
      await db.child('parking_spaces').child(spaceId).remove();
    } catch (e) {
      print('Error deleting ParkingSpace: $e');
    }
  }

  // --- Fetch functions ---

  // Fetch all users (admin only, or for testing)
  Future<List<AppUser>> fetchUsers() async {
    try {
      final snapshot = await db.child('users').get();
      if (!snapshot.exists) return [];
      final usersMap = Map<String, dynamic>.from(snapshot.value as Map);
      return usersMap.values
          .map((e) => AppUser.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Fetch all parking spaces (for users to search/map)
  Future<List<ParkingSpace>> fetchAllParkingSpaces() async {
    try {
      final snapshot = await db.child('parking_spaces').get();
      print('ALL parking_spaces: ${snapshot.value}');
      if (!snapshot.exists) return [];
      final spacesMap = Map<String, dynamic>.from(snapshot.value as Map);
      return spacesMap.values
          .map((e) => ParkingSpace.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('Error fetching parking spaces: $e');
      return [];
    }
  }

  // Fetch only the current owner's parking spaces
  Future<List<ParkingSpace>> fetchOwnerSpaces() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No authenticated user!');
        return [];
      }
      print('Fetching spaces for ownerId: ${user.uid}');
      // Hardcoded fetch: print ALL parking spaces for debugging
      final allSnapshot = await db.child('parking_spaces').get();
      print('ALL parking_spaces: ${allSnapshot.value}');
      // Owner query
      final snapshot = await db.child('parking_spaces').orderByChild('ownerId').equalTo(user.uid).get();
      print('Snapshot from owner query: ${snapshot.value}');
      if (!snapshot.exists) return [];
      final map = Map<String, dynamic>.from(snapshot.value as Map);
      final ownerSpaces = map.values.map((e) => ParkingSpace.fromMap(Map<String, dynamic>.from(e))).toList();
      print('Fetched owner spaces: $ownerSpaces');
      return ownerSpaces;
    } catch (e) {
      print('Error fetching owner spaces: $e');
      return [];
    }
  }

  // Fetch bookings for the current user
  Future<List<Booking>> fetchUserBookings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];
      final snapshot = await db.child('bookings').orderByChild('userId').equalTo(user.uid).get();
      if (!snapshot.exists) return [];
      final map = Map<String, dynamic>.from(snapshot.value as Map);
      return map.values.map((e) => Booking.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  }

  Future<void> addOrUpdateRole(AppUser user, String role) async {
    final userRef = db.child('users').child(user.uid);
    final snapshot = await userRef.get();
    Map<String, dynamic> userData = user.toMap();
    if (snapshot.exists) {
      userData = Map<String, dynamic>.from(snapshot.value as Map);
      final roles = Map<String, bool>.from(userData['roles'] ?? {});
      roles[role] = true;
      userData['roles'] = roles;
    } else {
      userData['roles'] = {role: true};
    }
    await userRef.set(userData);
  }
}
