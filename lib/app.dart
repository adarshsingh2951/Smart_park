import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  const MyApp({Key? key, required this.themeMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkEasy',
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: themeMode,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
