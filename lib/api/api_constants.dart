// lib/api/api_constants.dart

class ApiConstants {
  static const baseUrl = "http://10.0.2.2:5001";

  // existing
  static const String leads = "/leads";

  // new
  static const String batches = "/api/batches";
  static const String employees = "/api/employees";
  static const String financials = "/api/financials";
  static const String frontline = "/api/frontline";
  static const String platform = "/api/platform";
  static const String students = "/api/students";
  static const String tutors = "/api/tutors";
  static const String workshops = "/api/workshops";
  static const String changePassword = "/api/auth/student/change-password";
  static const String deleteAccount = "/api/auth/student/delete";
  static const String downloadData = "/api/auth/student/export";
}
