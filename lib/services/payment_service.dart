import '../api/api_constants.dart';
import '../api/api_service.dart';

class PaymentService {
  final ApiService _api = ApiService();

  /// INITIATE PAYMENT
  Future<dynamic> initiatePayment(
    String token,
    Map<String, dynamic> body,
  ) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}/payments/initiate",
      token: token,
      body: body,
    );
  }

  /// VERIFY PAYMENT
  Future<dynamic> verifyPayment(String token, Map<String, dynamic> body) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}/payments/verify",
      token: token,
      body: body,
    );
  }
}
