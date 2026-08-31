import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? prefs.getString("access_token");
    return token;
  }


  static Future<String?> getUserId() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is! Map) return null;
      final id = payload['sub'] ?? payload['id'] ?? payload['userId'];
      return id?.toString();
    } catch (_) {
      return null;
    }
  }


  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("access_token", token);
  }


  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("access_token");
  }
}
