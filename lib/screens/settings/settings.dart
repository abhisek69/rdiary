import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../../services/app_lock_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppLockService _lockService = AppLockService();
  bool _lockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    final enabled = await _lockService.isLockEnabled();
    setState(() {
      _lockEnabled = enabled;
    });
  }

  int? getMaterialShade(Color color) {
    for (final swatch in Colors.primaries) {
      for (final shade in [50,100,200,300,400,500,600,700,800,900]) {
        final c = swatch[shade];
        if (c?.value == color.value) {
          return shade;
        }
      }
    }
    return null;
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (Route<dynamic> route) => false,
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

          /// 👤 USER INFO
          if (user != null)
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(user.displayName ?? 'No name',
                    style: Theme.of(context).textTheme.titleMedium),
                Text(user.email ?? 'No email',
                    style: Theme.of(context).textTheme.bodyMedium),
                const Divider(height: 30),
              ],
            ),

          /// 🌙 DARK MODE
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDark,
            onChanged: themeProvider.toggleTheme,
          ),

          /// 🎨 COLOR PICKER
          ListTile(
            title: const Text('Primary Color'),
            subtitle: const Text('Customize your app theme color'),
            trailing: CircleAvatar(
              backgroundColor: themeProvider.primaryColor,
            ),
            onTap: () async {
              final Color newColor = await showColorPickerDialog(
                context,
                themeProvider.primaryColor,
                title: const Text('Pick a primary color'),
              );

              final shade = getMaterialShade(newColor);

              if (shade != null && shade < 400) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Shades below 500 are not allowed.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                themeProvider.updatePrimaryColor(newColor);
              }
            },
          ),

          const Divider(height: 30),

          /// 🔐 APP LOCK SECTION
          SwitchListTile(
            title: const Text("Enable App Lock"),
            subtitle: const Text("Protect diary with PIN & fingerprint"),
            value: _lockEnabled,
            onChanged: (value) async {
              if (value) {
                Get.toNamed('/create-pin');
              } else {
                await _lockService.setLockEnabled(false);
                setState(() {
                  _lockEnabled = false;
                });
              }
            },
          ),

          const SizedBox(height: 20),

          /// 🚪 LOGOUT
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
