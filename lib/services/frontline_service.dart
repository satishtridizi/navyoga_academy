

import '../api/api_constants.dart';
import '../api/api_service.dart';

class FrontlineService {
  final ApiService _api = ApiService();


  Future<dynamic> getFrontlineStaff(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.frontline}",
      token: token,
    );
  }


  Future<dynamic> getFrontlineById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.frontline}/$id",
      token: token,
    );
  }


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


  Future<dynamic> deleteFrontline(String id, String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.frontline}/$id",
      token: token,
    );
  }
}
