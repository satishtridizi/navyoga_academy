import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:navyoga_academy/utils/auth_manager.dart';

class ApiService {
  Future<dynamic> postRequest({
    required String url,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      _logRequest("POST", url, body: body, token: token);

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      _logResponse("POST", url, response.statusCode, response.body);

      final data = jsonDecode(response.body);


      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }


      if (response.statusCode == 400) {
        return {
          "success": false,
          "message": data["message"] ?? "Invalid input",
        };
      }

      if (response.statusCode == 401) {
        return {"success": false, "message": data["message"] ?? "Unauthorized"};
      }

      return {
        "success": false,
        "message": data["message"] ?? "Something went wrong",
      };
    }

    on Exception catch (e, stackTrace) {
      _logError("POST", url, e, stackTrace);
      return {"success": false, "message": _friendlyRequestError(e)};
    }
  }

  Future<dynamic> getRequest({required String url, String? token}) async {
    try {
      _logRequest("GET", url, token: token);

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 30));

      _logResponse("GET", url, response.statusCode, response.body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 401) {

        await AuthManager.clearToken();

        return {
          "success": false,
          "unauthorized": true,
          "message": "Session expired",
        };
      }


      if (response.statusCode == 403) {
        return {"success": false, "message": "Access denied for this role"};
      }


      if (response.statusCode == 404) {
        return {"success": false, "message": "API not found"};
      }


      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }


      return {
        "success": false,
        "message": data["message"] ?? "Something went wrong",
      };
    }

    on Exception catch (e, stackTrace) {
      _logError("GET", url, e, stackTrace);
      return {"success": false, "message": _friendlyRequestError(e)};
    }
  }

  Future<dynamic> putRequest({
    required String url,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      _logRequest("PUT", url, body: body, token: token);

      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      _logResponse("PUT", url, response.statusCode, response.body);

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      return {
        "success": false,
        "message": data["message"] ?? "Something went wrong",
      };
    }
    on Exception catch (e, stackTrace) {
      _logError("PUT", url, e, stackTrace);
      return {"success": false, "message": _friendlyRequestError(e)};
    }
  }

  Future<dynamic> patchRequest({
    required String url,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      _logRequest("PATCH", url, body: body, token: token);

      final response = await http
          .patch(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      _logResponse("PATCH", url, response.statusCode, response.body);

      final data = jsonDecode(response.body);


      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }


      if (response.statusCode == 401) {
        await AuthManager.clearToken();

        return {
          "success": false,
          "unauthorized": true,
          "message": "Session expired",
        };
      }


      if (response.statusCode == 403) {
        return {"success": false, "message": "Access denied"};
      }


      if (response.statusCode == 404) {
        return {"success": false, "message": "API not found"};
      }


      if (response.statusCode == 400) {
        return {
          "success": false,
          "message": data["message"] ?? "Invalid input",
        };
      }


      return {
        "success": false,
        "message": data["message"] ?? "Something went wrong",
      };
    } on Exception catch (e, stackTrace) {
      _logError("PATCH", url, e, stackTrace);
      return {"success": false, "message": _friendlyRequestError(e)};
    }
  }

  Future<dynamic> deleteRequest({
    required String url,
    required String token,
  }) async {
    try {
      _logRequest("DELETE", url, token: token);

      final response = await http.delete(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      _logResponse("DELETE", url, response.statusCode, response.body);

      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      _logError("DELETE", url, e, stackTrace);
      rethrow;
    }
  }

  Future<dynamic> uploadBytesRequest({
    required String url,
    required List<int> bytes,
    required String contentType,
  }) async {
    try {
      _logRequest("UPLOAD_PUT", url);

      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              "Content-Type": contentType,
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 30));

      _logResponse("UPLOAD_PUT", url, response.statusCode, response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "statusCode": response.statusCode};
      }

      return {
        "success": false,
        "statusCode": response.statusCode,
        "message": "Failed to upload file",
      };
    } on Exception catch (e, stackTrace) {
      _logError("UPLOAD_PUT", url, e, stackTrace);
      return {"success": false, "message": _friendlyRequestError(e)};
    }
  }


  void _logRequest(String method, String url, {Map<String, dynamic>? body, String? token}) {
    if (kDebugMode) {
      debugPrint("--------------------------------------------------");
      debugPrint("🚀 [API $method] $url");
      if (token != null) debugPrint("🔑 TOKEN: ${token.length > 15 ? '${token.substring(0, 15)}...' : token}");
      if (body != null) debugPrint("📦 BODY: ${jsonEncode(body)}");
    }
  }

  void _logResponse(String method, String url, int statusCode, String responseBody) {
    if (kDebugMode) {
      debugPrint("📊 [$method $statusCode] $url");
      debugPrint("📥 RESPONSE: $responseBody");
      debugPrint("--------------------------------------------------");
    }
  }

  void _logError(String method, String url, Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint("❌ [API $method ERROR] $url => $error");
      if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
      debugPrint("--------------------------------------------------");
    }
  }

  String _friendlyRequestError(Object error) {
    final value = error.toString().toLowerCase();
    if (value.contains('timeout')) {
      return 'The request took too long. Please try again.';
    }
    if (value.contains('socket') ||
        value.contains('network') ||
        value.contains('connection') ||
        value.contains('host lookup')) {
      return 'Please check your internet connection and try again.';
    }
    return 'We could not complete your request. Please try again.';
  }
}
