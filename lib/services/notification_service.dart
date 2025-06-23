import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  static Future<void> scheduleTaskNotifications(Task task) async {
    if (task.date.year <= 1970) return;

    final now = DateTime.now();
    final deadline = task.date;

    final onDeadlineDay = DateTime(deadline.year, deadline.month, deadline.day, 9, 0);
    if (onDeadlineDay.isAfter(now)) {
      await _schedule(
        id: _notificationId(task, 1),
        title: 'Сегодня дедлайн!',
        body: 'Задача: ${task.title}',
        time: onDeadlineDay,
      );
    }

    final twoDaysBefore = onDeadlineDay.subtract(Duration(days: 2));
    if (twoDaysBefore.isAfter(now)) {
      await _schedule(
        id: _notificationId(task, 2),
        title: 'Скоро дедлайн!',
        body: 'Через 2 дня: ${task.title}',
        time: twoDaysBefore,
      );
    }

    final twoHoursBefore = deadline.subtract(Duration(hours: 2));
    if (twoHoursBefore.isAfter(now)) {
      await _schedule(
        id: _notificationId(task, 3),
        title: 'Осталось 2 часа!',
        body: 'Завершите: ${task.title}',
        time: twoHoursBefore,
      );
    }

    final overdue = deadline.add(Duration(seconds: 15));
    if (overdue.isAfter(now)) {
      await _schedule(
        id: _notificationId(task, 4),
        title: 'Задача просрочена!',
        body: 'Вы не завершили: ${task.title}',
        time: overdue,
      );
    }
  }

  static Future<void> cancelAllTaskNotifications(Task task) async {
    for (var i = 1; i <= 4; i++) {
      await _plugin.cancel(_notificationId(task, i));
    }
  }

  static int _notificationId(Task task, int type) {
    final hash = task.id.hashCode.abs().toString();
    final short = hash.length >= 6 ? hash.substring(0, 6) : hash;
    return int.tryParse(short)! + type;
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'tasks_channel',
          'Задачи',
          channelDescription: 'Уведомления о задачах',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }
}