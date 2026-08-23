import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // ============================================================
  // NOTIFICATION PLUGIN
  // ============================================================

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // INITIALIZATION
  // ============================================================

  static Future<void> init() async {
    debugPrint('[RDIARY][NOTIFICATION] Initializing notification service...');
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      const initSettings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('[RDIARY][NOTIFICATION] Notification response received: ${details.payload}');
        },
      );

      // Load timezone database.
      tz.initializeTimeZones();

      // Detect local timezone
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      debugPrint('[RDIARY][NOTIFICATION] Initialization SUCCESS');
      debugPrint('[RDIARY][NOTIFICATION] Device timezone: ${tz.local.name}');
      debugPrint('[RDIARY][NOTIFICATION] Current local time: ${tz.TZDateTime.now(tz.local)}');
    } catch (e) {
      debugPrint('[RDIARY][NOTIFICATION] Initialization FAILED: $e');
    }
  }

  // ============================================================
  // DIAGNOSTICS
  // ============================================================

  static Future<void> runDiagnostics() async {
    debugPrint('[RDIARY][NOTIFICATION] ===== NOTIFICATION DIAGNOSTICS =====');
    debugPrint('[RDIARY][NOTIFICATION] Android version: ${Platform.operatingSystemVersion}');
    debugPrint('[RDIARY][NOTIFICATION] App build mode: ${kReleaseMode ? 'RELEASE' : 'DEBUG'}');
    
    final notifStatus = await Permission.notification.status;
    debugPrint('[RDIARY][NOTIFICATION] Notification permission: ${notifStatus.name}');
    
    if (Platform.isAndroid) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      debugPrint('[RDIARY][NOTIFICATION] Exact alarm permission: ${exactAlarmStatus.name}');
    }
    
    debugPrint('[RDIARY][NOTIFICATION] Timezone: ${tz.local.name}');
    debugPrint('[RDIARY][NOTIFICATION] Current time: ${tz.TZDateTime.now(tz.local)}');
    
    await logPendingNotifications();
    debugPrint('[RDIARY][NOTIFICATION] =====================================');
  }

  static Future<void> logPendingNotifications() async {
    try {
      final List<PendingNotificationRequest> pending = await _notificationsPlugin.pendingNotificationRequests();
      debugPrint('[RDIARY][NOTIFICATION] Pending notifications: ${pending.length}');
      for (var req in pending) {
        debugPrint('  - ID: ${req.id} | Title: ${req.title}');
      }
    } catch (e) {
      debugPrint('[RDIARY][NOTIFICATION] Error listing pending notifications: $e');
    }
  }

  // ============================================================
  // NOTIFICATION PERMISSION
  // ============================================================

  static Future<void> requestPermission() async {
    if (!Platform.isAndroid) return;

    debugPrint('[RDIARY][NOTIFICATION] Requesting notification permission...');
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      final result = await Permission.notification.request();
      debugPrint('[RDIARY][NOTIFICATION] Notification permission result: ${result.name}');
    } else {
      debugPrint('[RDIARY][NOTIFICATION] Notification permission: ALREADY GRANTED');
    }
  }

  // ============================================================
  // EXACT ALARM PERMISSION
  // ============================================================

  static Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    debugPrint('[RDIARY][NOTIFICATION] Checking exact alarm permission...');
    
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) {
      debugPrint('[RDIARY][NOTIFICATION] Exact alarm permission: ALREADY GRANTED');
      return true;
    }

    debugPrint('[RDIARY][NOTIFICATION] Exact alarm permission ${status.name}. Requesting...');
    
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final granted = await androidPlugin?.requestExactAlarmsPermission();

    debugPrint('[RDIARY][NOTIFICATION] Exact alarm permission result: ${granted == true ? 'GRANTED' : 'DENIED'}');

    return granted ?? false;
  }

  // ============================================================
  // INSTANT NOTIFICATION (TEST)
  // ============================================================

  static Future<void> showWelcomeNotification() async {
    debugPrint('[RDIARY][NOTIFICATION] Triggering welcome notification...');
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'rdiary_welcome_channel',
        'Welcome Notifications',
        channelDescription: 'Greetings when you open the app',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notificationsPlugin.show(
      999,
      'Welcome Back! 💜',
      'It\'s great to see you again. Let\'s make today productive!',
      details,
    );
    debugPrint('[RDIARY][NOTIFICATION] Welcome notification SUCCESS');
  }

  // ============================================================
  // 5-MINUTE TEST GOAL REMINDER
  // ============================================================

  static Future<void> scheduleTestGoalReminder5Min() async {
    try {
      debugPrint('[RDIARY][NOTIFICATION] Scheduling test reminders...');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[RDIARY][NOTIFICATION] Test Goal FAILED: No user logged in.');
        return;
      }

      final goalsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .where('isCompleted', isEqualTo: false)
          .limit(1)
          .get();

      String goalName = 'your goals';
      if (goalsSnapshot.docs.isNotEmpty) {
        goalName = goalsSnapshot.docs.first.data()['title'] ?? 'your goal';
      }

      final now = tz.TZDateTime.now(tz.local);

      for (int i = 1; i <= 6; i++) {
        final scheduledTime = now.add(Duration(minutes: 5 * i));
        final id = 888 + i;

        await _notificationsPlugin.zonedSchedule(
          id,
          'Goal Reminder (Test $i) 🎯',
          'Don\'t forget: $goalName',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'rdiary_test_channel_v3',
              'Test Notifications',
              channelDescription: 'Testing 5-minute reminders',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('[RDIARY][NOTIFICATION] Test reminder scheduled | id: $id | time: $scheduledTime');
      }
      debugPrint('[RDIARY][NOTIFICATION] Test reminders scheduled SUCCESS');
    } catch (e) {
      debugPrint('[RDIARY][NOTIFICATION] Test reminders FAILED: $e');
    }
  }

  // ############################################################
  //                     GOAL REMINDERS
  // ############################################################

  static Future<void> scheduleUpcomingGoalReminders({int daysAhead = 7}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint('[RDIARY][NOTIFICATION] Goal reminders FAILED: No user.');
        return;
      }

      debugPrint('[RDIARY][NOTIFICATION] Scheduling upcoming goal reminders...');

      final goalsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .get();

      debugPrint('[RDIARY][FIRESTORE] Goals found: ${goalsSnapshot.docs.length}');

      await cancelGoalReminders();

      if (goalsSnapshot.docs.isEmpty) {
        debugPrint('[RDIARY][NOTIFICATION] No goals to schedule.');
        return;
      }

      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final now = tz.TZDateTime.now(tz.local);
      int totalScheduled = 0;

      for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
        final targetDate = tz.TZDateTime(tz.local, now.year, now.month, now.day + dayOffset);
        final weekday = dayNames[targetDate.weekday - 1];

        final List<String> goalsForThisDay = [];

        for (final goalDoc in goalsSnapshot.docs) {
          final data = goalDoc.data();
          final title = data['title']?.toString().trim() ?? '';
          if (title.isEmpty) continue;

          if (data['isCompleted'] as bool? ?? false) continue;

          final goalDays = List<String>.from(data['goalDays'] ?? []);
          if (!goalDays.contains(weekday)) continue;

          final targetDateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
          final startTimestamp = data['startDate'] as Timestamp?;
          if (startTimestamp != null) {
            final start = startTimestamp.toDate();
            if (targetDateOnly.isBefore(DateTime(start.year, start.month, start.day))) continue;
          }

          final deadlineTimestamp = data['deadline'] as Timestamp?;
          if (deadlineTimestamp != null) {
            final deadline = deadlineTimestamp.toDate();
            if (targetDateOnly.isAfter(DateTime(deadline.year, deadline.month, deadline.day))) continue;
          }

          goalsForThisDay.add(title);
        }

        if (goalsForThisDay.isEmpty) continue;

        final messages = _generateMotivationalMessages(goalsForThisDay);

        // Morning 8:30 AM
        if (await _scheduleGoalNotification(
          id: _goalNotificationId(targetDate, 1),
          date: targetDate,
          hour: 8,
          minute: 30,
          title: 'Good Morning ☀️',
          message: messages['morning']!,
        )) totalScheduled++;

        // Midday 1:00 PM
        if (await _scheduleGoalNotification(
          id: _goalNotificationId(targetDate, 2),
          date: targetDate,
          hour: 13,
          minute: 0,
          title: 'Keep Going 🎯',
          message: messages['midday']!,
        )) totalScheduled++;

        // Evening 6:30 PM
        if (await _scheduleGoalNotification(
          id: _goalNotificationId(targetDate, 3),
          date: targetDate,
          hour: 18,
          minute: 30,
          title: 'Your Goals Are Waiting 💜',
          message: messages['evening']!,
        )) totalScheduled++;

        // Night 9:30 PM
        if (await _scheduleGoalNotification(
          id: _goalNotificationId(targetDate, 4),
          date: targetDate,
          hour: 21,
          minute: 30,
          title: 'How Was Your Day? 🌙',
          message: messages['night']!,
        )) totalScheduled++;
      }

      debugPrint('[RDIARY][NOTIFICATION] Goal reminders scheduled: $totalScheduled');
    } catch (e, stackTrace) {
      debugPrint('[RDIARY][NOTIFICATION] Goal reminders FAILED: $e');
      debugPrint('$stackTrace');
    }
  }

  static Map<String, String> _generateMotivationalMessages(List<String> goals) {
    final random = Random();
    String randomGoal() => goals[random.nextInt(goals.length)];
    final goalCount = goals.length;

    final morningMessages = [
      'Good morning 💜 You have $goalCount goal${goalCount > 1 ? 's' : ''} today.',
      'New day, new opportunity 🌅 Don\'t forget about ${randomGoal()}.',
      'Small steps create big changes. Give ${randomGoal()} some time today 💜',
    ];

    final middayMessages = [
      'Hey 👀 Don\'t forget about ${randomGoal()}. You\'ve still got plenty of time.',
      'How\'s the day going? 💜 Your goals haven\'t forgotten about you.',
    ];

    final eveningMessages = [
      'The day isn\'t over yet 🌆 There\'s still time for ${randomGoal()}.',
      'A little progress tonight can make tomorrow feel better 💜',
    ];

    final nightMessages = [
      'How did today go? 🌙 Did you get a chance to work on ${randomGoal()}?',
      'Consistency beats perfection. Tomorrow we keep rolling 💜',
    ];

    return {
      'morning': morningMessages[random.nextInt(morningMessages.length)],
      'midday': middayMessages[random.nextInt(middayMessages.length)],
      'evening': eveningMessages[random.nextInt(eveningMessages.length)],
      'night': nightMessages[random.nextInt(nightMessages.length)],
    };
  }

  static Future<bool> _scheduleGoalNotification({
    required int id,
    required tz.TZDateTime date,
    required int hour,
    required int minute,
    required String title,
    required String message,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = tz.TZDateTime(tz.local, date.year, date.month, date.day, hour, minute);

    if (!scheduledTime.isAfter(now)) return false;

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        message,
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'rdiary_goal_reminders_v2',
            'RDiary Goal Reminders',
            channelDescription: 'Motivational reminders for your goals',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('[RDIARY][NOTIFICATION] Goal reminder scheduled | id: $id | time: $scheduledTime');
      return true;
    } catch (e) {
      debugPrint('[RDIARY][NOTIFICATION] Goal reminder FAILED | id: $id | error: $e');
      return false;
    }
  }

  static int _goalNotificationId(tz.TZDateTime date, int slot) {
    return ((date.year % 100) * 1000000) + (date.month * 10000) + (date.day * 100) + slot;
  }

  static Future<void> cancelGoalReminders({int daysAhead = 14}) async {
    final now = tz.TZDateTime.now(tz.local);
    for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      final date = tz.TZDateTime(tz.local, now.year, now.month, now.day + dayOffset);
      for (int slot = 1; slot <= 4; slot++) {
        await _notificationsPlugin.cancel(_goalNotificationId(date, slot));
      }
    }
    debugPrint('[RDIARY][NOTIFICATION] Previous goal reminders cleared.');
  }

  // ############################################################
  //                     DIARY REMINDERS
  // ############################################################

  static Future<void> scheduleUpcomingDiaryReminders({int daysAhead = 7}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      debugPrint('[RDIARY][NOTIFICATION] Scheduling upcoming diary reminders...');
      await cancelUpcomingDiaryReminders(daysAhead: 14);

      int totalScheduled = 0;
      final now = tz.TZDateTime.now(tz.local);
      final random = Random();

      for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
        final targetDate = tz.TZDateTime(tz.local, now.year, now.month, now.day + dayOffset);

        if (dayOffset == 0) {
          if (await _hasDiaryEntryForDate(user.uid, targetDate)) {
            debugPrint('[RDIARY][NOTIFICATION] Diary already written today. Skipping reminders.');
            continue;
          }
        }

        final middayMsg = 'How\'s your day going? 💜 Take a minute to write it down.';
        final eveningMsg = 'Your day is becoming a memory. Save a little piece of it 📝';
        final nightMsg = 'Before today becomes yesterday 🌙 Write a few words about it.';

        if (await _scheduleDiaryNotification(
          id: _diaryNotificationId(targetDate, 1),
          date: targetDate,
          hour: 12,
          minute: 0,
          title: 'A moment for yourself 💜',
          message: middayMsg,
        )) totalScheduled++;

        if (await _scheduleDiaryNotification(
          id: _diaryNotificationId(targetDate, 2),
          date: targetDate,
          hour: 18,
          minute: 0,
          title: 'How was your day? 🌆',
          message: eveningMsg,
        )) totalScheduled++;

        if (await _scheduleDiaryNotification(
          id: _diaryNotificationId(targetDate, 3),
          date: targetDate,
          hour: 22,
          minute: 0,
          title: 'Before today ends 🌙',
          message: nightMsg,
        )) totalScheduled++;
      }
      debugPrint('[RDIARY][NOTIFICATION] Diary reminders scheduled: $totalScheduled');
    } catch (e) {
      debugPrint('[RDIARY][NOTIFICATION] Diary reminders FAILED: $e');
    }
  }

  static Future<bool> _hasDiaryEntryForDate(String uid, tz.TZDateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfNextDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(startOfNextDay))
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  static Future<bool> _scheduleDiaryNotification({
    required int id,
    required tz.TZDateTime date,
    required int hour,
    required int minute,
    required String title,
    required String message,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = tz.TZDateTime(tz.local, date.year, date.month, date.day, hour, minute);

    if (!scheduledTime.isAfter(now)) return false;

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        message,
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'rdiary_diary_reminders_v2',
            'RDiary Diary Reminders',
            channelDescription: 'Gentle reminders to write your daily diary',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('[RDIARY][NOTIFICATION] Diary reminder scheduled | id: $id | time: $scheduledTime');
      return true;
    } catch (e) {
      debugPrint('[RDIARY][NOTIFICATION] Diary reminder FAILED | id: $id | error: $e');
      return false;
    }
  }

  static int _diaryNotificationId(tz.TZDateTime date, int slot) {
    return 100000000 + ((date.year % 100) * 1000000) + (date.month * 10000) + (date.day * 100) + slot;
  }

  static Future<void> cancelUpcomingDiaryReminders({int daysAhead = 14}) async {
    final now = tz.TZDateTime.now(tz.local);
    for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      final date = tz.TZDateTime(tz.local, now.year, now.month, now.day + dayOffset);
      for (int slot = 1; slot <= 3; slot++) {
        await _notificationsPlugin.cancel(_diaryNotificationId(date, slot));
      }
    }
    debugPrint('[RDIARY][NOTIFICATION] Previous diary reminders cleared.');
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('[RDIARY][NOTIFICATION] All RDiary notifications cancelled.');
  }
}
