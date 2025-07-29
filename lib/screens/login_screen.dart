import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rdiary/utils/loading_helper.dart'; // Ensure you have loading_helper functions
import '../../auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          onPressed: () async {
            // Show loading spinner when the user starts signing in
            showLoadingScreen(context, message: "Logging in...");

            // Call the sign-in function
            final user = await _authService.signInWithGoogle();

            // After the login is finished, hide the loading screen
            hideLoadingScreen(context);

            if (user != null) {
              // Navigate to the home screen if login is successful
              Get.offAllNamed('/home');

            } else {
              // Handle failure to sign in (optional)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Login failed. Please try again."),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
