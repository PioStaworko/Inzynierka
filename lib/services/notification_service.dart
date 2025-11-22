// lib/services/notification_service.dart

import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Możesz dodać iOS/macOS/linux jeśli potrzebujesz

    // WindowsInitializationSettings nie jest const, dlatego budujemy InitializationSettings
    final windowsSettings = WindowsInitializationSettings(
      appName: 'Savings App',
      appUserModelId: 'com.piostaworko.savings_app',
      guid: '2f4b2e6b-8f7c-4f6a-9f3e-1c2b3a4d5e6f',
    );

    final settings = InitializationSettings(
      android: androidSettings,
      windows: windowsSettings,
    );

    await _notifications.initialize(settings);

    // WAŻNE: Od Androida 13 trzeba poprosić o uprawnienia tylko na Androidzie
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> showNotification(int id, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_channel', 
      'Powiadomienia o budżecie',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details);
  }
}