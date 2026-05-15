import '../api/api_constants.dart';
import '../api/api_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  // ✅ GET ALL
  Future<dynamic> getNotifications(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/notifications",
      token: token,
    );
  }

  // ✅ MARK AS READ
  Future<dynamic> markAsRead(String token, String id) async {
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}/notifications/$id",
      token: token,
      body: {"isRead": true},
    );
  }

  // ✅ DELETE
  Future<dynamic> deleteNotification(String token, String id) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}/notifications/$id",
      token: token,
    );
  }
}
