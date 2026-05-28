// lib/services/frontline_service.dart

import '../api/api_constants.dart';
import '../api/api_service.dart';

class FrontlineService {
  final ApiService _api = ApiService();

  /// GET ALL FRONTLINE STAFF
  Future<dynamic> getFrontlineStaff(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.frontline}",
      token: token,
    );
  }

  /// GET SINGLE FRONTLINE STAFF MEMBER
  Future<dynamic> getFrontlineById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.frontline}/$id",
      token: token,
    );
  }

  /// CREATE FRONTLINE STAFF
  Future<dynamic> createFrontline(
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.frontline}",
      body: data,
      token: token,
    );
  }

  /// UPDATE FRONTLINE STAFF
  Future<dynamic> updateFrontline(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.frontline}/$id",
      body: data,
      token: token,
    );
  }

  /// DELETE FRONTLINE STAFF
  Future<dynamic> deleteFrontline(String id, String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.frontline}/$id",
      token: token,
    );
  }
}
