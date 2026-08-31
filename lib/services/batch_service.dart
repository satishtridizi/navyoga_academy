

import '../api/api_constants.dart';
import '../api/api_service.dart';

class BatchService {
  final ApiService _api = ApiService();


  Future<dynamic> getBatches(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.batches}",
      token: token,
    );
  }


  Future<dynamic> getBatchById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.batches}/$id",
      token: token,
    );
  }


  Future<dynamic> createBatch(Map<String, dynamic> data, String token) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.batches}",
      body: data,
      token: token,
    );
  }


  Future<dynamic> updateBatch(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.batches}/$id",
      body: data,
      token: token,
    );
  }


  Future<dynamic> deleteBatch(String id, String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.batches}/$id",
      token: token,
    );
  }
}
