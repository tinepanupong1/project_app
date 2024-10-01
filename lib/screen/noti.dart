import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showWaterReminderNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'water_channel',
      'Water Reminder',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Drink Water Reminder',
      'อย่าลืมดื่มน้ำให้เพียงพอวันนี้นะ!',
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleDailyReminder() async {
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'Drink Water Reminder',
      'ดื่มน้ำเพื่อสุขภาพที่ดีของคุณ!',
      RepeatInterval.hourly,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_channel',
          'Water Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
