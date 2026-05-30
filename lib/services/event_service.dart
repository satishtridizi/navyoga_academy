import '../api/api_constants.dart';
import '../api/api_service.dart';

class EventService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getEvents(String token) async {
    final response = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/events/upcoming",
      token: token,
    );

    if (response["success"] == true) {
      return response["data"]["items"] ?? [];
    }

    return [];
  }

  Future<dynamic> enrollEvent(String eventId, String token) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/events/$eventId/enrollment",
      body: {},
      token: token,
    );
  }
}
