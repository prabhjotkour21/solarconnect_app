import 'api_service.dart';

class EnergyService {
  EnergyService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> getReadings(
    String token, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _apiService.get('/energy/readings', queryParams: queryParams, token: token);
  }

  Future<Map<String, dynamic>> getDailySummary(
    String token, {
    String? day,
  }) async {
    final params = <String, dynamic>{};
    if (day != null && day.isNotEmpty) {
      params['day'] = day;
    }
    return _apiService.get('/energy/daily-summary', queryParams: params.isEmpty ? null : params, token: token);
  }

  Future<Map<String, dynamic>> getStatistics(String token) async {
    return _apiService.get('/energy/statistics', token: token);
  }

  Future<Map<String, dynamic>> getTrends(
    String token, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _apiService.get('/energy/trends', queryParams: queryParams, token: token);
  }

  Future<Map<String, dynamic>> getTrendComparison(
    String token, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _apiService.get('/energy/trends/comparison', queryParams: queryParams, token: token);
  }

  Future<Map<String, dynamic>> getTrendReport(
    String token, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _apiService.get('/energy/trends/report', queryParams: queryParams, token: token);
  }
}
