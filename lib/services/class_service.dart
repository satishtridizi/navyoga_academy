import '../api/api_constants.dart';
import '../api/api_service.dart';

class ClassService {
  final ApiService _api = ApiService();

  /// GET CLASSES
  Future<dynamic> getClasses(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/classes",
      token: token,
    );
  }

  /// GET BATCHES
  Future<dynamic> getBatches(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/batch",
      token: token,
    );
  }

  /// GET WORKSHOPS
  Future<dynamic> getWorkshops(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}/workshop",
      token: token,
    );
  }
}
