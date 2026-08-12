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
    String? city,
    String? country,
    String? gender,
    int? age,
    String? bloodGroup,
    String? emergencyContact,
    String? medicalConditions,
    String? yogaExperience,
    String? currentLevel,
    String? areasOfInterest,
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'city': _clean(city),
      'country': _clean(country),
      'gender': _clean(gender),
      'age': age,
      'bloodGroup': _clean(bloodGroup),
      'emergencyContact': _clean(emergencyContact),
      'medicalConditions': _clean(medicalConditions),
      'yogaExperience': _clean(yogaExperience),
      'currentLevel': _clean(currentLevel),
      'areasOfInterest': _clean(areasOfInterest),
    }..removeWhere((key, value) => value == null);

    return _api.patchRequest(
      url: '${ApiConstants.baseUrl}/api/auth/student/me',
      token: token,
      body: body,
    );
  }

  Future<Map<String, dynamic>> uploadProfileImage({
    required String token,
    required File imageFile,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConstants.baseUrl}/api/auth/student/profile-image',
      ),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    Map<String, dynamic> decoded;

    try {
      final raw = jsonDecode(response.body);
      decoded = raw is Map
          ? Map<String, dynamic>.from(raw)
          : <String, dynamic>{
              'success': false,
              'message': 'Invalid server response.',
            };
    } catch (_) {
      decoded = <String, dynamic>{
        'success': false,
        'message': 'Unable to read the server response.',
      };
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      decoded['success'] = false;
      decoded['message'] ??=
          'Profile image upload failed (${response.statusCode}).';
    }

    return decoded;
  }

  String? _clean(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
