import '../api/api_constants.dart';
import '../api/api_service.dart';

class PaymentsService {
  final ApiService _api = ApiService();

  Future<dynamic> getMyYttRecordedEnrollments(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/ytt-recorded/my-enrollments",
      token: token,
    );
  }
}
