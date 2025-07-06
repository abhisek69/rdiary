import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdiary/screens/addNotes.dart';
import 'package:rdiary/screens/home.dart';
import 'package:rdiary/screens/settings.dart';
import 'theme/app_theme.dart';
import 'models/note_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => NoteProvider(), child: DiaryApp()),
  );
}

class DiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'My Diary',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                case '/settings':
                  return MaterialPageRoute(builder: (_) => const SettingsScreen());
                case '/add':
                  final selectedDate = settings.arguments as DateTime?;
                  return MaterialPageRoute(
                    builder: (_) => AddNoteScreen(selectedDate: selectedDate),
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}
