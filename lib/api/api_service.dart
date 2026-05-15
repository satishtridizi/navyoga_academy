import 'dart:convert';

import 'package:http/http.dart' as http;

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
    /// TIMEOUT
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
    required String token,
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
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
