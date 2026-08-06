import 'api_service.dart';

class DashboardService {
  DashboardService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> getOverview(String token) async {
    return _apiService.get('/dashboard/overview', token: token);
  }

  Future<Map<String, dynamic>> getWeeklySummary(String token) async {
    return _apiService.get('/dashboard/weekly-summary', token: token);
  }

  Future<Map<String, dynamic>> getMetrics(String token) async {
    return _apiService.get('/dashboard/metrics', token: token);
  }
}
