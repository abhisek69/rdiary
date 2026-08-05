import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);

    // Load timezone database.
    tz.initializeTimeZones();

    // Currently RDiary uses India timezone.
    // Later this can be changed to automatic device detection.
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    debugPrint('🌍 Timezone: ${tz.local.name}');
    debugPrint('🕐 RDiary time: ${tz.TZDateTime.now(tz.local)}');
  }

  // ============================================================
  // NOTIFICATION PERMISSION
  // ============================================================

  static Future<void> requestPermission() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.notification.status;

    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  // ============================================================
  // EXACT ALARM PERMISSION
  // ============================================================

  static Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final granted = await androidPlugin?.requestExactAlarmsPermission();

    debugPrint('⏰ Exact alarm permission: $granted');

    return granted ?? false;
  }

  // ============================================================
  // INSTANT NOTIFICATION (TEST)
  // ============================================================

  static Future<void> showWelcomeNotification() async {
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
    debugPrint('🚀 Welcome notification triggered.');
  }

  // ============================================================
  // 5-MINUTE TEST GOAL REMINDER
  // ============================================================

  static Future<void> scheduleTestGoalReminder5Min() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ Test Goal: No user logged in.');
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

      // Schedule 6 notifications, each 5 minutes apart (covers next 30 mins)
      for (int i = 1; i <= 6; i++) {
        final scheduledTime = now.add(Duration(minutes: 5 * i));

        await _notificationsPlugin.zonedSchedule(
          888 + i,
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
        debugPrint('🔔 Test reminder $i scheduled for: $scheduledTime');
      }
    } catch (e) {
      debugPrint('❌ Test goal reminder failed: $e');
    }
  }

  // ############################################################
  //
  //                     GOAL REMINDERS
  //
  // ############################################################

  // ============================================================
  // 7-DAY GOAL REMINDER ENGINE
  // ============================================================

  static Future<void> scheduleUpcomingGoalReminders({int daysAhead = 7}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint('❌ Goal reminders: No logged-in user.');
        return;
      }

      debugPrint('');
      debugPrint('========================================');
      debugPrint('🎯 RDIARY GOAL REMINDER ENGINE');
      debugPrint('========================================');

      // --------------------------------------------------------
      // GET USER GOALS
      // --------------------------------------------------------

      final goalsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('goals')
              .get();

      debugPrint('📋 Firestore goals found: ${goalsSnapshot.docs.length}');

      // Remove old goal reminders before rebuilding.
      await cancelGoalReminders();

      if (goalsSnapshot.docs.isEmpty) {
        debugPrint('😴 User currently has no goals.');
        return;
      }

      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      final now = tz.TZDateTime.now(tz.local);

      int totalScheduled = 0;

      // --------------------------------------------------------
      // TODAY + NEXT 6 DAYS
      // --------------------------------------------------------

      for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
        final targetDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + dayOffset,
        );

        final weekday = dayNames[targetDate.weekday - 1];

        final dateText =
            '${targetDate.year}-'
            '${targetDate.month.toString().padLeft(2, '0')}-'
            '${targetDate.day.toString().padLeft(2, '0')}';

        debugPrint('');
        debugPrint('----------------------------------------');
        debugPrint('📅 $dateText ($weekday)');

        final List<String> goalsForThisDay = [];

        // ------------------------------------------------------
        // FIND GOALS FOR THIS DATE
        // ------------------------------------------------------

        for (final goalDoc in goalsSnapshot.docs) {
          final data = goalDoc.data();

          final title = data['title']?.toString().trim() ?? '';

          if (title.isEmpty) {
            continue;
          }

          // ----------------------------------------------------
          // ENTIRE GOAL COMPLETED
          // ----------------------------------------------------

          final isCompleted = data['isCompleted'] as bool? ?? false;

          if (isCompleted) {
            debugPrint('✅ "$title" skipped — entire goal completed.');
            continue;
          }

          // ----------------------------------------------------
          // WEEKDAY CHECK
          // ----------------------------------------------------

          final goalDays = List<String>.from(data['goalDays'] ?? []);

          if (!goalDays.contains(weekday)) {
            continue;
          }

          final targetDateOnly = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
          );

          // ----------------------------------------------------
          // START DATE CHECK
          // ----------------------------------------------------

          final startTimestamp = data['startDate'] as Timestamp?;

          if (startTimestamp != null) {
            final start = startTimestamp.toDate();

            final startDateOnly = DateTime(start.year, start.month, start.day);

            if (targetDateOnly.isBefore(startDateOnly)) {
              continue;
            }
          }

          // ----------------------------------------------------
          // DEADLINE CHECK
          // ----------------------------------------------------

          final deadlineTimestamp = data['deadline'] as Timestamp?;

          if (deadlineTimestamp != null) {
            final deadline = deadlineTimestamp.toDate();

            final deadlineDateOnly = DateTime(
              deadline.year,
              deadline.month,
              deadline.day,
            );

            if (targetDateOnly.isAfter(deadlineDateOnly)) {
              continue;
            }
          }

          // Goal is active for this day.
          goalsForThisDay.add(title);
        }

        // ------------------------------------------------------
        // NO GOALS TODAY
        // ------------------------------------------------------

        if (goalsForThisDay.isEmpty) {
          debugPrint('😴 No active goals scheduled for $weekday.');
          continue;
        }

        debugPrint('🎯 Goals: ${goalsForThisDay.join(', ')}');

        final messages = _generateMotivationalMessages(goalsForThisDay);

        // ------------------------------------------------------
        // 8:30 AM — MORNING
        // ------------------------------------------------------

        if (await _scheduleGoalNotification(
          id: _goalNotificationId(targetDate, 1),
          date: targetDate,
          hour: 8,
          minute: 30,
          title: 'Good Morning ☀️',
          message: messages['morning']!,
        )) {
          totalScheduled++;
        }

        // ------------------------------------------------------
        // 1:00 PM — MIDDAY
        // ------------------------------------------------------

        if (await _scheduleGoalNotification(
          id: _goalNotificationId(targetDate, 2),
          date: targetDate,
          hour: 13,
          minute: 0,
          title: 'Keep Going 🎯',
          message: messages['midday']!,
        )) {
          totalScheduled++;
        }

        // ------------------------------------------------------
        // 6:30 PM — EVENING
        // ------------------------------------------------------

        if (await _scheduleGoalNotification(
          id: _goalNotificationId(targetDate, 3),
          date: targetDate,
          hour: 18,
          minute: 30,
          title: 'Your Goals Are Waiting 💜',
          message: messages['evening']!,
        )) {
          totalScheduled++;
        }

        // ------------------------------------------------------
        // 9:30 PM — NIGHT
        // ------------------------------------------------------

        if (await _scheduleGoalNotification(
          id: _goalNotificationId(targetDate, 4),
          date: targetDate,
          hour: 21,
          minute: 30,
          title: 'How Was Your Day? 🌙',
          message: messages['night']!,
        )) {
          totalScheduled++;
        }
      }

      debugPrint('');
      debugPrint('========================================');
      debugPrint('✅ $totalScheduled goal reminders scheduled.');
      debugPrint('========================================');
    } catch (e, stackTrace) {
      debugPrint('❌ Goal reminder scheduling failed: $e');

      debugPrint('$stackTrace');
    }
  }

  // ============================================================
  // GOAL MOTIVATIONAL MESSAGE ENGINE
  // ============================================================

  static Map<String, String> _generateMotivationalMessages(List<String> goals) {
    final random = Random();

    String randomGoal() {
      return goals[random.nextInt(goals.length)];
    }

    final goalCount = goals.length;

    // ----------------------------------------------------------
    // MORNING MESSAGES
    // ----------------------------------------------------------

    final morningMessages = [
      'Good morning 💜 You have $goalCount '
          'goal${goalCount > 1 ? 's' : ''} today. '
          'Let\'s make today count.',

      'New day, new opportunity 🌅 '
          'Don\'t forget about ${randomGoal()}.',

      'Small steps create big changes. '
          'Give ${randomGoal()} some time today 💜',

      'You made a promise to yourself. '
          '${randomGoal()} is part of that promise 🎯',

      'Fresh day. Fresh energy. '
          'Your goals are waiting for you ☀️',

      'Your future self is built by what you do today. '
          'Start with ${randomGoal()}.',

      'Good morning 🌅 No pressure to be perfect. '
          'Just make a little progress today.',

      'Hey, you\'ve got this 💜 '
          'Maybe start your day with ${randomGoal()}.',
    ];

    // ----------------------------------------------------------
    // MIDDAY MESSAGES
    // ----------------------------------------------------------

    final middayMessages = [
      'Hey 👀 Don\'t forget about ${randomGoal()}. '
          'You\'ve still got plenty of time.',

      'How\'s the day going? 💜 '
          'Your goals haven\'t forgotten about you.',

      'Quick reminder 🎯 Even 10 focused minutes on '
          '${randomGoal()} counts.',

      'Half the day may be gone, '
          'but the opportunity isn\'t. Keep moving 💪',

      'Don\'t forget the things you care about. '
          '${randomGoal()} deserves a little attention today.',

      'A small win is still a win. '
          'How about making some progress on ${randomGoal()}?',

      'Hey 👋 Remember why you started. Keep going.',

      'Your hobbies and goals need a little love too 💜 '
          'How about ${randomGoal()}?',
    ];

    // ----------------------------------------------------------
    // EVENING MESSAGES
    // ----------------------------------------------------------

    final eveningMessages = [
      'The day isn\'t over yet 🌆 '
          'There\'s still time for ${randomGoal()}.',

      'A little progress tonight '
          'can make tomorrow feel better 💜',

      'Busy day? That\'s okay. '
          'Even one small step toward ${randomGoal()} counts.',

      'Don\'t let a busy day make you forget '
          'what matters to you 🎯',

      'You don\'t have to finish everything. '
          'Just don\'t stop moving forward 💜',

      'One focused session. One small win. '
          'That\'s enough to keep moving.',

      'Still some time left 🌆 '
          'Maybe give ${randomGoal()} a little attention.',

      'Hey 👋 Your day isn\'t finished yet. '
          '${randomGoal()} is still waiting for you.',
    ];

    // ----------------------------------------------------------
    // NIGHT MESSAGES
    // ----------------------------------------------------------

    final nightMessages = [
      'How did today go? 🌙 '
          'Did you get a chance to work on ${randomGoal()}?',

      'Life gets hard sometimes, '
          'but we keep moving 💜',

      'Before the day ends, remember that '
          'every small effort counts.',

      'Maybe today wasn\'t perfect — '
          'it doesn\'t need to be. Keep going 🌙',

      'Did you make progress on ${randomGoal()} today? '
          'If not, tomorrow is another chance 💜',

      'One difficult day doesn\'t define your journey. '
          'Rest, reset, continue.',

      'Another day almost complete 🌙 '
          'Consistency beats perfection.',

      'Whatever happened today, don\'t give up on yourself. '
          'Tomorrow we keep rolling 💜',
    ];

    return {
      'morning': morningMessages[random.nextInt(morningMessages.length)],
      'midday': middayMessages[random.nextInt(middayMessages.length)],
      'evening': eveningMessages[random.nextInt(eveningMessages.length)],
      'night': nightMessages[random.nextInt(nightMessages.length)],
    };
  }

  // ============================================================
  // SCHEDULE ONE GOAL NOTIFICATION
  // ============================================================

  static Future<bool> _scheduleGoalNotification({
    required int id,
    required tz.TZDateTime date,
    required int hour,
    required int minute,
    required String title,
    required String message,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    final scheduledTime = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // Never schedule reminders in the past.
    if (!scheduledTime.isAfter(now)) {
      debugPrint(
        '⏭️ Goal reminder skipped — '
        '$scheduledTime already passed.',
      );

      return false;
    }

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

    debugPrint('🔔 $scheduledTime → $title');

    debugPrint('💬 $message');

    return true;
  }

  // ============================================================
  // UNIQUE GOAL NOTIFICATION ID
  // ============================================================

  static int _goalNotificationId(tz.TZDateTime date, int slot) {
    // Slot:
    // 1 = Morning
    // 2 = Midday
    // 3 = Evening
    // 4 = Night

    return ((date.year % 100) * 1000000) +
        (date.month * 10000) +
        (date.day * 100) +
        slot;
  }

  // ============================================================
  // CANCEL UPCOMING GOAL REMINDERS
  // ============================================================

  static Future<void> cancelGoalReminders({int daysAhead = 14}) async {
    final now = tz.TZDateTime.now(tz.local);

    for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      final date = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + dayOffset,
      );

      for (int slot = 1; slot <= 4; slot++) {
        await _notificationsPlugin.cancel(_goalNotificationId(date, slot));
      }
    }

    debugPrint('🧹 Previous goal reminders cleared.');
  }

  // ############################################################
  //
  //                     DIARY REMINDERS
  //
  // ############################################################

  // ============================================================
  // 7-DAY DIARY REMINDER ENGINE
  // ============================================================
  //
  // Schedules:
  //
  // 12:00 PM
  // 06:00 PM
  // 10:00 PM
  //
  // for today + next 6 days.
  //
  // ============================================================

  static Future<void> scheduleUpcomingDiaryReminders({
    int daysAhead = 7,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint('❌ Diary reminders: No logged-in user.');
        return;
      }

      final now = tz.TZDateTime.now(tz.local);

      final random = Random();

      debugPrint('');
      debugPrint('========================================');
      debugPrint('📖 RDIARY DIARY REMINDER ENGINE');
      debugPrint('========================================');

      // Remove previous diary schedule before rebuilding.
      await cancelUpcomingDiaryReminders(daysAhead: 14);

      int totalScheduled = 0;

      // --------------------------------------------------------
      // TODAY + NEXT 6 DAYS
      // --------------------------------------------------------

      for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
        final targetDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + dayOffset,
        );

        final dateText =
            '${targetDate.year}-'
            '${targetDate.month.toString().padLeft(2, '0')}-'
            '${targetDate.day.toString().padLeft(2, '0')}';

        debugPrint('');
        debugPrint('----------------------------------------');
        debugPrint('📖 Diary date: $dateText');

        // ------------------------------------------------------
        // CHECK TODAY'S DIARY
        // ------------------------------------------------------
        //
        // We only need to check today here.
        //
        // Future dates cannot have entries yet.
        // ------------------------------------------------------

        if (dayOffset == 0) {
          final hasWrittenToday = await _hasDiaryEntryForDate(
            user.uid,
            targetDate,
          );

          if (hasWrittenToday) {
            debugPrint('💜 Diary already written today.');

            continue;
          }
        }

        // ------------------------------------------------------
        // MIDDAY MESSAGES
        // ------------------------------------------------------

        final middayMessages = [
          'How\'s your day going? 💜 '
              'Take a minute to write it down.',

          'Hey 👋 You haven\'t written yet. '
              'Even a few words are enough.',

          'Pause for a moment 💜 '
              'What\'s on your mind today?',

          'Your diary is waiting 📖 '
              'Write something about your day so far.',

          'You don\'t need a big story. '
              'One honest thought is enough 💜',

          'Capture a little piece of today '
              'before the day gets busy 📝',
        ];

        // ------------------------------------------------------
        // EVENING MESSAGES
        // ------------------------------------------------------

        final eveningMessages = [
          'How was your day? 🌆 '
              'Take a moment to put it into words.',

          'Your day is becoming a memory. '
              'Save a little piece of it 📝',

          'Good day or difficult day — '
              'both deserve a place in your diary 💜',

          'What happened today that '
              'you don\'t want to forget? 📖',

          'Take a few minutes for yourself 💜 '
              'How did today really feel?',

          'Your diary doesn\'t need perfection. '
              'Just tell it what happened today.',
        ];

        // ------------------------------------------------------
        // NIGHT MESSAGES
        // ------------------------------------------------------

        final nightMessages = [
          'Before today becomes yesterday 🌙 '
              'Write a few words about it.',

          'You haven\'t written anything today 💜 '
              'Take a minute to capture your day.',

          'How are you feeling tonight? '
              'Leave those thoughts somewhere safe 🌙',

          'One last thing before you rest — '
              'tell your diary how today went 💜',

          'Your future self may love reading about today. '
              'Leave a little memory 📝',

          'No need for a long entry. '
              'Just write what today felt like 💜',

          'Close the day with a few honest words. '
              'Your diary is waiting 🌙',
        ];

        // ------------------------------------------------------
        // 12:00 PM
        // ------------------------------------------------------

        if (await _scheduleDiaryNotification(
          id: _diaryNotificationId(targetDate, 1),
          date: targetDate,
          hour: 12,
          minute: 0,
          title: 'A moment for yourself 💜',
          message: middayMessages[random.nextInt(middayMessages.length)],
        )) {
          totalScheduled++;
        }

        // ------------------------------------------------------
        // 6:00 PM
        // ------------------------------------------------------

        if (await _scheduleDiaryNotification(
          id: _diaryNotificationId(targetDate, 2),
          date: targetDate,
          hour: 18,
          minute: 0,
          title: 'How was your day? 🌆',
          message: eveningMessages[random.nextInt(eveningMessages.length)],
        )) {
          totalScheduled++;
        }

        // ------------------------------------------------------
        // 10:00 PM
        // ------------------------------------------------------

        if (await _scheduleDiaryNotification(
          id: _diaryNotificationId(targetDate, 3),
          date: targetDate,
          hour: 22,
          minute: 0,
          title: 'Before today ends 🌙',
          message: nightMessages[random.nextInt(nightMessages.length)],
        )) {
          totalScheduled++;
        }
      }

      debugPrint('');
      debugPrint('========================================');
      debugPrint('✅ $totalScheduled diary reminders scheduled.');
      debugPrint('========================================');
    } catch (e, stackTrace) {
      debugPrint('❌ Diary reminder scheduling failed: $e');

      debugPrint('$stackTrace');
    }
  }

  // ============================================================
  // CHECK WHETHER A DIARY ENTRY EXISTS FOR DATE
  // ============================================================
  //
  // IMPORTANT:
  //
  // This assumes your Firestore note documents contain:
  //
  // date: Timestamp
  //
  // If your actual field has another name, change 'date' below.
  // ============================================================

  static Future<bool> _hasDiaryEntryForDate(
    String uid,
    tz.TZDateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);

    final startOfNextDay = startOfDay.add(const Duration(days: 1));

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notes')
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('date', isLessThan: Timestamp.fromDate(startOfNextDay))
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  // ============================================================
  // SCHEDULE ONE DIARY NOTIFICATION
  // ============================================================

  static Future<bool> _scheduleDiaryNotification({
    required int id,
    required tz.TZDateTime date,
    required int hour,
    required int minute,
    required String title,
    required String message,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    final scheduledTime = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // Never schedule reminders in the past.
    if (!scheduledTime.isAfter(now)) {
      debugPrint(
        '⏭️ Diary reminder skipped — '
        '$scheduledTime already passed.',
      );

      return false;
    }

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

    debugPrint('📖 $scheduledTime → $title');

    debugPrint('💬 $message');

    return true;
  }

  // ============================================================
  // UNIQUE DIARY NOTIFICATION ID
  // ============================================================
  //
  // Separate ID range from goal reminders.
  //
  // Slot:
  //
  // 1 = Midday
  // 2 = Evening
  // 3 = Night
  //
  // ============================================================

  static int _diaryNotificationId(tz.TZDateTime date, int slot) {
    return 100000000 +
        ((date.year % 100) * 1000000) +
        (date.month * 10000) +
        (date.day * 100) +
        slot;
  }

  // ============================================================
  // CANCEL DIARY REMINDERS FOR ONE DATE
  // ============================================================
  //
  // Call this AFTER a diary entry is successfully saved.
  //
  // Example:
  //
  // User writes diary at 2 PM.
  //
  // 12 PM -> already happened
  // 6 PM  -> cancelled
  // 10 PM -> cancelled
  //
  // Tomorrow's reminders remain scheduled.
  // ============================================================

  static Future<void> cancelDiaryRemindersForDate(tz.TZDateTime date) async {
    for (int slot = 1; slot <= 3; slot++) {
      await _notificationsPlugin.cancel(_diaryNotificationId(date, slot));
    }

    debugPrint(
      '💜 Diary reminders cancelled for '
      '${date.year}-${date.month}-${date.day}.',
    );
  }

  // ============================================================
  // CANCEL UPCOMING DIARY REMINDERS
  // ============================================================
  //
  // Used internally whenever the 7-day schedule is rebuilt.
  // ============================================================

  static Future<void> cancelUpcomingDiaryReminders({int daysAhead = 14}) async {
    final now = tz.TZDateTime.now(tz.local);

    for (int dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      final date = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + dayOffset,
      );

      for (int slot = 1; slot <= 3; slot++) {
        await _notificationsPlugin.cancel(_diaryNotificationId(date, slot));
      }
    }

    debugPrint('🧹 Previous diary reminders cleared.');
  }

  // ============================================================
  // OPTIONAL: CANCEL EVERYTHING
  // ============================================================

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();

    debugPrint('🧹 All RDiary notifications cancelled.');
  }
}
