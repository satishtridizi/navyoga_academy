

import '../api/api_constants.dart';
import '../api/api_service.dart';

class EmployeeService {
  final ApiService _api = ApiService();


  Future<dynamic> getEmployees(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.employees}",
      token: token,
    );
  }


  Future<dynamic> getEmployeeById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.employees}/$id",
      token: token,
    );
  }


  Future<dynamic> createEmployee(
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.employees}",
      body: data,
      token: token,
    );
  }


  Future<dynamic> updateEmployee(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.employees}/$id",
      body: data,
      token: token,
    );
  }


  Future<dynamic> deleteEmployee(String id, String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.employees}/$id",
      token: token,
    );
  }
}
