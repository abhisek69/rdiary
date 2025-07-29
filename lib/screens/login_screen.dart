import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rdiary/utils/loading_helper.dart';
import '../../auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🖌️ Background Gradient with Curves
          Container(
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   colors: [Color(0xFF6A82FB), Color(0xFFFC5C7D)],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              color:  Theme.of(context).colorScheme.primary,
            ),
          ),

          // 🎨 Ink Blob Overlay Effect
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ).animate().fadeIn(duration: 1000.ms).scale(),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ).animate().fadeIn(duration: 1200.ms).scale(),
          ),

          // 🌟 Main Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 📘 Diary Icon Animated
                const Icon(Icons.book_rounded, size: 80, color: Colors.white)
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 1, end: 0, duration: 800.ms),

                const SizedBox(height: 20),

                // 🖋️ App Name with Style
                Text(
                  'RDiary',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 1),

                const SizedBox(height: 12),

                Text(
                  'Reflect. Write. Grow.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 40),

                // 🔐 Google Sign-in Button Styled & Animated
                ElevatedButton.icon(
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    showLoadingScreen(context, message: "Logging in...");

                    final user = await _authService.signInWithGoogle();

                    hideLoadingScreen(context);

                    if (user != null) {
                      Get.offAllNamed('/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Login failed. Please try again."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 1, duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
