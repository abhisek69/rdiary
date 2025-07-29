import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rdiary/screens/SplashScreen.dart';
import 'package:rdiary/screens/addNotes.dart';
import 'package:rdiary/screens/home.dart';
import 'package:rdiary/screens/login_screen.dart';
import 'package:rdiary/screens/settings.dart';
import 'package:rdiary/services/notification_service.dart';
import 'theme/app_theme.dart';
import 'models/note_provider.dart';
import 'package:get/get.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  await NotificationService.requestPermission(); // ✅ Proper permission check
  // await NotificationService.showTestNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: const DiaryApp(),
    ),
  );
}



class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return GetMaterialApp(
            title: 'My Diary',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/', // ✅ Always show splash screen first
            getPages: [
              GetPage(
                name: '/',
                page: () => const SplashScreen(),
              ),
              GetPage(
                name: '/home',
                page: () {
                  final date = Get.arguments as DateTime?;
                  return HomeScreen(initialDate: date);
                },
              ),
              GetPage(
                name: '/settings',
                page: () => const SettingsScreen(),
              ),
              GetPage(
                name: '/login',
                page: () => LoginScreen(),
              ),
              GetPage(
                name: '/add',
                page: () {
                  final selectedDate = Get.arguments as DateTime?;
                  return AddNoteScreen(selectedDate: selectedDate);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
