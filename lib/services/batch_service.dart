// lib/services/batch_service.dart

import '../api/api_constants.dart';
import '../api/api_service.dart';

class BatchService {
  final ApiService _api = ApiService();

  /// GET ALL BATCHES
  Future<dynamic> getBatches(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.batches}",
      token: token,
    );
  }

  /// GET SINGLE BATCH
  Future<dynamic> getBatchById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.batches}/$id",
      token: token,
    );
  }

  /// CREATE BATCH
  Future<dynamic> createBatch(Map<String, dynamic> data, String token) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.batches}",
      body: data,
      token: token,
    );
  }

  /// UPDATE BATCH
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

  /// DELETE BATCH
  Future<dynamic> deleteBatch(String id, String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.batches}/$id",
      token: token,
    );
  }
}
