import '../api/api_constants.dart';
import '../api/api_service.dart';

class DashboardService {
  final ApiService _api = ApiService();

  Future<dynamic> getDashboard(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/dashboard/student",
      token: token,
    );
  }
}
