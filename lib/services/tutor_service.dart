

import '../api/api_constants.dart';
import '../api/api_service.dart';

class TutorService {
  final ApiService _api = ApiService();


  Future<dynamic> getTutors(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.tutors}",
      token: token,
    );
  }


  Future<dynamic> getTutorById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.tutors}/$id",
      token: token,
    );
  }


  Future<dynamic> getMyTutorProfile(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/auth/tutor/me",
      token: token,
    );
  }


  Future<dynamic> createTutor(Map<String, dynamic> data, String token) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.tutors}",
      body: data,
      token: token,
    );
  }


  Future<dynamic> updateTutor(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _api.patchRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.tutors}/$id",
      body: data,
      token: token,
    );
  }


  Future<dynamic> deleteTutor(String id, String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.tutors}/$id",
      token: token,
    );
  }
}
