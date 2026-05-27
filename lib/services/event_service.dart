import '../api/api_constants.dart';
import '../api/api_service.dart';

class EventService {
  final ApiService _api = ApiService();

  Future<dynamic> getEvents(String token) async {
    final response = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/events",

      token: token,
    );

    return response;
  }
}
