import '../api/api_constants.dart';
import '../api/api_service.dart';

class SubscriptionService {
  final ApiService _api = ApiService();

  Future<dynamic> getPlans(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/self-paced/plans",
      token: token,
    );
  }

  Future<dynamic> getMySubscription(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/self-paced/my-subscription",
      token: token,
    );
  }
}
