import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:navyoga_academy/api/api_constants.dart';
import 'package:navyoga_academy/models/mylive_class_model.dart';

class MyClassesService {
  MyClassesService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  Future<MyClassesResponse> getMyClasses({
    required String token,
  }) async {
    final trimmedToken = token.trim();

    if (trimmedToken.isEmpty) {
      throw const MyClassesUnauthorizedException();
    }

    final uri = Uri.parse(
      ApiConstants.myClassesUrl,
    );

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $trimmedToken',
        },
      );

      if (kDebugMode) {
        debugPrint(
          'GET ${ApiConstants.myClassesUrl}',
        );
        debugPrint(
          'My Classes status: ${response.statusCode}',
        );
        debugPrint(
          'My Classes response: ${response.body}',
        );
      }

      final decoded = _decodeResponse(
        response.body,
      );

      if (response.statusCode == 401 ||
          decoded['unauthorized'] == true) {
        throw const MyClassesUnauthorizedException();
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw MyClassesException(
          decoded['message']?.toString() ??
              'Unable to load classes.',
        );
      }

      if (decoded['success'] != true) {
        throw MyClassesException(
          decoded['message']?.toString() ??
              'Unable to load classes.',
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
    } on http.ClientException catch (error) {
      if (kDebugMode) {
        debugPrint(
          'My Classes network error: $error',
        );
      }

      throw const MyClassesException(
        'Unable to connect to the server. '
        'Please check your internet connection.',
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'Unexpected My Classes error: $error',
        );
        debugPrintStack(
          stackTrace: stackTrace,
        );
      }

      throw const MyClassesException(
        'Something went wrong while loading your classes.',
      );
    }
  }

  Map<String, dynamic> _decodeResponse(
    String body,
  ) {
    if (body.trim().isEmpty) {
      throw const MyClassesException(
        'The server returned an empty response.',
      );
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is! Map) {
        throw const MyClassesException(
          'The server returned an invalid response.',
        );
      }

      return Map<String, dynamic>.from(decoded);
    } on FormatException {
      throw const MyClassesException(
        'The server returned an invalid response.',
      );
    }
  }

  void dispose() {
    _client.close();
  }
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