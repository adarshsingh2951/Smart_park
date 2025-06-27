import 'package:firebase_database/firebase_database.dart';
import '../models/app_user.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Save user info to database
  Future<void> saveUser(AppUser user) async {
    await _db.child('users').child(user.uid).set(user.toMap());
  }
}
