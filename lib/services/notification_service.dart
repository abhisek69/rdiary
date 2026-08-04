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
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // ============================================================
  // INITIALIZATION
  // ============================================================

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    tz.initializeTimeZones();

    // TEMPORARY:
    // Later we will automatically detect the user's device timezone.
    tz.setLocalLocation(
      tz.getLocation('Asia/Kolkata'),
    );

    debugPrint('🌍 Timezone: ${tz.local.name}');
    debugPrint(
      '🕐 RDiary time: ${tz.TZDateTime.now(tz.local)}',
    );
  }

  // ============================================================
  // PERMISSIONS
  // ============================================================

  static Future<void> requestPermission() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.notification.status;

    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  static Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin =
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted =
    await androidPlugin?.requestExactAlarmsPermission();

    debugPrint('⏰ Exact alarm permission: $granted');

    return granted ?? false;
  }

  // ============================================================
  // MAIN GOAL REMINDER ENGINE
  // ============================================================

  static Future<void> scheduleUpcomingGoalReminders({
    int daysAhead = 7,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint('❌ No logged-in user.');
        return;
      }

      debugPrint('');
      debugPrint('========================================');
      debugPrint('💜 RDIARY GOAL REMINDER ENGINE');
      debugPrint('========================================');

      final goalsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('goals')
          .get();

      debugPrint(
        '📋 Firestore goals found: ${goalsSnapshot.docs.length}',
      );

      // Remove our previously scheduled goal reminders before rebuilding.
      await cancelGoalReminders();

      if (goalsSnapshot.docs.isEmpty) {
        debugPrint('😴 User currently has no goals.');
        return;
      }

      const dayNames = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];

      final now = tz.TZDateTime.now(tz.local);

      int totalScheduled = 0;

      // ========================================================
      // CHECK TODAY + UPCOMING DAYS
      // ========================================================

      for (int dayOffset = 0;
      dayOffset < daysAhead;
      dayOffset++) {
        final targetDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + dayOffset,
        );

        final weekday =
        dayNames[targetDate.weekday - 1];

        final dateText =
            '${targetDate.year}-'
            '${targetDate.month.toString().padLeft(2, '0')}-'
            '${targetDate.day.toString().padLeft(2, '0')}';

        debugPrint('');
        debugPrint('----------------------------------------');
        debugPrint('📅 $dateText ($weekday)');

        final List<String> goalsForThisDay = [];

        // ======================================================
        // FIND GOALS BELONGING TO THIS DATE
        // ======================================================

        for (final goalDoc in goalsSnapshot.docs) {
          final data = goalDoc.data();

          final title =
              data['title']?.toString().trim() ?? '';

          if (title.isEmpty) {
            continue;
          }

          final isCompleted =
              data['isCompleted'] as bool? ?? false;

          // This means the entire goal has been completed.
          if (isCompleted) {
            debugPrint(
              '✅ "$title" skipped — entire goal completed.',
            );
            continue;
          }

          final goalDays = List<String>.from(
            data['goalDays'] ?? [],
          );

          // Goal does not belong to this weekday.
          if (!goalDays.contains(weekday)) {
            continue;
          }

          // ====================================================
          // START DATE
          // ====================================================

          final startTimestamp =
          data['startDate'] as Timestamp?;

          if (startTimestamp != null) {
            final start = startTimestamp.toDate();

            final startDateOnly = DateTime(
              start.year,
              start.month,
              start.day,
            );

            final targetDateOnly = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day,
            );

            if (targetDateOnly.isBefore(startDateOnly)) {
              continue;
            }
          }

          // ====================================================
          // DEADLINE
          // ====================================================

          final deadlineTimestamp =
          data['deadline'] as Timestamp?;

          if (deadlineTimestamp != null) {
            final deadline = deadlineTimestamp.toDate();

            final deadlineDateOnly = DateTime(
              deadline.year,
              deadline.month,
              deadline.day,
            );

            final targetDateOnly = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day,
            );

            if (targetDateOnly.isAfter(deadlineDateOnly)) {
              continue;
            }
          }

          goalsForThisDay.add(title);
        }

        // ======================================================
        // NO GOALS FOR THIS DAY
        // ======================================================

        if (goalsForThisDay.isEmpty) {
          debugPrint(
            '😴 No active goals scheduled for $weekday.',
          );
          continue;
        }

        debugPrint(
          '🎯 Goals: ${goalsForThisDay.join(', ')}',
        );

        // Generate motivational messages specifically for this day.
        final messages =
        _generateMotivationalMessages(
          goalsForThisDay,
        );

        // ======================================================
        // MORNING — 8:30 AM
        // ======================================================

        if (await _scheduleUpcomingNotification(
          id: _notificationId(targetDate, 1),
          date: targetDate,
          hour: 8,
          minute: 30,
          title: 'Good Morning ☀️',
          message: messages['morning']!,
        )) {
          totalScheduled++;
        }

        // ======================================================
        // MIDDAY — 1:00 PM
        // ======================================================

        if (await _scheduleUpcomingNotification(
          id: _notificationId(targetDate, 2),
          date: targetDate,
          hour: 13,
          minute: 0,
          title: 'Keep Going 🎯',
          message: messages['midday']!,
        )) {
          totalScheduled++;
        }

        // ======================================================
        // EVENING — 6:30 PM
        // ======================================================

        if (await _scheduleUpcomingNotification(
          id: _notificationId(targetDate, 3),
          date: targetDate,
          hour: 18,
          minute: 30,
          title: 'Your Goals Are Waiting 💜',
          message: messages['evening']!,
        )) {
          totalScheduled++;
        }

        // ======================================================
        // NIGHT — 9:30 PM
        // ======================================================

        if (await _scheduleUpcomingNotification(
          id: _notificationId(targetDate, 4),
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
      debugPrint(
        '✅ $totalScheduled goal reminders scheduled.',
      );
      debugPrint('========================================');
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Goal reminder scheduling failed: $e',
      );
      debugPrint('$stackTrace');
    }
  }

  // ============================================================
  // MOTIVATIONAL MESSAGE ENGINE
  // ============================================================

  static Map<String, String> _generateMotivationalMessages(
      List<String> goals,
      ) {
    final random = Random();

    String randomGoal() {
      return goals[random.nextInt(goals.length)];
    }

    final goalCount = goals.length;

    // ----------------------------------------------------------
    // MORNING
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
    // MIDDAY
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
    // EVENING
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
    // NIGHT
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
      'morning':
      morningMessages[
      random.nextInt(morningMessages.length)],

      'midday':
      middayMessages[
      random.nextInt(middayMessages.length)],

      'evening':
      eveningMessages[
      random.nextInt(eveningMessages.length)],

      'night':
      nightMessages[
      random.nextInt(nightMessages.length)],
    };
  }

  // ============================================================
  // SCHEDULE ONE NOTIFICATION
  // ============================================================

  static Future<bool> _scheduleUpcomingNotification({
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

    // Never schedule a reminder in the past.
    if (!scheduledTime.isAfter(now)) {
      debugPrint(
        '⏭️ $title skipped — $scheduledTime already passed.',
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
          channelDescription:
          'Motivational reminders for your goals',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint(
      '🔔 $scheduledTime → $title',
    );

    debugPrint(
      '💬 $message',
    );

    return true;
  }

  // ============================================================
  // UNIQUE NOTIFICATION ID
  // ============================================================

  static int _notificationId(
      tz.TZDateTime date,
      int slot,
      ) {
    // Includes year so IDs don't collide next year.
    //
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
  // CANCEL GOAL REMINDERS
  // ============================================================

  static Future<void> cancelGoalReminders() async {
    final now = tz.TZDateTime.now(tz.local);

    // Clear a slightly larger window than we normally schedule.
    for (int dayOffset = 0;
    dayOffset < 14;
    dayOffset++) {
      final date = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + dayOffset,
      );

      for (int slot = 1; slot <= 4; slot++) {
        await _notificationsPlugin.cancel(
          _notificationId(date, slot),
        );
      }
    }

    debugPrint(
      '🧹 Previous RDiary goal reminders cleared.',
    );
  }
}