import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  Color _primaryColor = Colors.deepPurple;
  Color _secondaryColor = Colors.amber;

  ThemeProvider() {
    _loadPreferences();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  ThemeMode get themeMode => _themeMode;

  Color get primaryColor => _primaryColor;

  Color get secondaryColor => _secondaryColor;

  bool get useSystemTheme =>
      _themeMode == ThemeMode.system;

  bool get isDarkMode =>
      _themeMode == ThemeMode.dark;

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
    _themeMode =
    isDark ? ThemeMode.dark : ThemeMode.light;

    _savePreferences();

    notifyListeners();
  }

  // ============================================================
  // SYSTEM THEME
  // ============================================================

  void setSystemTheme(bool enabled) {
    if (enabled) {
      // Follow Android/iOS theme automatically.
      _themeMode = ThemeMode.system;
    } else {
      // When system mode is turned OFF,
      // use the phone's CURRENT appearance as the
      // starting manual theme.
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;

      _themeMode =
      brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
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
    final prefs =
    await SharedPreferences.getInstance();

    // ----------------------------------------------------------
    // THEME MODE
    // ----------------------------------------------------------

    final savedThemeMode =
    prefs.getString('themeMode');

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
      // First installation / old preference format.
      //
      // Check whether the old "isDark" setting exists.
        if (prefs.containsKey('isDark')) {
          final oldIsDark =
              prefs.getBool('isDark') ?? false;

          _themeMode =
          oldIsDark
              ? ThemeMode.dark
              : ThemeMode.light;
        } else {
          // Brand-new users follow the phone automatically.
          _themeMode = ThemeMode.system;
        }
    }

    // ----------------------------------------------------------
    // COLORS
    // ----------------------------------------------------------

    final primaryColorValue =
        prefs.getInt('primaryColor') ??
            Colors.deepPurple.value;

    final secondaryColorValue =
        prefs.getInt('secondaryColor') ??
            Colors.amber.value;

    _primaryColor =
        Color(primaryColorValue);

    _secondaryColor =
        Color(secondaryColorValue);

    notifyListeners();
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  Future<void> _savePreferences() async {
    final prefs =
    await SharedPreferences.getInstance();

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

    await prefs.setString(
      'themeMode',
      themeModeValue,
    );

    await prefs.setInt(
      'primaryColor',
      _primaryColor.value,
    );

    await prefs.setInt(
      'secondaryColor',
      _secondaryColor.value,
    );
  }
}