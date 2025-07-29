import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Transparent status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    // Navigate after delay based on login state
    Future.delayed(const Duration(seconds: 2), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.offAllNamed('/login'); // 🔁 go to login
      } else {
        Get.offAllNamed('/home'); // ✅ go to home
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
              child: const Icon(Icons.book_rounded, size: 100, color: Colors.white),
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 1, end: 0),

            const SizedBox(height: 20),

            FadeTransition(
              opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
              child: const Text(
                'My Diary',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 1, end: 0),

            const SizedBox(height: 16),

            const Text(
              'Reflect. Write. Grow.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
