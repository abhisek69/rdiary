import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/note_provider.dart';

import 'screens/SplashScreen.dart';
import 'screens/addSubject/addSubject.dart';
import 'screens/home/main_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings/create_pin_screen.dart';
import 'screens/settings/settings.dart';

import 'services/notification_service.dart';

import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // FIREBASE
  // ============================================================

  await Firebase.initializeApp();

  // ============================================================
  // SUPABASE
  // ============================================================

  await Supabase.initialize(
    url: 'https://qdlwnbedbtsiebbmaoft.supabase.co',
    anonKey: 'sb_publishable_jiYejeVC7icUUllln6BMLA_ULqq8Rqj',
  );

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  await NotificationService.init();

  await NotificationService.requestPermission();

  final exactAllowed = await NotificationService.requestExactAlarmPermission();

  // Trigger Instant Welcome Notification
  await NotificationService.showWelcomeNotification();

  // Run Diagnostics
  await NotificationService.runDiagnostics();

  // ============================================================
  // START APP
  // ============================================================

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: const DiaryApp(),
    ),
  );

  // ============================================================
  // BUILD NOTIFICATION SCHEDULE
  // ============================================================

  // We wait a bit for Firebase Auth to potentially restore session
  await Future.delayed(const Duration(seconds: 2));

  if (exactAllowed) {
    debugPrint('🚀 Building RDiary notification schedule...');

    // Goal reminders
    await NotificationService.scheduleUpcomingGoalReminders(daysAhead: 7);

    // Diary reminders
    await NotificationService.scheduleUpcomingDiaryReminders(daysAhead: 7);

    // Test 5-minute reminder
    await NotificationService.scheduleTestGoalReminder5Min();
  } else {
    debugPrint('❌ Exact alarm permission missing.');
  }
}

// ============================================================
// RDIARY APP
// ============================================================

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider already exists ABOVE DiaryApp.
    //
    // Do NOT create another ThemeProvider here.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return GetMaterialApp(
          title: 'My Diary',

          debugShowCheckedModeBanner: false,

          // ====================================================
          // THEME
          // ====================================================
          theme: themeProvider.lightTheme,

          darkTheme: themeProvider.darkTheme,

          themeMode: themeProvider.themeMode,

          // ====================================================
          // INITIAL ROUTE
          // ====================================================
          initialRoute: '/',

          // ====================================================
          // ROUTES
          // ====================================================
          getPages: [
            // --------------------------------------------------
            // SPLASH
            // --------------------------------------------------
            GetPage(name: '/', page: () => const SplashScreen()),

            // --------------------------------------------------
            // LOCK
            // --------------------------------------------------
            GetPage(name: '/lock', page: () => const LockScreen()),

            // --------------------------------------------------
            // HOME
            // --------------------------------------------------
            GetPage(
              name: '/home',
              page: () {
                final date = Get.arguments as DateTime?;

                return MainScreen(initialDate: date);
              },
            ),

            // --------------------------------------------------
            // SETTINGS
            // --------------------------------------------------
            GetPage(name: '/settings', page: () => const SettingsScreen()),

            // --------------------------------------------------
            // LOGIN
            // --------------------------------------------------
            GetPage(name: '/login', page: () => LoginScreen()),

            // --------------------------------------------------
            // CREATE PIN
            // --------------------------------------------------
            GetPage(name: '/create-pin', page: () => const CreatePinScreen()),

            // --------------------------------------------------
            // ADD NOTE
            // --------------------------------------------------
            GetPage(
              name: '/add',
              page: () {
                final selectedDate = Get.arguments as DateTime?;

                return AddSubjectScreen(selectedDate: selectedDate);
              },
            ),
          ],
        );
      },
    );
  }
}
