import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../../services/app_lock_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ============================================================
  // SERVICES & STATE
  // ============================================================

  final AppLockService _lockService = AppLockService();

  bool _lockEnabled = false;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadLockState();
  }

  // ============================================================
  // LOAD APP LOCK STATUS
  // ============================================================

  Future<void> _loadLockState() async {
    final enabled = await _lockService.isLockEnabled();

    // The screen may have been closed while waiting.
    if (!mounted) return;

    setState(() {
      _lockEnabled = enabled;
    });
  }

  // ============================================================
  // MATERIAL COLOR SHADE CHECK
  // ============================================================

  int? _getMaterialShade(Color color) {
    const shades = [
      50,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900,
    ];

    for (final swatch in Colors.primaries) {
      for (final shade in shades) {
        final shadeColor = swatch[shade];

        if (shadeColor?.value == color.value) {
          return shade;
        }
      }
    }

    return null;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      // Firebase logout.
      await FirebaseAuth.instance.signOut();

      // Google logout if the user signed in with Google.
      final googleSignIn = GoogleSignIn();

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      if (!mounted) return;

      // Remove all previous routes and return to login.
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // PRIMARY COLOR PICKER
  // ============================================================

  Future<void> _selectPrimaryColor(
      ThemeProvider themeProvider,
      ) async {
    final newColor = await showColorPickerDialog(
      context,
      themeProvider.primaryColor,
      title: const Text(
        'Pick a primary color',
      ),
    );

    if (!mounted) return;

    final shade = _getMaterialShade(newColor);

    // Prevent very light Material shades.
    if (shade != null && shade < 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Shades below 500 are not allowed.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    themeProvider.updatePrimaryColor(
      newColor,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final themeProvider =
    context.watch<ThemeProvider>();

    final user =
        FirebaseAuth.instance.currentUser;

    // Is RDiary explicitly using dark mode?
    final isDark =
        themeProvider.themeMode == ThemeMode.dark;

    // Is RDiary following the phone's theme?
    final useSystemTheme =
        themeProvider.themeMode == ThemeMode.system;

    // Actual phone brightness.
    // Used to show the correct disabled Dark Mode switch state
    // while System Theme is enabled.
    final systemIsDark =
        MediaQuery.platformBrightnessOf(context) ==
            Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          // ====================================================
          // USER PROFILE
          // ====================================================

          if (user != null) ...[
            _buildUserProfile(
              context,
              user,
            ),

            const Divider(
              height: 32,
            ),
          ],

          // ====================================================
          // APPEARANCE
          // ====================================================

          _buildSectionTitle(
            context,
            'Appearance',
          ),

          const SizedBox(
            height: 8,
          ),

          // ----------------------------------------------------
          // SYSTEM THEME
          // ----------------------------------------------------

          SwitchListTile(
            contentPadding: EdgeInsets.zero,

            secondary: const Icon(
              Icons.brightness_auto,
            ),

            title: const Text(
              'Use System Theme',
            ),

            subtitle: const Text(
              'Automatically follow your phone\'s light or dark mode',
            ),

            value: useSystemTheme,

            onChanged: (enabled) {
              themeProvider.setSystemTheme(
                enabled,
              );
            },
          ),

          // ----------------------------------------------------
          // MANUAL DARK MODE
          // ----------------------------------------------------

          SwitchListTile(
            contentPadding: EdgeInsets.zero,

            secondary: Icon(
              useSystemTheme
                  ? Icons.brightness_auto
                  : isDark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),

            title: const Text(
              'Dark Mode',
            ),

            subtitle: Text(
              useSystemTheme
                  ? 'Controlled automatically by your phone'
                  : 'Manually switch between light and dark mode',
            ),

            // When system mode is enabled, display the phone's
            // current state even though this switch is disabled.
            value: useSystemTheme
                ? systemIsDark
                : isDark,

            // null disables the manual switch.
            onChanged: useSystemTheme
                ? null
                : themeProvider.toggleTheme,
          ),

          // ----------------------------------------------------
          // PRIMARY COLOR
          // ----------------------------------------------------

          ListTile(
            contentPadding: EdgeInsets.zero,

            leading: const Icon(
              Icons.palette_outlined,
            ),

            title: const Text(
              'Primary Color',
            ),

            subtitle: const Text(
              'Customize your RDiary theme color',
            ),

            trailing: CircleAvatar(
              radius: 15,
              backgroundColor:
              themeProvider.primaryColor,
            ),

            onTap: () {
              _selectPrimaryColor(
                themeProvider,
              );
            },
          ),

          const Divider(
            height: 36,
          ),

          // ====================================================
          // PRIVACY & SECURITY
          // ====================================================

          _buildSectionTitle(
            context,
            'Privacy & Security',
          ),

          const SizedBox(
            height: 8,
          ),

          // ----------------------------------------------------
          // APP LOCK
          // ----------------------------------------------------

          SwitchListTile(
            contentPadding: EdgeInsets.zero,

            secondary: const Icon(
              Icons.lock_outline,
            ),

            title: const Text(
              'Enable App Lock',
            ),

            subtitle: const Text(
              'Protect your diary with PIN & fingerprint',
            ),

            value: _lockEnabled,

            onChanged: (enabled) async {
              if (enabled) {
                // User must create a PIN before enabling lock.
                await Get.toNamed(
                  '/create-pin',
                );

                // Reload actual lock state after returning.
                await _loadLockState();
              } else {
                await _lockService.setLockEnabled(
                  false,
                );

                if (!mounted) return;

                setState(() {
                  _lockEnabled = false;
                });
              }
            },
          ),

          const Divider(
            height: 36,
          ),

          // ====================================================
          // ACCOUNT
          // ====================================================

          _buildSectionTitle(
            context,
            'Account',
          ),

          const SizedBox(
            height: 16,
          ),

          // ----------------------------------------------------
          // LOGOUT
          // ----------------------------------------------------

          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: _logout,

              icon: const Icon(
                Icons.logout,
              ),

              label: const Text(
                'Logout',
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor:
                Colors.redAccent,

                foregroundColor:
                Colors.white,

                padding:
                const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // USER PROFILE
  // ============================================================

  Widget _buildUserProfile(
      BuildContext context,
      User user,
      ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,

          backgroundImage:
          user.photoURL != null
              ? NetworkImage(
            user.photoURL!,
          )
              : null,

          child:
          user.photoURL == null
              ? const Icon(
            Icons.person,
            size: 40,
          )
              : null,
        ),

        const SizedBox(
          height: 10,
        ),

        Text(
          user.displayName ??
              'No name',

          style:
          Theme.of(context)
              .textTheme
              .titleMedium,
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          user.email ??
              'No email',

          style:
          Theme.of(context)
              .textTheme
              .bodyMedium,
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      BuildContext context,
      String title,
      ) {
    return Text(
      title,

      style:
      Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(
        fontWeight:
        FontWeight.bold,

        color:
        Theme.of(context)
            .colorScheme
            .primary,
      ),
    );
  }
}