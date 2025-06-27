import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkeasy2/providers/image_provider.dart';
import 'package:parkeasy2/providers/slot_provider.dart';
import 'package:parkeasy2/providers/speech_provider.dart';
import 'package:parkeasy2/services/noti_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'screens/auth_screen.dart';
import 'screens/map_screen.dart';
import 'screens/owner_dashboard_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env safely
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env loaded: ${dotenv.env}");
  } catch (e) {
    print('❌ Failed to load .env file: $e');
    //print('Env loaded: ${dotenv.env}');
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotiService().initNotification();
  // Run app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
        ChangeNotifierProvider(create: (_) => SlotProvider()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If you don't use showcaseview, you can remove ShowCaseWidget below
    return ShowCaseWidget(
      builder:
          (context) => MaterialApp(
            title: 'ParkEasy',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.blue),
            home: const SplashScreen(),
          ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  Future<String?> _getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role'); // 'owner' or 'user'
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: _getRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final role = roleSnapshot.data;
              final email = snapshot.data!.email ?? '';
              if (role == 'owner') {
                return OwnerDashboardScreen();
              } else {

                return MapScreen(email: email);
              }
            },
          );
        }
        return AuthScreen();
      },
    );
  }
}
