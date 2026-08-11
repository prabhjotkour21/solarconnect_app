import 'api_service.dart';

class SettingsService {
  SettingsService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> getProfile(String token) async {
    return _apiService.get('/settings/profile', token: token);
  }

  Future<Map<String, dynamic>> updateProfile(String token, {required Map<String, dynamic> data}) async {
    return _apiService.put('/settings/profile', body: data, token: token);
  }

  Future<Map<String, dynamic>> getNotificationSettings(String token) async {
    return _apiService.get('/settings/notifications', token: token);
  }

  Future<Map<String, dynamic>> updateNotificationSettings(
    String token, {
    required bool notifications,
    String? theme,
    String? language,
  }) async {
    final Map<String, dynamic> body = {
      'notifications': notifications,
      if (theme != null) 'theme': theme,
      if (language != null) 'language': language,
    };
    return _apiService.put('/settings/notifications', body: body, token: token);
  }

  Future<Map<String, dynamic>> getPrivacySettings(String token) async {
    return _apiService.get('/settings/privacy', token: token);
  }

  Future<Map<String, dynamic>> updatePrivacySettings(
    String token, {
    bool? allowDataSharing,
    bool? analyticsOptIn,
  }) async {
    final Map<String, dynamic> body = {
      if (allowDataSharing != null) 'allowDataSharing': allowDataSharing,
      if (analyticsOptIn != null) 'analyticsOptIn': analyticsOptIn,
    };
    return _apiService.put('/settings/privacy', body: body, token: token);
  }

  Future<Map<String, dynamic>> getAppearanceSettings(String token) async {
    return _apiService.get('/settings/appearance', token: token);
  }

  Future<Map<String, dynamic>> updateAppearanceSettings(
    String token, {
    String? theme,
    String? language,
  }) async {
    final Map<String, dynamic> body = {
      if (theme != null) 'theme': theme,
      if (language != null) 'language': language,
    };
    return _apiService.put('/settings/appearance', body: body, token: token);
  }
}
