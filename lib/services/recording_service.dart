import '../api/api_constants.dart';
import '../api/api_service.dart';

class RecordingService {
  final ApiService _api = ApiService();

  Future<List> getRecordings(String token) async {
    final res = await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/ytt-recorded",
      token: token,
    );

    print("RECORDINGS RESPONSE");
    print(res);

    if (res["unauthorized"] == true) {
      throw Exception("UNAUTHORIZED");
    }

    if (res["success"] == true) {
      return (res["data"] as List?) ?? [];
    }

    return [];
  }
}
