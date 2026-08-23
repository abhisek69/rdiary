import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backgrounds/diary_world/diary_world.dart';

class ThemeProvider extends ChangeNotifier {
  // ============================================================
  // STATE
  // ============================================================

  ThemeMode _themeMode = ThemeMode.system;

  Color _primaryColor = Colors.deepPurple;
  Color _secondaryColor = Colors.amber;

  /// Current RDiary visual world.
  ///
  /// Default:
  /// Cosmic Universe
  DiaryWorld _diaryWorld = DiaryWorld.cosmicUniverse;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  ThemeProvider() {
    _loadPreferences();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  ThemeMode get themeMode => _themeMode;

  Color get primaryColor => _primaryColor;

  Color get secondaryColor => _secondaryColor;

  DiaryWorld get diaryWorld => _diaryWorld;

  bool get useSystemTheme => _themeMode == ThemeMode.system;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ============================================================
  // DIARY WORLD
  // ============================================================

  Future<void> setDiaryWorld(DiaryWorld world) async {
    if (_diaryWorld == world) return;

    _diaryWorld = world;

    notifyListeners();

    await _savePreferences();
  }

  // ============================================================
  // LIGHT THEME
  // ============================================================

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
    ),
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: _primaryColor,
    ),
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
    ),
  );

  // ============================================================
  // MANUAL DARK / LIGHT MODE
  // ============================================================

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    _savePreferences();

    notifyListeners();
  }

  // ============================================================
  // SYSTEM THEME
  // ============================================================

  void setSystemTheme(bool enabled) {
    if (enabled) {
      _themeMode = ThemeMode.system;
    } else {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;

      _themeMode =
      brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }

    _savePreferences();

    notifyListeners();
  }

  // ============================================================
  // PRIMARY COLOR
  // ============================================================

  void updatePrimaryColor(Color color) {
    _primaryColor = color;

    _savePreferences();

    notifyListeners();
  }

  // ============================================================
  // SECONDARY COLOR
  // ============================================================

  void updateSecondaryColor(Color color) {
    _secondaryColor = color;

    _savePreferences();

    notifyListeners();
  }

  // ============================================================
  // LOAD SAVED SETTINGS
  // ============================================================

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // ----------------------------------------------------------
    // THEME MODE
    // ----------------------------------------------------------

    final savedThemeMode = prefs.getString('themeMode');

    switch (savedThemeMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;

      case 'dark':
        _themeMode = ThemeMode.dark;
        break;

      case 'system':
        _themeMode = ThemeMode.system;
        break;

      default:
        if (prefs.containsKey('isDark')) {
          final oldIsDark = prefs.getBool('isDark') ?? false;

          _themeMode = oldIsDark ? ThemeMode.dark : ThemeMode.light;
        } else {
          _themeMode = ThemeMode.system;
        }
    }

    // ----------------------------------------------------------
    // COLORS
    // ----------------------------------------------------------

    final primaryColorValue =
        prefs.getInt('primaryColor') ?? Colors.deepPurple.value;

    final secondaryColorValue =
        prefs.getInt('secondaryColor') ?? Colors.amber.value;

    _primaryColor = Color(primaryColorValue);

    _secondaryColor = Color(secondaryColorValue);

    // ----------------------------------------------------------
    // DIARY WORLD
    // ----------------------------------------------------------

    final savedDiaryWorld = prefs.getString('diaryWorld');

    if (savedDiaryWorld != null) {
      _diaryWorld = DiaryWorld.values.firstWhere(
            (world) => world.name == savedDiaryWorld,
        orElse: () => DiaryWorld.cosmicUniverse,
      );
    } else {
      // Existing users/default installation start with Cosmic.
      _diaryWorld = DiaryWorld.cosmicUniverse;
    }

    notifyListeners();
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    String themeModeValue;

    switch (_themeMode) {
      case ThemeMode.light:
        themeModeValue = 'light';
        break;

      case ThemeMode.dark:
        themeModeValue = 'dark';
        break;

      case ThemeMode.system:
        themeModeValue = 'system';
        break;
    }

    await prefs.setString('themeMode', themeModeValue);

    await prefs.setInt(
      'primaryColor',
      _primaryColor.value,
    );

    await prefs.setInt(
      'secondaryColor',
      _secondaryColor.value,
    );

    // Save selected visual world.
    await prefs.setString(
      'diaryWorld',
      _diaryWorld.name,
    );
  }
}