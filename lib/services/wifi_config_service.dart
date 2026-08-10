import 'api_service.dart';

class WifiConfigService {
  WifiConfigService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> configureWifi(
    String inverterId,
    String token, {
    required String ssid,
    required String password,
    int? timeoutSeconds,
    bool? retry,
  }) async {
    return _apiService.post(
      '/inverters/$inverterId/wifi-config',
      body: {
        'ssid': ssid,
        'password': password,
        if (timeoutSeconds != null) 'timeoutSeconds': timeoutSeconds,
        if (retry != null) 'retry': retry,
      },
      token: token,
    );
  }
}
