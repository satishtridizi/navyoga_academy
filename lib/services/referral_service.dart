import 'package:flutter/foundation.dart';

import '../api/api_constants.dart';
import '../api/api_service.dart';

class ReferralService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getReferrals(
    String token, {
    int page = 1,
    int limit = 5,
  }) async {
    try {
      final response = await _api.getRequest(
        url:
            '${ApiConstants.baseUrl}'
            '/api/referrals/me'
            '?page=$page&limit=$limit',
        token: token,
      );

      debugPrint(
        'REFERRALS RESPONSE => $response',
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      if (response is Map) {
        return Map<String, dynamic>.from(
          response,
        );
      }

      return {
        'success': false,
        'message': 'Invalid referral response',
        'data': <String, dynamic>{},
      };
    } catch (error, stackTrace) {
      debugPrint(
        'REFERRALS ERROR => $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return {
        'success': false,
        'message': error.toString(),
        'data': <String, dynamic>{},
      };
    }
  }
}