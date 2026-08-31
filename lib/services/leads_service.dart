import '../api/api_service.dart';
import '../api/api_constants.dart';

class LeadsService {
  final ApiService _apiService = ApiService();


  Future<dynamic> getLeads(String token) async {
    return await _apiService.getRequest(
      url: ApiConstants.baseUrl + ApiConstants.leads,
      token: token,
    );
  }


  Future<dynamic> getLeadById(String id, String token) async {
    return await _apiService.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.leads}/$id",
      token: token,
    );
  }


  Future<dynamic> createLead(Map<String, dynamic> data, String token) async {
    return await _apiService.postRequest(
      url: ApiConstants.baseUrl + ApiConstants.leads,
      body: data,
      token: token,
    );
  }


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
