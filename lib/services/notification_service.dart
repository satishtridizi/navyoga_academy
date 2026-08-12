import '../api/api_constants.dart';
import '../api/api_service.dart';
import 'reminder_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  // ✅ GET ALL
  Future<List> getNotifications(String token) async {
    final localList = await ReminderService().getLocalInAppNotifications();
    List apiItems = [];

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
        apiItems = (res["data"]["items"] as List?) ?? [];
      }
    } catch (e) {
      print("Error fetching remote notifications: $e");
    }

    return [...localList, ...apiItems];
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
}
