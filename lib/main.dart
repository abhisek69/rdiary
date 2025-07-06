import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdiary/screens/SplashScreen.dart';
import 'package:rdiary/screens/addNotes.dart';
import 'package:rdiary/screens/home.dart';
import 'package:rdiary/screens/login_screen.dart';
import 'package:rdiary/screens/settings.dart';
import 'package:rdiary/utils/loading_helper.dart'; // Add loading helper imports
import 'theme/app_theme.dart';
import 'models/note_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
            home: const SplashScreen(), // Set SplashScreen as the home screen
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/home':
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                case '/settings':
                  return MaterialPageRoute(builder: (_) => const SettingsScreen());
                case '/login':
                  return MaterialPageRoute(builder: (_) =>  LoginScreen());
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