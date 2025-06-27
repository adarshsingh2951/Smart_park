import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle({required String role}) async {
    try {
      UserCredential? userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }
      // Save role in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', role); // role should be 'owner' or 'user'
      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  // Email/Password Sign-In
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Save role in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', role); // role should be 'owner' or 'user'
      return userCredential;
    } catch (e) {
      print('Email/Password Sign-In Error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
  }

  // Current user
  User? get currentUser => _auth.currentUser;
}
