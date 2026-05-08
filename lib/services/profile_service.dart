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
    final response = await _api.putRequest(
      url: "${ApiConstants.baseUrl}/profile",

      token: token,

      body: {"name": name, "email": email, "phone": phone, "address": address},
    );

    return response;
  }
}
