import '../api/api_constants.dart';
import '../api/api_service.dart';

class SubscriptionService {
  final ApiService _api = ApiService();

  Future<dynamic> getPlans(String token) async {
    final response = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/subscriptions",

      token: token,
    );

    return response;
  }
}
