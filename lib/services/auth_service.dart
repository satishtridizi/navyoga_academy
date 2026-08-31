import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';

import '../api/api_constants.dart';
import '../api/api_service.dart';

class AuthService {
  final ApiService _api = ApiService();


Future<dynamic> studentLogin({
  required String email,
  required String password,
}) async {
  final url = "${ApiConstants.baseUrl}/api/auth/student/login";

  final payload = {
    "email": email,
    "password": password,
  };

  debugPrint("════════════ API REQUEST ════════════");
  debugPrint("URL     : $url");
  debugPrint("METHOD  : POST");
  debugPrint("PAYLOAD : ${jsonEncode(payload)}");
  debugPrint("═════════════════════════════════════");

  final response = await _api.postRequest(
    url: url,
    body: payload,
  );

  debugPrint("════════════ API RESPONSE ═══════════");
  debugPrint("URL      : $url");
  debugPrint("RESPONSE : ${jsonEncode(response)}");
  debugPrint("═════════════════════════════════════");

  if (response["success"] == true &&
      response["data"] != null &&
      response["data"]["token"] != null) {
    await AuthManager.saveToken(
      response["data"]["token"],
    );

    debugPrint("TOKEN SAVED SUCCESSFULLY");
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
        if (referralCode != null && referralCode.trim().isNotEmpty)
          "referredByCode": referralCode.trim(),
      },
    );

    return response;
  }

  Future<dynamic> sendPasswordResetOtp({required String phone}) {
    return _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/otp/send",
      body: {"phone": phone, "purpose": "PASSWORD_RESET"},
    );
  }

  Future<dynamic> verifyPasswordResetOtp({
    required String phone,
    required String code,
  }) {
    return _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/otp/verify",
      body: {
        "phone": phone,
        "purpose": "PASSWORD_RESET",
        "code": code,
      },
    );
  }

  Future<dynamic> resetPassword({
    required String phone,
    required String accessToken,
    required String newPassword,
  }) {
    return _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/forgot-password",
      body: {
        "phone": phone,
        "accessToken": accessToken,
        "newPassword": newPassword,
      },
    );
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


  Future<dynamic> verifyPhone({
    required String token,
    required String accessToken,
  }) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/verify-phone",
      token: token,
      body: {"accessToken": accessToken},
    );
  }
}
