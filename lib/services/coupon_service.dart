import '../api/api_constants.dart';
import '../api/api_service.dart';

class CouponService {
  final ApiService _api = ApiService();

  Future<dynamic> getCoupons(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/coupons",
      token: token,
    );
  }
}
