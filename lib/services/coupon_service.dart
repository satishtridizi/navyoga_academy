import '../api/api_constants.dart';
import '../api/api_service.dart';

class CouponService {
  final ApiService _api = ApiService();

  // ✅ Only student-accessible endpoint — validate/apply a coupon code
  Future<dynamic> validateCoupon(String couponCode, String token) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/coupons/validate",
      body: {"code": couponCode},
      token: token,
    );
  }
}
