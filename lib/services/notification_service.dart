import '../api/api_constants.dart';
import '../api/api_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  // ✅ GET ALL
  Future<List> getNotifications(String token) async {
    final res = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/notifications",
      token: token,
    );
    print("NOTIFICATIONS RESPONSE = $res");
    // 🔥 FIXED
    if (res["unauthorized"] == true) {
      throw Exception("UNAUTHORIZED");
    }

    if (res["success"] == true) {
      return (res["data"]["items"] as List?) ?? [];
    }

    return [];
  }

  // ✅ MARK AS READ
  Future<dynamic> markAsRead(String token, String id) async {
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}/api/notifications/$id",
      token: token,
      body: {"isRead": true},
    );
  }

  // ✅ DELETE
  Future<dynamic> deleteNotification(String token, String id) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}/api/notifications/$id",
      token: token,
    );
  }
}
