import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class YttRecordedService {
  static const String _baseUrl =
      'https://d20fx2gucmvzba.cloudfront.net';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<Map<String, dynamic>> getMyEnrollments(
    String token,
  ) async {
    try {
      final response = await _dio.get(
        '/api/ytt-recorded/my-enrollments',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint(
        'YTT RECORDED ENROLLMENTS STATUS => '
        '${response.statusCode}',
      );

      debugPrint(
        'YTT RECORDED ENROLLMENTS RESPONSE => '
        '${response.data}',
      );

      return _toMapResponse(
        response.data,
        fallbackData: <dynamic>[],
      );
    } on DioException catch (error) {
      debugPrint(
        'YTT RECORDED ENROLLMENTS ERROR => '
        '${error.response?.data ?? error.message}',
      );

      return {
        'success': false,
        'message': _extractMessage(error),
        'data': <dynamic>[],
      };
    } catch (error, stackTrace) {
      debugPrint(
        'YTT RECORDED ENROLLMENTS ERROR => $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      return {
        'success': false,
        'message':
            'Unable to load YTT Recorded enrollments',
        'data': <dynamic>[],
      };
    }
  }

  Future<Map<String, dynamic>> getRenewalPrompt(
    String token,
  ) async {
    try {
      final response = await _dio.get(
        '/api/subscriptions/renewal-prompt',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint(
        'RENEWAL PROMPT STATUS => '
        '${response.statusCode}',
      );

      debugPrint(
        'RENEWAL PROMPT RESPONSE => '
        '${response.data}',
      );

      return _toMapResponse(
        response.data,
        fallbackData: <String, dynamic>{},
      );
    } on DioException catch (error) {
      debugPrint(
        'RENEWAL PROMPT ERROR => '
        '${error.response?.data ?? error.message}',
      );

      return {
        'success': false,
        'message': _extractMessage(error),
        'data': <String, dynamic>{},
      };
    } catch (error, stackTrace) {
      debugPrint(
        'RENEWAL PROMPT ERROR => $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      return {
        'success': false,
        'message':
            'Unable to load renewal information',
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

  String _extractMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map &&
        responseData['message'] != null) {
      return responseData['message'].toString();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out';

      case DioExceptionType.sendTimeout:
        return 'Request timed out';

      case DioExceptionType.receiveTimeout:
        return 'Server response timed out';

      case DioExceptionType.connectionError:
        return 'Please check your internet connection';

      case DioExceptionType.badResponse:
        return 'Server returned an error';

      case DioExceptionType.cancel:
        return 'Request was cancelled';

      default:
        return error.message ?? 'Something went wrong';
    }
  }
}