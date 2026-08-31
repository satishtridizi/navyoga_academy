import 'package:flutter/foundation.dart';
import 'package:navyoga_academy/api/api_constants.dart';
import 'package:navyoga_academy/api/api_service.dart';

class YttRecordedService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getMyEnrollments(
    String token,
  ) async {
    try {
      final response = await _api.getRequest(
        url: '${ApiConstants.liveApiBaseUrl}/api/ytt-recorded/my-enrollments',
        token: token,
      );

      debugPrint('YTT RECORDED ENROLLMENTS RESPONSE => $response');

      return _toMapResponse(
        response,
        fallbackData: <dynamic>[],
      );
    } catch (error, stackTrace) {
      debugPrint('YTT RECORDED ENROLLMENTS ERROR => $error');
      debugPrintStack(stackTrace: stackTrace);

      return {
        'success': false,
        'message': 'Unable to load YTT Recorded enrollments',
        'data': <dynamic>[],
      };
    }
  }

  Future<Map<String, dynamic>> getRenewalPrompt(
    String token,
  ) async {
    try {
      final response = await _api.getRequest(
        url: '${ApiConstants.liveApiBaseUrl}/api/subscriptions/renewal-prompt',
        token: token,
      );

      debugPrint('RENEWAL PROMPT RESPONSE => $response');

      return _toMapResponse(
        response,
        fallbackData: <String, dynamic>{},
      );
    } catch (error, stackTrace) {
      debugPrint('RENEWAL PROMPT ERROR => $error');
      debugPrintStack(stackTrace: stackTrace);

      return {
        'success': false,
        'message': 'Unable to load renewal information',
        'data': <String, dynamic>{},
      };
    }
  }

  Map<String, dynamic> _toMapResponse(
    dynamic responseData, {
    required dynamic fallbackData,
  }) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    return {
      'success': false,
      'message': 'Invalid server response',
      'data': fallbackData,
    };
  }
}