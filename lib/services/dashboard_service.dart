import '../api/api_constants.dart';
import '../api/api_service.dart';

class DashboardService {
  final ApiService _api = ApiService();

  Future<dynamic> getAttendance(String token) async {
    final response = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/dashboard/superadmin",
      token: token,
    );

    return response;
  }
}
