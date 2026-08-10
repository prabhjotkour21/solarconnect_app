import 'api_service.dart';

class PowerCutService {
  PowerCutService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> getPowerCuts(
    String inverterId,
    String token, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _apiService.get(
      '/inverters/$inverterId/power-cuts',
      queryParams: queryParams,
      token: token,
    );
  }

  Future<Map<String, dynamic>> createPowerCut(
    String inverterId,
    String token, {
    required Map<String, dynamic> body,
  }) async {
    return _apiService.post(
      '/inverters/$inverterId/power-cuts',
      body: body,
      token: token,
    );
  }

  Future<Map<String, dynamic>> getPowerCutStatistics(
    String inverterId,
    String token, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _apiService.get(
      '/inverters/$inverterId/power-cuts/statistics',
      queryParams: queryParams,
      token: token,
    );
  }
}
