 import '../api/api_constants.dart';
 import '../api/api_service.dart';

// class SubscriptionService {
//   

//   Future<dynamic> getPlans(String token) async {
//     return await _api.getRequest(
//       url: "${ApiConstants.baseUrl}/api/self-paced/plans",
//       token: token,
//     );
//   }

  
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SubscriptionService {
  static const String _baseUrl =
      'https://d20fx2gucmvzba.cloudfront.net';
      final ApiService _api = ApiService();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

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
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint(
        'SUBSCRIPTION API [$endpoint] => ${response.data}',
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return {
        'success': false,
        'message': 'Invalid server response',
        'data': fallbackData,
      };
    } on DioException catch (error) {
      debugPrint(
        'SUBSCRIPTION API ERROR [$endpoint] => '
        '${error.response?.data ?? error.message}',
      );

      return {
        'success': false,
        'message': _extractMessage(error),
        'data': fallbackData,
      };
    } catch (error, stackTrace) {
      debugPrint(
        'SUBSCRIPTION API ERROR [$endpoint] => $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      return {
        'success': false,
        'message': 'Unable to load subscription information',
        'data': fallbackData,
      };
    }
  }

  String _extractMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The request timed out';

      case DioExceptionType.connectionError:
        return 'Please check your internet connection';

      case DioExceptionType.badResponse:
        return 'The server returned an error';

      default:
        return error.message ?? 'Something went wrong';
    }
  }
}