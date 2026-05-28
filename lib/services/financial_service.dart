// lib/services/financial_service.dart

import '../api/api_constants.dart';
import '../api/api_service.dart';

class FinancialService {
  final ApiService _api = ApiService();

  /// GET FINANCIAL SUMMARY (revenue, expenses, etc.)
  Future<dynamic> getFinancialSummary(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.financials}/summary",
      token: token,
    );
  }

  /// GET ALL TRANSACTIONS
  Future<dynamic> getTransactions(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.financials}/transactions",
      token: token,
    );
  }

  /// GET SINGLE TRANSACTION
  Future<dynamic> getTransactionById(String id, String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.financials}/transactions/$id",
      token: token,
    );
  }

  /// GET REVENUE REPORT (e.g. monthly breakdown)
  Future<dynamic> getRevenueReport(String token) async {
    return await _api.getRequest(
      url: "${ApiConstants.baseUrl}${ApiConstants.financials}/revenue",
      token: token,
    );
  }
}
