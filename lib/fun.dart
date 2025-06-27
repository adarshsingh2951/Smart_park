import 'package:flutter/material.dart';

class FancyFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const FancyFAB({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<FancyFAB> createState() => _FancyFABState();
}

class _FancyFABState extends State<FancyFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _glow = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Trigger glowing effect every 1.5 seconds
    Future.delayed(Duration.zero, () {
      _startGlowLoop();
    });
  }

  void _startGlowLoop() async {
    while (mounted) {
      setState(() => _glow = !_glow);
      await Future.delayed(const Duration(milliseconds: 1500));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    widget.onPressed();
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: _glow
              ? [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ]
              : [],
        ),
        child: FloatingActionButton(
          onPressed: _handleTap,
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add, size: 28,color: Colors.black,),
          tooltip: 'Add Parking Slot',
        ),
      ),
    );
  }
}
