import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../../backgrounds/diary_world/diary_world.dart';
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
      await FirebaseAuth.instance.signOut();

      final googleSignIn = GoogleSignIn();

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
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
      title: const Text('Pick a primary color'),
    );

    if (!mounted) return;

    final shade = _getMaterialShade(newColor);

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

    themeProvider.updatePrimaryColor(newColor);
  }

  // ============================================================
  // DIARY WORLD SELECTOR
  // ============================================================

  Future<void> _showDiaryWorldSelector(
      BuildContext context,
      ThemeProvider themeProvider,
      ) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your diary world',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Choose the atmosphere that surrounds your memories.',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.bodyMedium,
                ),

                const SizedBox(height: 20),

                ...DiaryWorld.values.map((world) {
                  final selected =
                      themeProvider.diaryWorld == world;

                  final available =
                  _isDiaryWorldAvailable(world);

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getDiaryWorldIcon(world),
                      ),

                      title: Text(
                        _getDiaryWorldTitle(world),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: Text(
                        available
                            ? _getDiaryWorldDescription(world)
                            : '${_getDiaryWorldDescription(world)}\nIn development',
                      ),

                      isThreeLine: !available,

                      trailing: selected
                          ? Icon(
                        Icons.check_circle,
                        color: Theme.of(
                          sheetContext,
                        ).colorScheme.primary,
                      )
                          : available
                          ? const Icon(
                        Icons.circle_outlined,
                      )
                          : const Icon(
                        Icons.construction_outlined,
                      ),

                      onTap: () {
                        if (!available) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${_getDiaryWorldTitle(world)} is currently in development 🚧',
                              ),
                            ),
                          );

                          return;
                        }

                        themeProvider.setDiaryWorld(world);

                        Navigator.pop(sheetContext);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DIARY WORLD TITLE
  // ============================================================

  String _getDiaryWorldTitle(DiaryWorld world) {
    switch (world) {
      case DiaryWorld.simple:
        return 'Theme-less';

      case DiaryWorld.moonlightOcean:
        return 'Moonlight Ocean';

      case DiaryWorld.forestFireflies:
        return 'Forest Fireflies';

      case DiaryWorld.butterflyGarden:
        return 'Butterfly Garden';

      case DiaryWorld.cosmicUniverse:
        return 'Cosmic Universe';

      case DiaryWorld.rainyStreet:
        return 'Rainy Street';
    }
  }

  // ============================================================
  // DIARY WORLD DESCRIPTION
  // ============================================================

  String _getDiaryWorldDescription(DiaryWorld world) {
    switch (world) {
      case DiaryWorld.simple:
        return 'Clean RDiary without a visual world';

      case DiaryWorld.moonlightOcean:
        return 'A peaceful ocean beneath the moonlight';

      case DiaryWorld.forestFireflies:
        return 'A magical forest glowing with fireflies';

      case DiaryWorld.butterflyGarden:
        return 'A peaceful garden filled with butterflies';

      case DiaryWorld.cosmicUniverse:
        return 'Explore your memories among the stars';

      case DiaryWorld.rainyStreet:
        return 'A calm street beneath the evening rain';
    }
  }

  // ============================================================
  // DIARY WORLD AVAILABILITY
  // ============================================================

  bool _isDiaryWorldAvailable(DiaryWorld world) {
    switch (world) {
      case DiaryWorld.simple:
      case DiaryWorld.cosmicUniverse:
        return true;

      case DiaryWorld.moonlightOcean:
      case DiaryWorld.forestFireflies:
      case DiaryWorld.butterflyGarden:
      case DiaryWorld.rainyStreet:
        return false;
    }
  }

  // ============================================================
  // DIARY WORLD ICON
  // ============================================================

  IconData _getDiaryWorldIcon(DiaryWorld world) {
    switch (world) {
      case DiaryWorld.simple:
        return Icons.layers_clear_outlined;

      case DiaryWorld.moonlightOcean:
        return Icons.nightlight_round;

      case DiaryWorld.forestFireflies:
        return Icons.forest_outlined;

      case DiaryWorld.butterflyGarden:
        return Icons.local_florist_outlined;

      case DiaryWorld.cosmicUniverse:
        return Icons.auto_awesome;

      case DiaryWorld.rainyStreet:
        return Icons.umbrella_outlined;
    }
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

    final isDark =
        themeProvider.themeMode ==
            ThemeMode.dark;

    final useSystemTheme =
        themeProvider.themeMode ==
            ThemeMode.system;

    final systemIsDark =
        MediaQuery.platformBrightnessOf(
          context,
        ) ==
            Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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

          const SizedBox(height: 8),

          // ----------------------------------------------------
          // DIARY THEME
          // ----------------------------------------------------

          ListTile(
            contentPadding:
            EdgeInsets.zero,

            leading: const Icon(
              Icons.auto_awesome_outlined,
            ),

            title: const Text(
              'Diary Theme',
            ),

            subtitle: Text(
              _getDiaryWorldTitle(
                themeProvider.diaryWorld,
              ),
            ),

            trailing: const Icon(
              Icons.chevron_right,
            ),

            onTap: () {
              _showDiaryWorldSelector(
                context,
                themeProvider,
              );
            },
          ),

          const Divider(height: 20),

          // ----------------------------------------------------
          // SYSTEM THEME
          // ----------------------------------------------------

          SwitchListTile(
            contentPadding:
            EdgeInsets.zero,

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
          // DARK MODE
          // ----------------------------------------------------

          SwitchListTile(
            contentPadding:
            EdgeInsets.zero,

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

            value: useSystemTheme
                ? systemIsDark
                : isDark,

            onChanged: useSystemTheme
                ? null
                : themeProvider.toggleTheme,
          ),

          // ----------------------------------------------------
          // PRIMARY COLOR
          // ----------------------------------------------------

          ListTile(
            contentPadding:
            EdgeInsets.zero,

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

          const Divider(height: 36),

          // ====================================================
          // PRIVACY & SECURITY
          // ====================================================

          _buildSectionTitle(
            context,
            'Privacy & Security',
          ),

          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding:
            EdgeInsets.zero,

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
                await Get.toNamed(
                  '/create-pin',
                );

                await _loadLockState();
              } else {
                await _lockService
                    .setLockEnabled(false);

                if (!mounted) return;

                setState(() {
                  _lockEnabled = false;
                });
              }
            },
          ),

          const Divider(height: 36),

          // ====================================================
          // ACCOUNT
          // ====================================================

          _buildSectionTitle(
            context,
            'Account',
          ),

          const SizedBox(height: 16),

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

              style:
              ElevatedButton.styleFrom(
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

        const SizedBox(height: 10),

        Text(
          user.displayName ?? 'No name',
          style: Theme.of(
            context,
          ).textTheme.titleMedium,
        ),

        const SizedBox(height: 3),

        Text(
          user.email ?? 'No email',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium,
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
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(
          context,
        ).colorScheme.primary,
      ),
    );
  }
}