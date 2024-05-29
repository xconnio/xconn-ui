import "dart:async";
import "package:flutter/material.dart";
import "package:xconn_ui/constants.dart";
import "package:xconn_ui/screens/mobile/mobile_home.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    Timer(
      const Duration(seconds: 2),
      () async => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MobileHomeScaffold(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            "assets/logo/splashlogo.png",
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
