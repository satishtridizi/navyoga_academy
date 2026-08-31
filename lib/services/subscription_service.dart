import 'package:flutter/foundation.dart';
import '../api/api_constants.dart';
import '../api/api_service.dart';

class SubscriptionService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getPlatform(
    String token,
  ) {
    return _get(
      '/api/platform',
      token,
      fallbackData: <String, dynamic>{},
    );
  }

  Future<dynamic> getMySubscription(String token) async {
    return await _api.getRequest(
      url: ApiConstants.myEnrollmentUrl,
      token: token,
    );
  }

  Future<Map<String, dynamic>> getLivePlans(
    String token,
  ) {
    return _get(
      '/api/live/plans',
      token,
      fallbackData: <dynamic>[],
    );
  }

  Future<Map<String, dynamic>> getSelfPacedPlans(
    String token,
  ) {
    return _get(
      '/api/self-paced/plans',
      token,
      fallbackData: <dynamic>[],
    );
  }

  Future<Map<String, dynamic>> getYttLivePlans(
    String token,
  ) {
    return _get(
      '/api/ytt-live/plans',
      token,
      fallbackData: <dynamic>[],
    );
  }

  Future<Map<String, dynamic>> getYttRecordedPlans(
    String token,
  ) {
    return _get(
      '/api/ytt-recorded/plans',
      token,
      fallbackData: <dynamic>[],
    );
  }

  Future<Map<String, dynamic>> getLiveEnrollment(
    String token,
  ) {
    return _get(
      '/api/live/my-enrollment',
      token,
      fallbackData: <String, dynamic>{},
    );
  }

  Future<Map<String, dynamic>> getSelfPacedSubscription(
    String token,
  ) {
    return _get(
      '/api/self-paced/my-subscription',
      token,
      fallbackData: <String, dynamic>{},
    );
  }

  Future<Map<String, dynamic>> getYttLiveEnrollments(
    String token,
  ) {
    return _get(
      '/api/ytt-live/my-enrollments',
      token,
      fallbackData: <dynamic>[],
    );
  }

  Future<Map<String, dynamic>> getYttRecordedEnrollments(
    String token,
  ) {
    return _get(
      '/api/ytt-recorded/my-enrollments',
      token,
      fallbackData: <dynamic>[],
    );
  }

  Future<Map<String, dynamic>> _get(
    String endpoint,
    String token, {
    required dynamic fallbackData,
  }) async {
    try {
      final url = endpoint.startsWith('http')
          ? endpoint
          : '${ApiConstants.liveApiBaseUrl}$endpoint';

      final response = await _api.getRequest(
        url: url,
        token: token,
      );

      debugPrint('SUBSCRIPTION API [$endpoint] => $response');

      if (response is Map<String, dynamic>) {
        return response;
      }

      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }

      return {
        'success': false,
        'message': 'Invalid server response',
        'data': fallbackData,
      };
    } catch (error, stackTrace) {
      debugPrint('SUBSCRIPTION API ERROR [$endpoint] => $error');
      debugPrintStack(stackTrace: stackTrace);

      return {
        'success': false,
        'message': 'Unable to load subscription information',
        'data': fallbackData,
      };
    }
  }
}