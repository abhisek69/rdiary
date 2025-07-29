import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Reverse-lookup the shade of a selected color from Material swatches
  int? getMaterialShade(Color color) {
    for (final swatch in Colors.primaries) {
      if (swatch is MaterialColor) {
        for (final shade in [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]) {
          final c = swatch[shade];
          if (c?.value == color.value) {
            return shade;
          }
        }
      }
    }
    return null;
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Firebase Sign Out
      await FirebaseAuth.instance.signOut();

      // Google Sign-Out (optional)
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // Clear entire navigation stack and go to login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (Route<dynamic> route) => false, // removes all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (user != null)
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null ? const Icon(Icons.person, size: 40) : null,
                ),
                const SizedBox(height: 10),
                Text(user.displayName ?? 'No name',
                    style: Theme.of(context).textTheme.titleMedium),
                Text(user.email ?? 'No email',
                    style: Theme.of(context).textTheme.bodyMedium),
                const Divider(height: 30),
              ],
            ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDark,
            onChanged: themeProvider.toggleTheme,
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Primary Color'),
            subtitle: const Text('Customize your app theme color'),
            trailing: CircleAvatar(backgroundColor: themeProvider.primaryColor),
            onTap: () async {
              final Color newColor = await showColorPickerDialog(
                context,
                themeProvider.primaryColor,
                title: const Text('Pick a primary color'),
                heading: const Text('Select your diary primary color'),
                showMaterialName: false,
                showColorName: true,
                showColorCode: false,
              );

              final shade = getMaterialShade(newColor);

              if (shade != null && shade < 400) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Shades below 500 are not allowed as they may affect readability.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                  ),
                );
              } else {
                themeProvider.updatePrimaryColor(newColor);
              }
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
