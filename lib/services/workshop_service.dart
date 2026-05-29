// lib/services/workshop_service.dart

import '../api/api_constants.dart';
import '../api/api_service.dart';

class WorkshopService {
  final ApiService _api = ApiService();

  /// GET ALL WORKSHOPS
  Future<dynamic> getWorkshops(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.workshops}/upcoming",
      token: token,
    );
  }

  /// GET SINGLE WORKSHOP
  Future<dynamic> getWorkshopById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.workshops}/$id",
      token: token,
    );
  }

  /// CREATE WORKSHOP
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

  /// UPDATE WORKSHOP
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

  /// DELETE WORKSHOP
  Future<dynamic> deleteWorkshop(String id, String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.workshops}/$id",
      token: token,
    );
  }

  /// ENROLL IN WORKSHOP
  Future<dynamic> enrollWorkshop(String id, String token) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.workshops}/$id/enroll",
      body: {},
      token: token,
    );
  }
}
