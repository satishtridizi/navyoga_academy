import '../api/api_constants.dart';
import '../api/api_service.dart';

class YttLiveService {
  final ApiService _api = ApiService();

  Future<dynamic> getMyEnrollments(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/ytt-live/my-enrollments",
      token: token,
    );
  }

  Future<dynamic> getCourses(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/ytt-live",
      token: token,
    );
  }
}
