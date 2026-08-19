import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService._internal();
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  static const String _localNotifStorageKey = 'app_local_in_app_notifications';

  Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      _initialized = true;
      debugPrint('ReminderService initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing ReminderService: $e');
    }
  }

  /// Request permissions on Android 13+ / iOS
  Future<void> requestPermissions() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlatform?.requestNotificationsPermission();

      final iosPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosPlatform?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  /// Immediately surface and persist a class-created notification. Persisting
  /// here keeps the in-app inbox consistent with the system notification.
  Future<void> showNewClassNotification({
    required String classId,
    required String classTitle,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'navyoga_classes',
      'New Classes',
      channelDescription: 'Notifications when a new class is available',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      _generateNotifId('new_class_$classId'),
      'New class available',
      classTitle,
      details,
      payload: 'class_$classId',
    );
    await _saveInAppNotification(
      id: 'inapp_new_class_$classId',
      title: 'New class available',
      message: classTitle,
      scheduledTime: DateTime.now(),
    );
  }

  /// Schedule Class Reminders: 30 minutes and 15 minutes prior to class scheduled start
  Future<void> scheduleClassReminders({
    required String classId,
    required String classTitle,
    required DateTime scheduledAt,
  }) async {
    await init();
    final now = DateTime.now();

    final time30m = scheduledAt.subtract(const Duration(minutes: 30));
    final time15m = scheduledAt.subtract(const Duration(minutes: 15));

    // 1. 30 Minutes Reminder
    if (time30m.isAfter(now)) {
      final id30 = _generateNotifId('${classId}_30m');
      await _scheduleLocalNotification(
        id: id30,
        title: 'Class Reminder: $classTitle',
        body: 'Your live yoga class "$classTitle" starts in 30 minutes!',
        scheduledDate: time30m,
        payload: 'class_$classId',
      );

      await _saveInAppNotification(
        id: 'inapp_${classId}_30m',
        title: 'Upcoming Class in 30m',
        message: '"$classTitle" starts in 30 minutes at ${_formatTime(scheduledAt)}',
        scheduledTime: time30m,
      );
    }

    // 2. 15 Minutes Reminder
    if (time15m.isAfter(now)) {
      final id15 = _generateNotifId('${classId}_15m');
      await _scheduleLocalNotification(
        id: id15,
        title: 'Class Starting Soon: $classTitle',
        body: 'Get ready! Your class "$classTitle" starts in 15 minutes!',
        scheduledDate: time15m,
        payload: 'class_$classId',
      );

      await _saveInAppNotification(
        id: 'inapp_${classId}_15m',
        title: 'Upcoming Class in 15m',
        message: '"$classTitle" starts in 15 minutes! Be ready to join.',
        scheduledTime: time15m,
      );
    }
  }

  /// Schedule Subscription Renewal Reminder: 7 days before renewal
  Future<void> scheduleSubscriptionRenewalReminder({
    required DateTime renewalDate,
    String? planName,
  }) async {
    await init();
    final now = DateTime.now();
    final time7d = renewalDate.subtract(const Duration(days: 7));

    if (time7d.isAfter(now)) {
      final planLabel = planName ?? 'membership';
      final notifId = _generateNotifId('renewal_${renewalDate.millisecondsSinceEpoch}');

      await _scheduleLocalNotification(
        id: notifId,
        title: 'Subscription Renewal Reminder',
        body: 'Your NavYoga $planLabel subscription renews in 7 days on ${_formatDate(renewalDate)}.',
        scheduledDate: time7d,
        payload: 'subscription_renewal',
      );

      await _saveInAppNotification(
        id: 'inapp_renewal_${renewalDate.millisecondsSinceEpoch}',
        title: 'Subscription Renewal in 1 Week',
        message: 'Your $planLabel plan is set to renew on ${_formatDate(renewalDate)}.',
        scheduledTime: time7d,
      );
    }
  }

  Future<void> _scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'navyoga_reminders',
        'Class & Renewal Reminders',
        channelDescription: 'Notifications for class start times and subscription renewals',
        importance: Importance.max,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('Scheduled push reminder "$title" for $tzScheduled');
    } catch (e) {
      debugPrint('Error scheduling local notification: $e');
    }
  }

  /// Store notification in SharedPreferences so it shows up in in-app list
  Future<void> _saveInAppNotification({
    required String id,
    required String title,
    required String message,
    required DateTime scheduledTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingRaw = prefs.getStringList(_localNotifStorageKey) ?? [];

      final existingList = existingRaw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

      // Avoid duplicates
      if (existingList.any((item) => item['id'] == id)) return;

      existingList.insert(0, {
        'id': id,
        'title': title,
        'message': message,
        'isRead': false,
        'createdAt': scheduledTime.toIso8601String(),
      });

      final updatedRaw = existingList.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList(_localNotifStorageKey, updatedRaw);
    } catch (e) {
      debugPrint('Error saving in-app notification: $e');
    }
  }

  /// Fetch all saved local in-app notifications
  Future<List<Map<String, dynamic>>> getLocalInAppNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_localNotifStorageKey) ?? [];
      return rawList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  /// Mark local notification as read
  Future<void> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_localNotifStorageKey) ?? [];
      final list = rawList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

      for (var item in list) {
        if (item['id'] == id) {
          item['isRead'] = true;
        }
      }

      await prefs.setStringList(
        _localNotifStorageKey,
        list.map((e) => jsonEncode(e)).toList(),
      );
    } catch (_) {}
  }

  /// Delete local notification
  Future<void> deleteNotification(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_localNotifStorageKey) ?? [];
      final list = rawList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

      list.removeWhere((item) => item['id'] == id);

      await prefs.setStringList(
        _localNotifStorageKey,
        list.map((e) => jsonEncode(e)).toList(),
      );
    } catch (_) {}
  }

  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localNotifStorageKey);
  }

  int _generateNotifId(String input) {
    return input.hashCode & 0x7FFFFFFF;
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
