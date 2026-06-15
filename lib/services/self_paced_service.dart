import '../api/api_constants.dart';
import '../api/api_service.dart';

class SelfPacedService {
  final ApiService _api = ApiService();

  /// 🔥 GET COURSES
  Future<dynamic> getCourses(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/self-paced/modules",
      token: token,
    );
  }

  Future<dynamic> initiatePayment(
    String token,
    String moduleId,
    // String planId,
  ) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/payments/initiate",
      token: token,
      body: {"moduleId": moduleId, "type": "SELF_PACED"},
    );
  }

  Future<dynamic> getClasses(String token, String moduleId) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/self-paced/modules/$moduleId/classes",
      token: token,
    );
  }
}
