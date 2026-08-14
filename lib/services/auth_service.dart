import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../utils/app_constants.dart';
import 'api_service.dart';

class AuthService {
  AuthService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await _apiService.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    await _persistAuth(response);
    return response;
  }

  Future<Map<String, dynamic>> logout(String token) async {
    final response = await _apiService.post('/auth/logout', token: token);
    await clearStoredAuth();
    return response;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _apiService.post('/auth/refresh', body: {
      'refreshToken': refreshToken,
    });

    await _persistAuth(response);
    return response;
  }

  Future<Map<String, dynamic>> getMe(String token) async {
    return _apiService.get('/auth/me', token: token);
  }

  Future<Map<String, dynamic>?> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.userDataKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.authTokenKey);
  }

  Future<String?> getStoredRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  Future<void> clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }

  Future<void> _persistAuth(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();

    final token = response['accessToken']?.toString();
    final refresh = response['refreshToken']?.toString();
    final userData = response['user'] ?? response['data'];

    debugPrint('AuthService._persistAuth accessToken: $token');

    if (token != null && token.isNotEmpty) {
      await prefs.setString(AppConstants.authTokenKey, token);
    }

    if (refresh != null && refresh.isNotEmpty) {
      await prefs.setString(AppConstants.refreshTokenKey, refresh);
    }

    if (userData != null) {
      final encoded = jsonEncode(userData is Map ? userData : {'data': userData});
      await prefs.setString(AppConstants.userDataKey, encoded);
    }
  }
}
