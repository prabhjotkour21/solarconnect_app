import 'api_service.dart';

class InverterService {
  InverterService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> pairInverter({
    required String serialNumber,
    required String model,
    required String brand,
    String? location,
    String? firmwareVersion,
    required String token,
  }) async {
    final body = {
      'serialNumber': serialNumber,
      'model': model,
      'brand': brand,
      if (location != null && location.isNotEmpty) 'location': location,
      if (firmwareVersion != null && firmwareVersion.isNotEmpty) 'firmwareVersion': firmwareVersion,
    };
    return _apiService.post(
      '/inverters/pair',
      body: body,
      token: token,
    );
  }

  Future<Map<String, dynamic>> getInverters(String token) async {
    return _apiService.get('/inverters', token: token);
  }

  Future<Map<String, dynamic>> getInverterById(String id, String token) async {
    return _apiService.get('/inverters/$id', token: token);
  }

  Future<Map<String, dynamic>> updateInverter(String id, String token, {required Map<String, dynamic> data}) async {
    return _apiService.put('/inverters/$id', body: data, token: token);
  }

  Future<Map<String, dynamic>> deleteInverter(String id, String token) async {
    return _apiService.delete('/inverters/$id', token: token);
  }

  Future<Map<String, dynamic>> unpairInverter(String id, String token) async {
    return _apiService.post('/inverters/$id/unpair', token: token);
  }

  Future<Map<String, dynamic>> getInverterStatus(String id, String token) async {
    return _apiService.get('/inverters/$id/status', token: token);
  }

  Future<Map<String, dynamic>> getSavingsHistory(
    String id,
    String token, {
    Map<String, String>? queryParams,
  }) async {
    return _apiService.get(
      '/inverters/$id/savings/history',
      queryParams: queryParams,
      token: token,
    );
  }
}
