import 'api_service.dart';

class UserProfileService {
  UserProfileService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> getProfile(String token) async {
    return _apiService.get('/users/profile', token: token);
  }

  Future<Map<String, dynamic>> updateProfile(String token, {required Map<String, dynamic> data}) async {
    return _apiService.put('/users/profile', body: data, token: token);
  }

  Future<Map<String, dynamic>> updatePreferences(String token, {required Map<String, dynamic> data}) async {
    return _apiService.put('/users/preferences', body: data, token: token);
  }

  Future<Map<String, dynamic>> updatePassword(String token, {required Map<String, dynamic> data}) async {
    return _apiService.put('/users/password', body: data, token: token);
  }
}
