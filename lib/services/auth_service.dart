import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_constants.dart';
import '../api/api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<dynamic> studentLogin({
    required String email,

    required String password,
  }) async {
    final response = await _api.postRequest(
      url: "${ApiConstants.baseUrl}/auth/superadmin/login",

      body: {"email": email, "password": password},
    );

    print(response);

    if (response["success"] == true &&
        response["data"] != null &&
        response["data"]["token"] != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        "token",
        response["data"]["token"], // ✅ FIXED
      );
    }

    return response;
  }

  Future<dynamic> getProfile(String token) async {
    final response = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/auth/superadmin/me",
      token: token,
    );

    return response;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
  }
}
