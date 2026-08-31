

import '../api/api_constants.dart';
import '../api/api_service.dart';

class FinancialService {
  final ApiService _api = ApiService();


  Future<dynamic> getFinancialSummary(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.financials}/summary",
      token: token,
    );
  }


  Future<dynamic> getTransactions(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.financials}/transactions",
      token: token,
    );
  }


  Future<dynamic> getTransactionById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.financials}/transactions/$id",
      token: token,
    );
  }


  Future<dynamic> getRevenueReport(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.financials}/revenue",
      token: token,
    );
  }
}
