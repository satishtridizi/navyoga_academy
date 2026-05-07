import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<dynamic> postRequest({
    required String url,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse(url),

      headers: {
        "Content-Type": "application/json",

        if (token != null) "Authorization": "Bearer $token",
      },

      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<dynamic> getRequest({required String url, String? token}) async {
    final response = await http.get(
      Uri.parse(url),

      headers: {
        "Content-Type": "application/json",

        if (token != null) "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }
}
