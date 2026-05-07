import '../api/api_constants.dart';
import '../api/api_service.dart';

class AttendanceService {
  final ApiService _api = ApiService();

  Future<dynamic> getAttendance(String token) async {
    final response = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/attendance",

      token: token,
    );

    return response;
  }
}
