import 'api_service.dart';

class ParameterService {
  ParameterService(this._apiService);
  final ApiService _apiService;

  Future<Map<String, dynamic>> loadDefinitions(String deviceId, String token) => _apiService.post('/devices/$deviceId/parameters/load', token: token);
  Future<Map<String, dynamic>> getCurrentValues(String deviceId, String token) => _apiService.post('/devices/$deviceId/parameters/current-values', token: token);
  Future<Map<String, dynamic>> validateParameters(String deviceId, String token, List<Map<String, dynamic>> items) => _apiService.post('/devices/$deviceId/parameters/validate', token: token, body: {'items': items});
  Future<Map<String, dynamic>> sendParameter(String deviceId, String token, {required int parameterNumber, required String value}) => _apiService.post(
    '/devices/$deviceId/parameters/send',
    token: token,
    body: {'parameterNumber': parameterNumber, 'value': value},
  );
}