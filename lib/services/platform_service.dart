// lib/services/platform_service.dart

import '../api/api_constants.dart';
import '../api/api_service.dart';

class PlatformService {
  final ApiService _api = ApiService();

  /// GET PLATFORM CONFIG / SETTINGS
  Future<dynamic> getPlatformConfig(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.platform}/config",
      token: token,
    );
  }

  /// UPDATE PLATFORM CONFIG
  Future<dynamic> updatePlatformConfig(
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.platform}/config",
      body: data,
      token: token,
    );
  }

  /// GET PLATFORM STATS (active users, revenue, sessions)
  Future<dynamic> getPlatformStats(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.platform}/stats",
      token: token,
    );
  }
}
