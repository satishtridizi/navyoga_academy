import '../api/api_service.dart';

class SelfPacedService {
  final ApiService _api = ApiService();

  Future<dynamic> enrollCourse(String token, String courseId) async {
    return await _api.postRequest(
      url: "/self-paced/enroll", // 🔥 confirm with backend later
      token: token,
      body: {"courseId": courseId},
    );
  }

  Future<Map<String, dynamic>> getCourses(String token) async {
    final response = await _api.getRequest(
      url: "https://your-api.com/self-paced/courses", // 🔥 FULL URL required
      token: token,
    );

    return response;
  }
}
