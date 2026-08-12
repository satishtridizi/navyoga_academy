import '../api/api_constants.dart';
import '../api/api_service.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiService _apiService;

  DashboardService({
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService();

  Future<DashboardModel> getDashboard({
    required String token,
  }) async {
    final dynamic response = await _apiService.getRequest(
      url: ApiConstants.studentDashboardUrl,
      token: token,
    );

    if (response is! Map) {
      throw const DashboardException(
        'Invalid dashboard response.',
      );
    }

    final result = Map<String, dynamic>.from(response);

    if (result['unauthorized'] == true) {
      throw const DashboardUnauthorizedException(
        'Your session has expired.',
      );
    }

    if (result['success'] != true) {
      throw DashboardException(
        result['message']?.toString() ??
            'Unable to load dashboard.',
      );
    }

    final data = result['data'];

    if (data is! Map) {
      throw const DashboardException(
        'Dashboard data is missing.',
      );
    }

    return DashboardModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}

class DashboardException implements Exception {
  final String message;

  const DashboardException(this.message);

  @override
  String toString() => message;
}

class DashboardUnauthorizedException
    extends DashboardException {
  const DashboardUnauthorizedException(super.message);
}
