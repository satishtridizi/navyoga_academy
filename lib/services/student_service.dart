

import '../api/api_constants.dart';
import '../api/api_service.dart';

class StudentService {
  final ApiService _api = ApiService();


  Future<dynamic> getStudents(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.students}",
      token: token,
    );
  }


  Future<dynamic> getStudentById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.students}/$id",
      token: token,
    );
  }


  Future<dynamic> createStudent(Map<String, dynamic> data, String token) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.students}",
      body: data,
      token: token,
    );
  }


  Future<dynamic> updateStudent(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.students}/$id",
      body: data,
      token: token,
    );
  }


  Future<dynamic> deleteStudent(String id, String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.students}/$id",
      token: token,
    );
  }
}
