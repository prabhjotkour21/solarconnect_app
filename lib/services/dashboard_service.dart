import 'api_service.dart';

class DashboardService {
  DashboardService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> getOverview(String token) async {
    return _apiService.get('/dashboard/overview', token: token);
  }

  Future<List<dynamic>> getWeeklySummary(String token) async {
    final response = await _apiService.get('/dashboard/weekly-summary', token: token);
    return response['data'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> getMetrics(String token) async {
    return _apiService.get('/dashboard/metrics', token: token);
  }
}
