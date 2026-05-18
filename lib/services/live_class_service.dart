import '../api/api_constants.dart';
import '../api/api_service.dart';

class LiveClassService {
  final ApiService _api = ApiService();

  Future<dynamic> getLiveClasses(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/ytt-live", // ✅ FIXED
      token: token,
    );
  }
}
