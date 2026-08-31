

import '../api/api_constants.dart';
import '../api/api_service.dart';

class WorkshopService {
  final ApiService _api = ApiService();


  Future<dynamic> getWorkshops(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.workshops}/my-enrollments",
      token: token,
    );
  }


  Future<dynamic> getWorkshopById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.workshops}/$id",
      token: token,
    );
  }


  Future<dynamic> createWorkshop(
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.workshops}",
      body: data,
      token: token,
    );
  }


  Future<dynamic> updateWorkshop(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.workshops}/$id",
      body: data,
      token: token,
    );
  }


  Future<dynamic> deleteWorkshop(String id, String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.workshops}/$id",
      token: token,
    );
  }


  Future<dynamic> enrollWorkshop(String id, String token) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.workshops}/$id/enrollment",
      body: {},
      token: token,
    );
  }
}
