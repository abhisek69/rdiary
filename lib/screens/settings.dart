import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
        ],
      ),
    );
  }
}
