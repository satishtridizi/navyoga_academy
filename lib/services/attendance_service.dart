import '../api/api_constants.dart';
import '../api/api_service.dart';

class AttendanceService {
  final ApiService _api = ApiService();

  Future<dynamic> getFrontlineAttendance(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/attendance/frontline/me",
      token: token,
    );
  }

  Future<dynamic> getOperationsAttendance(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/api/attendance/operations/me",
      token: token,
    );
  }

  // ✅ ADD THIS
  Future<List> getAttendance(String token) async {
    final results = await Future.wait([
      getFrontlineAttendance(token),
      getOperationsAttendance(token),
    ]);

    final frontline = results[0];
    final operations = results[1];

    if (frontline["unauthorized"] == true ||
        operations["unauthorized"] == true) {
      throw Exception("UNAUTHORIZED");
    }

    return [...(frontline["data"] ?? []), ...(operations["data"] ?? [])];
  }
}
