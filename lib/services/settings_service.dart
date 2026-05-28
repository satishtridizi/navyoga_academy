// lib/services/settings_service.dart

import 'package:navyoga_academy/models/settings_privacy_option_model.dart';

import '../api/api_constants.dart';
import '../api/api_service.dart';

class SettingsService {
  final ApiService _api = ApiService();

  List<PrivacyOption> fetchPrivacyOptions() {
    return [
      PrivacyOption(title: "Download My Data"),
      PrivacyOption(title: "Privacy Policy"),
      PrivacyOption(title: "Terms of Service"),
      PrivacyOption(title: "Delete Account", isDanger: true),
    ];
  }

  /// CHANGE PASSWORD
  Future<dynamic> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.changePassword}",
      token: token,
      body: {"currentPassword": currentPassword, "newPassword": newPassword},
    );
  }

  /// DELETE ACCOUNT
  Future<dynamic> deleteAccount(String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.deleteAccount}",
      token: token,
    );
  }

  /// EXPORT / DOWNLOAD MY DATA
  Future<dynamic> downloadMyData(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.downloadData}",
      token: token,
    );
  }
}
