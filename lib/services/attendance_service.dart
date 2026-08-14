import '../api/api_constants.dart';
import '../api/api_service.dart';
import '../models/student_attendance_model.dart';

class AttendanceException implements Exception {
  const AttendanceException(this.message);
  final String message;

  @override
  String toString() => message;
}

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
  // Future<List> getAttendance(String token) async {
  //   final results = await Future.wait([
  //     getFrontlineAttendance(token),
  //     getOperationsAttendance(token),
  //   ]);

  //   final frontline = results[0];
  //   final operations = results[1];

  //   if (frontline["unauthorized"] == true ||
  //       operations["unauthorized"] == true) {
  //     throw Exception("UNAUTHORIZED");
  //   }

  //   return [...(frontline["data"] ?? []), ...(operations["data"] ?? [])];
  // }
  Future<StudentAttendanceResponse> getAttendance(String token) async {
    final response = await _api.getRequest(
      url: ApiConstants.studentClassAttendanceUrl,
      token: token,
    );

    if (response is! Map || response['success'] != true) {
      throw AttendanceException(
        response is Map
            ? response['message']?.toString() ?? 'Unable to load attendance.'
            : 'The server returned an invalid attendance response.',
      );
    }

    final data = response['data'];
    if (data is! Map) {
      throw const AttendanceException('Attendance data was not found.');
    }

    return StudentAttendanceResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}
