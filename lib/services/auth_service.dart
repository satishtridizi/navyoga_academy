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

  Future<dynamic> logout(String token) async {
    final response = await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/logout",
      token: token,
      body: {},
    );

    await AuthManager.clearToken();

    return response;
  }

  Future<dynamic> studentRegister({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    final response = await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/register",
      body: {
        "name": name,
        "phone": phone,
        "email": email,
        "password": password,
        "referralCode": referralCode,
      },
    );

    return response;
  }

  Future<dynamic> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/change-password",
      token: token,
      body: {"currentPassword": currentPassword, "newPassword": newPassword},
    );
  }

  Future<dynamic> acceptTerms({required String token}) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/accept-terms",
      token: token,
      body: {},
    );
  }
}
