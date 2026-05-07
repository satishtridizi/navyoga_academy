import '../api/api_constants.dart';
import '../api/api_service.dart';

class DashboardService {
  final ApiService _api = ApiService();

  Future<dynamic> getDashboard(String token) async {
    final response = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/dashboard",

      token: token,
    );

    return response;
  }
}
