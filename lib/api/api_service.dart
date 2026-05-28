import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:navyoga_academy/utils/auth_manager.dart';

class ApiService {
  /// ================= POST =================
  Future<dynamic> postRequest({
    required String url,

    required Map<String, dynamic> body,

    String? token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),

            headers: {
              "Content-Type": "application/json",

              if (token != null) "Authorization": "Bearer $token",
            },

            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      // ✅ SUCCESS
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      // ❗ HANDLE ERRORS
      if (response.statusCode == 400) {
        return {
          "success": false,
          "message": data["message"] ?? "Invalid input",
        };
      }

      if (response.statusCode == 401) {
        return {"success": false, "message": "Unauthorized"};
      }

      return {
        "success": false,
        "message": data["message"] ?? "Something went wrong",
      };
    }
    // NETWORK / TIMEOUT / OTHER ERRORS
    on Exception catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ================= GET =================
  Future<dynamic> getRequest({required String url, String? token}) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 401) {
        // 🔥 AUTO LOGOUT
        await AuthManager.clearToken();

        return {
          "success": false,
          "unauthorized": true,
          "message": "Session expired",
        };
      }

      // ✅ HANDLE FORBIDDEN (ROLE ISSUE)
      if (response.statusCode == 403) {
        return {"success": false, "message": "Access denied for this role"};
      }

      // ✅ HANDLE NOT FOUND
      if (response.statusCode == 404) {
        return {"success": false, "message": "API not found"};
      }

      // ✅ SUCCESS
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      // ❗ DEFAULT ERROR
      return {
        "success": false,
        "message": data["message"] ?? "Something went wrong",
      };
    }
    // NETWORK / TIMEOUT / OTHER ERRORS
    on Exception catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ================= PUT =================
  Future<dynamic> putRequest({
    required String url,

    required Map<String, dynamic> body,

    String? token,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(url),

            headers: {
              "Content-Type": "application/json",

              if (token != null) "Authorization": "Bearer $token",
            },

            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      /// SUCCESS
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      /// SERVER ERROR
      return {
        "success": false,

        "message": data["message"] ?? "Something went wrong",
      };
    }
    /// NETWORK ERROR
    on Exception catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<dynamic> patchRequest({
    required String url,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      // ✅ SUCCESS
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      // ❗ UNAUTHORIZED
      if (response.statusCode == 401) {
        await AuthManager.clearToken();

        return {
          "success": false,
          "unauthorized": true,
          "message": "Session expired",
        };
      }

      // ❗ FORBIDDEN
      if (response.statusCode == 403) {
        return {"success": false, "message": "Access denied"};
      }

      // ❗ NOT FOUND
      if (response.statusCode == 404) {
        return {"success": false, "message": "API not found"};
      }

      // ❗ BAD REQUEST
      if (response.statusCode == 400) {
        return {
          "success": false,
          "message": data["message"] ?? "Invalid input",
        };
      }

      // ❗ DEFAULT ERROR
      return {
        "success": false,
        "message": data["message"] ?? "Something went wrong",
      };
    } on Exception catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<dynamic> deleteRequest({
    required String url,
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }
}
