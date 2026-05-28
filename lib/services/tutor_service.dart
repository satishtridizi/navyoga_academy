// lib/services/tutor_service.dart

import '../api/api_constants.dart';
import '../api/api_service.dart';

class TutorService {
  final ApiService _api = ApiService();

  /// GET ALL TUTORS
  Future<dynamic> getTutors(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.tutors}",
      token: token,
    );
  }

  /// GET SINGLE TUTOR
  Future<dynamic> getTutorById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.tutors}/$id",
      token: token,
    );
  }

  /// GET MY TUTOR PROFILE (for logged-in tutor)
  Future<dynamic> getMyTutorProfile(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/auth/tutor/me",
      token: token,
    );
  }

  /// CREATE TUTOR
  Future<dynamic> createTutor(Map<String, dynamic> data, String token) async {
    return await _api.postRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.tutors}",
      body: data,
      token: token,
    );
  }

  /// UPDATE TUTOR
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

  /// DELETE TUTOR
  Future<dynamic> deleteTutor(String id, String token) async {
    return await _api.deleteRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.tutors}/$id",
      token: token,
    );
  }
}
