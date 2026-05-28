import 'package:navyoga_academy/api/api_constants.dart';
import 'package:navyoga_academy/api/api_service.dart';

class CouponService {
  final ApiService _api = ApiService();

  Future<dynamic> validateCoupon({
    required String couponCode,
    required String token,
    required String type,
    String? planId,
    String? courseId,
    String? batchId,
    String? entityId,
  }) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/coupons/validate",
      token: token,
      body: {
        "code": couponCode,
        "type": type,
        if (planId != null) "planId": planId,
        if (courseId != null) "courseId": courseId,
        if (batchId != null) "batchId": batchId,
        if (entityId != null) "entityId": entityId,
      },
    );
  }
}
