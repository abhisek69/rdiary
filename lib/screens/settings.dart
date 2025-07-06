import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: isDark,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),
          ListTile(
            title: Text('Primary Color'),
            subtitle: Text('Customize your app color'),
            trailing: CircleAvatar(
              backgroundColor: themeProvider.primaryColor,
            ),
            onTap: () async {
              final Color newColor = await showColorPickerDialog(
                context,
                themeProvider.primaryColor,
                title: Text('Pick a color'),
                heading: Text('Select your diary theme color'),
                showMaterialName: true,
              );
              themeProvider.updatePrimaryColor(newColor);
            },
          ),
        ],
      ),
    );
  }
}
