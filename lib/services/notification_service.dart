import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted =
    await androidPlugin?.requestExactAlarmsPermission();

    debugPrint('⏰ Exact alarm permission: $granted');

    return granted ?? false;
  }
  static Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      999,
      'RDiary Test 💜',
      'Notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rdiary_test_channel',
          'RDiary Test Notifications',
          channelDescription: 'Testing RDiary notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );

    debugPrint('Immediate notification sent');
  }
  static Future<void> scheduleExponentialTest() async {
    final now = tz.TZDateTime.now(tz.local);

    // Delays from NOW: 30s, 60s, 120s, 240s, 480s
    final delays = <int>[30, 60, 120, 240, 480];

    for (int i = 0; i < delays.length; i++) {
      final seconds = delays[i];
      final scheduledTime =
      now.add(Duration(seconds: seconds));

      debugPrint(
        '⏰ Notification #${i + 1} scheduled in ${seconds}s at $scheduledTime',
      );

      try {
        await _notificationsPlugin.zonedSchedule(
          12345 + i, // Each notification MUST have unique ID
          'RDiary Test 💜',
          'Notification #${i + 1} — fired after $seconds seconds!',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'rdiary_test_channel_v2',
              'RDiary Test Notifications',
              channelDescription: 'Testing scheduled notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
        );

        debugPrint('✅ Notification #${i + 1} scheduled successfully');
      } catch (e) {
        debugPrint('❌ Notification #${i + 1} failed: $e');
      }
    }
  }
  static Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  static Future<void> scheduleReminderNotification() async {
    await _notificationsPlugin.zonedSchedule(
      0,
      'Daily your diary Reminder',
      'Don\'t forget to write your diary entry today!',
      // _nextInstanceOf8PM(),
      _nextInstanceInOneMinute(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceInOneMinute() {
    final now = tz.TZDateTime.now(tz.local);
    return now.add(const Duration(minutes: 1));
  }

  static tz.TZDateTime _nextInstanceOf8PM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones();
  }

}
