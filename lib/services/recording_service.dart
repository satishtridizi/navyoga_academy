import '../api/api_constants.dart';
import '../api/api_service.dart';

class RecordingService {
  final ApiService _api = ApiService();

  Future<dynamic> getRecordings(String token) async {
    final response = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/recordings",

      token: token,
    );

    return response;
  }
}
