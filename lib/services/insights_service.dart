import 'api_service.dart';

class InsightsService {
  InsightsService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> getInsights(
    String token, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _apiService.get('/insights', queryParams: queryParams, token: token);
  }
}
