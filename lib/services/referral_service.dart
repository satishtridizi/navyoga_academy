import '../api/api_constants.dart';
import '../api/api_service.dart';

class ReferralService {
  final ApiService _api = ApiService();

  Future<dynamic> getReferrals(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/referrals/me",
      token: token,
    );
  }
}
