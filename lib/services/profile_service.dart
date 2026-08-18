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
    final filename = imageFile.uri.pathSegments.last;
    final extension = filename.split('.').last.toLowerCase();
    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final presignResponse = await _api.postRequest(
      url: '${ApiConstants.baseUrl}/api/auth/student/me/avatar-presign',
      token: token,
      body: {
        'filename': filename,
        'contentType': contentType,
      },
    );

    if (presignResponse is! Map || presignResponse['success'] != true) {
      return <String, dynamic>{
        'success': false,
        'message': presignResponse is Map
            ? presignResponse['message']?.toString() ??
                'Unable to prepare the profile image upload.'
            : 'Unable to prepare the profile image upload.',
      };
    }

    final rawData = presignResponse['data'];
    final data = rawData is Map ? rawData : presignResponse;
    final uploadUrl = data['url']?.toString();
    final storePath = data['storePath']?.toString();

    if (uploadUrl == null || storePath == null) {
      return {
        'success': false,
        'message': 'The server returned incomplete upload information.',
      };
    }

    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: await imageFile.readAsBytes(),
    );

    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      return {
        'success': false,
        'message': 'Profile image upload failed (${uploadResponse.statusCode}).',
      };
    }

    final updateResponse = await _api.patchRequest(
      url: '${ApiConstants.baseUrl}/api/auth/student/me',
      token: token,
      body: {'avatar': storePath},
    );

    if (updateResponse is Map) {
      return Map<String, dynamic>.from(updateResponse);
    }
    return {
      'success': false,
      'message': 'Unable to save the new profile image.',
    };
  }

  String? _clean(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
