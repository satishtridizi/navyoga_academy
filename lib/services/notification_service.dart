import '../api/api_constants.dart';
import '../api/api_service.dart';
import '../models/notification_model.dart';
import 'reminder_service.dart';

class NotificationService {
  final ApiService _api = ApiService();


  Future<List<Map<String, dynamic>>> getNotifications(String token) async {
    final reminderService = ReminderService();
    final localList = await reminderService.getLocalInAppNotifications();
    final dismissedIds = await reminderService.getDismissedNotificationIds();
    final readIds = await reminderService.getReadNotificationIds();
    final clearedAt = await reminderService.getNotificationsClearedAt();
    List<dynamic> apiItems = [];

    try {
      final res = await _api.getRequest(
        url: "${ApiConstants.baseUrl}/api/notifications",
        token: token,
      );
      print("NOTIFICATIONS RESPONSE = $res");

      if (res["unauthorized"] == true) {
        throw Exception("UNAUTHORIZED");
      }

      if (res["success"] == true) {
        final data = res["data"];
        apiItems = data is List
            ? data
            : data is Map
                ? (data["items"] as List?) ?? const []
                : const [];
      }
    } catch (e) {
      print("Error fetching remote notifications: $e");
    }

    final unique = <String, Map<String, dynamic>>{};
    for (final raw in <dynamic>[...localList, ...apiItems]) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final model = NotificationModel.fromJson(item);
      if (model.id.isEmpty) continue;
      if (dismissedIds.contains(model.id)) continue;
      final createdAt = DateTime.tryParse(model.createdAt)?.toUtc();
      if (clearedAt != null &&
          createdAt != null &&
          !createdAt.isAfter(clearedAt)) {
        continue;
      }
      final isRead = model.isRead || readIds.contains(model.id);
      unique[model.id] = {
        ...item,
        'id': model.id,
        'title': model.title,
        'message': model.message,
        'isRead': isRead,
        'createdAt': model.createdAt,
      };
    }
    return unique.values.toList();
  }

  Future<int> getUnreadCount(String token) async {
    final notifications = await getNotifications(token);
    return notifications
        .map(NotificationModel.fromJson)
        .where((notification) => !notification.isRead)
        .length;
  }


  Future<dynamic> markAsRead(String token, String id) async {
    await ReminderService().markAsRead(id);
    if (id.startsWith('inapp_')) {
      return {'success': true};
    }
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}/api/notifications/$id",
      token: token,
      body: {"isRead": true},
    );
  }


  Future<void> markAllAsRead(String token, List<String> ids) async {
    if (ids.isEmpty) return;
    await ReminderService().markAllAsRead(ids);

    final remoteIds = ids.where((id) => !id.startsWith('inapp_')).toList();
    if (remoteIds.isNotEmpty) {
      await Future.wait(
        remoteIds.map(
          (id) => _api.patchRequest(
            url: "${ApiConstants.baseUrl}/api/notifications/$id",
            token: token,
            body: {"isRead": true},
          ).catchError((_) => null),
        ),
      );
    }
  }


  Future<dynamic> deleteNotification(String token, String id) async {
    await ReminderService().dismissNotifications([id]);
    if (id.startsWith('inapp_')) {
      await ReminderService().deleteNotification(id);
      return {'success': true};
    }
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}/api/notifications/$id",
      token: token,
    );
  }

  Future<void> clearAll(String token, List<String> ids) async {
    await ReminderService().clearNotifications(ids: ids);
    final remoteIds = ids.where(
      (id) => id.isNotEmpty && !id.startsWith('inapp_'),
    );
    await Future.wait(remoteIds.map((id) => deleteNotification(token, id)));
  }
}
