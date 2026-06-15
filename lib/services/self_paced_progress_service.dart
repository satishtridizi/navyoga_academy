import '../api/api_constants.dart';
import '../api/api_service.dart';

class SelfPacedProgressService {
  final ApiService _api = ApiService();

  Future<dynamic> getMyProgress(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/self-paced/my-progress",
      token: token,
    );
  }

  Future<dynamic> markComplete(String token, String classId) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/self-paced/classes/$classId/progress",
      token: token,
      body: {"isCompleted": true},
    );
  }
}
