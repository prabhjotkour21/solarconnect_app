import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// App-wide constants.
///
/// Rule: if a value appears more than once, it belongs here.
abstract class AppConstants {
  // ── App identity ───────────────────────────────────────────────────────────
  static const String appName = 'SolarConnect';
  static const String appVersion = '1.0.0';

  // ── API configuration ────────────────────────────────────────────────────
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/v1';
      //192.168.1.5
      //return 'http://192.168.1.5:3000/api/v1';
    }
    return 'http://localhost:5000/api/v1';
  }

  static String get websocketUrl {
    final uri = Uri.parse(apiBaseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final host = uri.host;
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '$scheme://$host$port/energy';
  }

  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // ── Animation durations ────────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // ── Layout ────────────────────────────────────────────────────────────────
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;

  // ── Demo / mock data refresh interval ────────────────────────────────────
  static const Duration mockRefreshInterval = Duration(seconds: 5);
}
