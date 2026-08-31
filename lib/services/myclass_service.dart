import 'package:flutter/foundation.dart';
import 'package:navyoga_academy/api/api_constants.dart';
import 'package:navyoga_academy/api/api_service.dart';
import 'package:navyoga_academy/models/mylive_class_model.dart';

class MyClassesService {
  MyClassesService({
    ApiService? api,
  }) : _api = api ?? ApiService();

  final ApiService _api;

  Future<MyClassesResponse> getMyClasses({
    required String token,
  }) async {
    final trimmedToken = token.trim();

    if (trimmedToken.isEmpty) {
      throw const MyClassesUnauthorizedException();
    }

    try {
      final response = await _api.getRequest(
        url: ApiConstants.myClassesUrl,
        token: trimmedToken,
      );

      if (kDebugMode) {
        debugPrint('GET ${ApiConstants.myClassesUrl}');
        debugPrint('My Classes response: $response');
      }

      if (response is! Map) {
        throw const MyClassesException('Unable to load classes.');
      }

      final Map<String, dynamic> decoded = Map<String, dynamic>.from(response);

      if (decoded['unauthorized'] == true) {
        throw const MyClassesUnauthorizedException();
      }

      if (decoded['success'] != true) {
        throw MyClassesException(
          decoded['message']?.toString() ?? 'Unable to load classes.',
        );
      }

      final data = decoded['data'];

      if (data is! Map) {
        throw const MyClassesException(
          'Classes data was not found.',
        );
      }

      return MyClassesResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on MyClassesException {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected My Classes error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      throw const MyClassesException(
        'Something went wrong while loading your classes.',
      );
    }
  }

  void dispose() {}
}

class MyClassesException implements Exception {
  const MyClassesException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MyClassesUnauthorizedException
    extends MyClassesException {
  const MyClassesUnauthorizedException()
      : super(
          'Your session has expired. '
          'Please log in again.',
        );
}