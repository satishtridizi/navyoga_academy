import '../api/api_service.dart';
import '../api/api_constants.dart';

class LeadsService {
  final ApiService _apiService = ApiService();

  /// GET ALL LEADS
  Future<dynamic> getLeads(String token) async {
    return await _apiService.getRequest(
      url: ApiConstants.baseUrl + ApiConstants.leads,
      token: token,
    );
  }

  /// GET SINGLE LEAD
  Future<dynamic> getLeadById(String id, String token) async {
    return await _apiService.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.leads}/$id",
      token: token,
    );
  }

  /// CREATE LEAD
  Future<dynamic> createLead(Map<String, dynamic> data, String token) async {
    return await _apiService.postRequest(
      url: ApiConstants.baseUrl + ApiConstants.leads,
      body: data,
      token: token,
    );
  }

  /// UPDATE LEAD (using PUT)
  Future<dynamic> updateLead(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _apiService.patchRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.leads}/$id",
      body: data,
      token: token,
    );
  }
}
