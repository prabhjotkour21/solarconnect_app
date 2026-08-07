import 'api_service.dart';

class DeviceService {
  DeviceService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> registerDevice({
    required String serialNumber,
    required String macAddress,
    String? firmwareVersion,
    String? location,
    String? description,
    required String token,
  }) async {
    return _apiService.post(
      '/devices/register',
      body: {
        'serialNumber': serialNumber,
        'macAddress': macAddress,
        if (firmwareVersion != null && firmwareVersion.isNotEmpty) 'firmwareVersion': firmwareVersion,
        if (location != null && location.isNotEmpty) 'location': location,
        if (description != null && description.isNotEmpty) 'description': description,
      },
      token: token,
    );
  }

  Future<Map<String, dynamic>> getDevices(String token) async {
    return _apiService.get('/devices', token: token);
  }
}
