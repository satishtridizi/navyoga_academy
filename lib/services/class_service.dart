import '../api/api_constants.dart';
import '../api/api_service.dart';

class ClassService {
  final ApiService _api = ApiService();

  /// TUTOR CLASSES (only for tutor role)
  Future<dynamic> getTutorClasses(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/class/tutor",
      token: token,
    );
  }

  /// TUTOR STUDENTS (NEW API)
  Future<dynamic> getMyStudents(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/auth/tutor/me/students",
      token: token,
    );
  }
}
