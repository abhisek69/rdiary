import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // static Future<void> showTestNotification() async {
  //   await _notificationsPlugin.show(
  //     999, // Unique ID
  //     'Test Notification',
  //     'This is a test notification triggered on app start.',
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'test_channel', // Channel ID
  //         'Test Notifications', // Channel name
  //         channelDescription: 'Channel for test notifications',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         color: Color(0xFF4B0082), // Indigo/dark purple
  //         styleInformation: BigTextStyleInformation(
  //           'This is a test notification triggered on app start.',
  //         ),
  //         enableLights: true,
  //         ledColor: Color(0xFF4B0082), // Optional: LED light
  //         ledOnMs: 1000,
  //         ledOffMs: 500,
  //       ),
  //     ),
  //   );
  // }

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones();
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
}
