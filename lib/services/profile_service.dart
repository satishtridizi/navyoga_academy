import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../api/api_constants.dart';
import '../api/api_service.dart';

class ProfileService {
  final ApiService _api = ApiService();

  Future<dynamic> updateProfile({
    required String token,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final response = await _api.patchRequest(
      url: "${ApiConstants.baseUrl}/api/auth/student/me",
      token: token,
      body: {"name": name, "email": email, "phone": phone, "address": address},
    );

    return response;
  }

  // ADD THIS METHOD
  Future<Map<String, dynamic>> uploadProfileImage({
    required String token,
    required File imageFile,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConstants.baseUrl}/api/auth/student/profile-image"),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }
}
