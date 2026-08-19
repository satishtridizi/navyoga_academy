import '../api/api_constants.dart';
import '../api/api_service.dart';
import '../models/notification_model.dart';
import 'reminder_service.dart';

class NotificationService {
  final ApiService _api = ApiService();
  int? _serverUnreadCount;

  // ✅ GET ALL
  Future<List<Map<String, dynamic>>> getNotifications(String token) async {
    _serverUnreadCount = null;
    final localList = await ReminderService().getLocalInAppNotifications();
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
        if (data is Map) {
          _serverUnreadCount = _toInt(
            data['unreadCount'] ??
                data['unread_count'] ??
                (data['meta'] is Map ? data['meta']['unreadCount'] : null),
          );
        }
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
      unique[model.id] = {
        ...item,
        'id': model.id,
        'title': model.title,
        'message': model.message,
        'isRead': model.isRead,
        'createdAt': model.createdAt,
      };
    }
    return unique.values.toList();
  }

  Future<int> getUnreadCount(String token) async {
    final notifications = await getNotifications(token);
    final localUnread = notifications
        .map(NotificationModel.fromJson)
        .where((notification) =>
            notification.id.startsWith('inapp_') && !notification.isRead)
        .length;
    final remoteUnread = _serverUnreadCount ??
        notifications
            .map(NotificationModel.fromJson)
            .where((notification) =>
                !notification.id.startsWith('inapp_') && !notification.isRead)
            .length;
    return localUnread + remoteUnread;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  // ✅ MARK AS READ
  Future<dynamic> markAsRead(String token, String id) async {
    if (id.startsWith('inapp_')) {
      await ReminderService().markAsRead(id);
      return {'success': true};
    }
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}/api/notifications/$id",
      token: token,
      body: {"isRead": true},
    );
  }

  // ✅ DELETE
  Future<dynamic> deleteNotification(String token, String id) async {
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
    await ReminderService().clearNotifications();
    final remoteIds = ids.where(
      (id) => id.isNotEmpty && !id.startsWith('inapp_'),
    );
    await Future.wait(remoteIds.map((id) => deleteNotification(token, id)));
  }
}
