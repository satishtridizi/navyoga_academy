import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../utils/auth_manager.dart';

class ReminderService {
  ReminderService._internal();
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  static const String _localNotifStorageKey = 'app_local_in_app_notifications';
  static const String _dismissedNotifStorageKey =
      'app_dismissed_notification_ids';
  static const String _readNotifStorageKey = 'app_read_notification_ids';
  static const String _notificationsClearedAtKey =
      'app_notifications_cleared_at';

  String? _cachedUserKey;


  Future<String> _userKey() async {
    final key = await AuthManager.getUserId() ?? 'anonymous';
    if (_cachedUserKey != key) {
      _cachedUserKey = key;
      _readNotifIdsCache = null;
      _dismissedNotifIdsCache = null;
    }
    return key;
  }

  Future<String> _scopedKey(String base) async => '${await _userKey()}::$base';

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


  Future<void> showNewClassNotification({
    required String classId,
    required String classTitle,
  }) async {
    final inboxId = 'inapp_new_class_$classId';
    if (await isNotificationDismissed(inboxId)) return;
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
      id: inboxId,
      title: 'New class available',
      message: classTitle,
      scheduledTime: DateTime.now(),
    );
  }


  Future<void> scheduleClassReminders({
    required String classId,
    required String classTitle,
    required DateTime scheduledAt,
  }) async {
    await init();
    final now = DateTime.now();

    final time30m = scheduledAt.subtract(const Duration(minutes: 30));
    final time15m = scheduledAt.subtract(const Duration(minutes: 15));
    final dismissedIds = await getDismissedNotificationIds();
    final inboxId30 = 'inapp_${classId}_30m';
    final inboxId15 = 'inapp_${classId}_15m';


    if (time30m.isAfter(now) && !dismissedIds.contains(inboxId30)) {
      final id30 = _generateNotifId('${classId}_30m');
      await _scheduleLocalNotification(
        id: id30,
        title: 'Class Reminder: $classTitle',
        body: 'Your live yoga class "$classTitle" starts in 30 minutes!',
        scheduledDate: time30m,
        payload: 'class_$classId',
      );

      await _saveInAppNotification(
        id: inboxId30,
        title: 'Upcoming Class in 30m',
        message: '"$classTitle" starts in 30 minutes at ${_formatTime(scheduledAt)}',
        scheduledTime: time30m,
      );
    }


    if (time15m.isAfter(now) && !dismissedIds.contains(inboxId15)) {
      final id15 = _generateNotifId('${classId}_15m');
      await _scheduleLocalNotification(
        id: id15,
        title: 'Class Starting Soon: $classTitle',
        body: 'Get ready! Your class "$classTitle" starts in 15 minutes!',
        scheduledDate: time15m,
        payload: 'class_$classId',
      );

      await _saveInAppNotification(
        id: inboxId15,
        title: 'Upcoming Class in 15m',
        message: '"$classTitle" starts in 15 minutes! Be ready to join.',
        scheduledTime: time15m,
      );
    }
  }


  Future<void> scheduleSubscriptionRenewalReminder({
    required DateTime renewalDate,
    String? planName,
  }) async {
    await init();
    final now = DateTime.now();
    final time7d = renewalDate.subtract(const Duration(days: 7));
    final inboxId =
        'inapp_renewal_${renewalDate.millisecondsSinceEpoch}';

    if (time7d.isAfter(now) && !await isNotificationDismissed(inboxId)) {
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
        id: inboxId,
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


  Future<void> _saveInAppNotification({
    required String id,
    required String title,
    required String message,
    required DateTime scheduledTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (await isNotificationDismissed(id)) return;
      final storageKey = await _scopedKey(_localNotifStorageKey);
      final existingRaw = prefs.getStringList(storageKey) ?? [];

      final existingList = existingRaw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();


      if (existingList.any((item) => item['id'] == id)) return;

      existingList.insert(0, {
        'id': id,
        'title': title,
        'message': message,
        'isRead': false,
        'createdAt': scheduledTime.toIso8601String(),
      });

      final updatedRaw = existingList.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList(storageKey, updatedRaw);
    } catch (e) {
      debugPrint('Error saving in-app notification: $e');
    }
  }


  static const Duration _localNotifRetention = Duration(days: 3);


  Future<List<Map<String, dynamic>>> getLocalInAppNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = await _scopedKey(_localNotifStorageKey);
      final rawList = prefs.getStringList(storageKey) ?? [];
      final dismissedIds = await getDismissedNotificationIds();
      final cutoff = DateTime.now().subtract(_localNotifRetention);

      final decoded = rawList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      final fresh = decoded.where((item) {
        final createdAt = DateTime.tryParse(item['createdAt']?.toString() ?? '');
        return createdAt == null || createdAt.isAfter(cutoff);
      }).toList();

      if (fresh.length != decoded.length) {
        await prefs.setStringList(
          storageKey,
          fresh.map((e) => jsonEncode(e)).toList(),
        );
      }

      return fresh
          .where((item) => !dismissedIds.contains(item['id']?.toString()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Set<String>? _readNotifIdsCache;
  Set<String>? _dismissedNotifIdsCache;


  Future<void> markAsRead(String id) async {
    await markAllAsRead([id]);
  }


  Future<void> markAllAsRead(Iterable<String> ids) async {
    final cleanIds = ids.map((id) => id.trim()).where((id) => id.isNotEmpty).toSet();
    if (cleanIds.isEmpty) return;

    try {
      final current = await getReadNotificationIds();
      current.addAll(cleanIds);
      _readNotifIdsCache = current;

      final prefs = await SharedPreferences.getInstance();

      final localKey = await _scopedKey(_localNotifStorageKey);
      final rawList = prefs.getStringList(localKey) ?? [];
      if (rawList.isNotEmpty) {
        final list = rawList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
        bool changed = false;
        for (var item in list) {
          final itemId = item['id']?.toString();
          if (itemId != null && cleanIds.contains(itemId)) {
            item['isRead'] = true;
            changed = true;
          }
        }
        if (changed) {
          await prefs.setStringList(
            localKey,
            list.map((e) => jsonEncode(e)).toList(),
          );
        }
      }

      final values = current.toList();
      final retained = values.length > 1000
          ? values.sublist(values.length - 1000)
          : values;
      await prefs.setStringList(await _scopedKey(_readNotifStorageKey), retained);
    } catch (_) {}
  }

  Future<Set<String>> getReadNotificationIds() async {
    final storageKey = await _scopedKey(_readNotifStorageKey);
    if (_readNotifIdsCache != null) {
      return Set<String>.from(_readNotifIdsCache!);
    }
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(storageKey) ?? const <String>[])
        .where((id) => id.isNotEmpty)
        .toSet();
    _readNotifIdsCache = ids;
    return Set<String>.from(ids);
  }


  Future<void> deleteNotification(String id) async {
    try {
      await dismissNotifications([id]);
      final prefs = await SharedPreferences.getInstance();
      final localKey = await _scopedKey(_localNotifStorageKey);
      final rawList = prefs.getStringList(localKey) ?? [];
      final list = rawList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

      list.removeWhere((item) => item['id'] == id);

      await prefs.setStringList(
        localKey,
        list.map((e) => jsonEncode(e)).toList(),
      );
      await _notificationsPlugin.cancel(_systemNotificationIdForInboxId(id));
    } catch (_) {}
  }

  Future<void> clearNotifications({Iterable<String> ids = const []}) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = await getLocalInAppNotifications();
    final clearedIds = {
      ...ids,
      ...stored.map((item) => item['id']?.toString() ?? ''),
    }..removeWhere((id) => id.isEmpty);
    await dismissNotifications(clearedIds);
    await prefs.remove(await _scopedKey(_localNotifStorageKey));
    await prefs.setString(
      await _scopedKey(_notificationsClearedAtKey),
      DateTime.now().toUtc().toIso8601String(),
    );


    for (final id in clearedIds) {
      await _notificationsPlugin.cancel(_systemNotificationIdForInboxId(id));
    }
  }

  Future<DateTime?> getNotificationsClearedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return DateTime.tryParse(
      prefs.getString(await _scopedKey(_notificationsClearedAtKey)) ?? '',
    )?.toUtc();
  }

  Future<Set<String>> getDismissedNotificationIds() async {
    final storageKey = await _scopedKey(_dismissedNotifStorageKey);
    if (_dismissedNotifIdsCache != null) {
      return Set<String>.from(_dismissedNotifIdsCache!);
    }
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(storageKey) ?? const <String>[])
        .where((id) => id.isNotEmpty)
        .toSet();
    _dismissedNotifIdsCache = ids;
    return Set<String>.from(ids);
  }

  Future<bool> isNotificationDismissed(String id) async {
    if (id.isEmpty) return false;
    return (await getDismissedNotificationIds()).contains(id);
  }

  Future<void> dismissNotifications(Iterable<String> ids) async {
    final cleanIds = ids.map((id) => id.trim()).where((id) => id.isNotEmpty).toSet();
    if (cleanIds.isEmpty) return;

    final existing = await getDismissedNotificationIds();
    existing.addAll(cleanIds);
    _dismissedNotifIdsCache = existing;

    final prefs = await SharedPreferences.getInstance();
    final values = existing.toList();
    final retained = values.length > 1000
        ? values.sublist(values.length - 1000)
        : values;
    await prefs.setStringList(await _scopedKey(_dismissedNotifStorageKey), retained);
  }

  int _systemNotificationIdForInboxId(String id) {
    if (id.startsWith('inapp_')) {
      return _generateNotifId(id.substring('inapp_'.length));
    }
    return _generateNotifId(id);
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
