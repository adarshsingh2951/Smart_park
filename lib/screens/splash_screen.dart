import 'package:flutter/material.dart';
import 'package:o3d/o3d.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final O3DController _modelController = O3DController();

  late AnimationController _slideInController;
  late Animation<Offset> _slideInAnimation;

  late AnimationController _slideOutController;
  late Animation<Offset> _slideOutAnimation;

  late Animation<Offset> _currentAnimation;

  @override
  void initState() {
    super.initState();

    _slideInController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideInController, curve: Curves.easeOut),
    );

    _slideOutController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0),
    ).animate(
      CurvedAnimation(parent: _slideOutController, curve: Curves.easeInOut),
    );

    _currentAnimation = _slideInAnimation;

    _slideOutController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>AuthScreen()),
        );
      }
    });

    _slideInController.forward().then((_) {
      Future.delayed(const Duration(seconds: 12), () {
        setState(() {
          _currentAnimation = _slideOutAnimation;
        });
        _slideOutController.forward();
      });
    });
  }

  @override
  void dispose() {
    _slideInController.dispose();
    _slideOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Optional: dark theme
      body: Center(
        child: SlideTransition(
          position: _currentAnimation,
          child: SizedBox(
            height: 400,
            width: 400,
            child: O3D(
              src: 'assets/xxx/Untitled.glb',
              controller: _modelController,
              autoRotate: true,
              autoPlay: true,
              autoRotateDelay: 1,
              interactionPrompt: InteractionPrompt.none,
            ),
          ),
        ),
      ),
    );
  }
}
