import '../api/api_constants.dart';
import '../api/api_service.dart';

class PaymentService {
  final ApiService _api = ApiService();

  Future<dynamic> getPayments(String token) async {
    final response = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/payments",

      token: token,
    );

    return response;
  }
}
