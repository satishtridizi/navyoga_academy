import 'package:navyoga_academy/utils/auth_manager.dart';

import '../api/api_constants.dart';
import '../api/api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<dynamic> studentLogin({
    required String email,

    required String password,
  }) async {
    final response = await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/login",

      body: {"email": email, "password": password},
    );

    if (response["success"] == true &&
        response["data"] != null &&
        response["data"]["token"] != null) {
      await AuthManager.saveToken(response["data"]["token"]);
    }

    return response;
  }

  Future<dynamic> getProfile(String token) async {
    final response = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/me",
      token: token,
    );

    return response;
  }

  Future<void> logout() async {
    await AuthManager.clearToken();
  }

  Future<dynamic> studentRegister({
    required String email,
    required String password,
  }) async {
    final response = await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/register",
      body: {"email": email, "password": password},
    );

    return response;
  }
}
