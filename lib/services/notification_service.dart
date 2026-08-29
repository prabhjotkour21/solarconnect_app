import 'api_service.dart';
import '../models/notification_preference.dart';

class NotificationService {
  NotificationService(this._apiService);

  final ApiService _apiService;

  // ==================== Notifications ==================== //
  
  Future<Map<String, dynamic>> getNotifications(
    String token, {
    Map<String, dynamic>? queryParams,
  }) async {
    return _apiService.get(
      '/notifications',
      queryParams: queryParams,
      token: token,
    );
  }

  Future<int> getUnreadCount(String token) async {
    final response = await _apiService.get('/notifications/unread-count', token: token);
    final count = response['unreadCount'];
    if (count is int) {
      return count;
    }
    if (count is String) {
      return int.tryParse(count) ?? 0;
    }
    return 0;
  }

  Future<Map<String, dynamic>> markAsRead(String id, String token) async {
    return _apiService.put('/notifications/$id/read', token: token);
  }

  Future<Map<String, dynamic>> markAllAsRead(String token) async {
    return _apiService.put('/notifications/mark-all-read', token: token);
  }

  Future<Map<String, dynamic>> deleteNotification(String id, String token) async {
    return _apiService.delete('/notifications/$id', token: token);
  }

  // ==================== Notification Preferences ==================== //

  /// Get user's notification preferences
  Future<NotificationPreference> getNotificationPreferences(String token) async {
    try {
      final response = await _apiService.get(
        '/notifications/preferences',
        token: token,
      );
      
      final data = response['data'] is Map ? response['data'] : response;
      return NotificationPreference.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      // Return default preferences if API call fails
      print('[NotificationService] Failed to fetch preferences: $e');
      return NotificationPreference.defaultPreferences();
    }
  }

  /// Update user's notification preferences
  Future<NotificationPreference> updateNotificationPreferences(
    String token, {
    required NotificationPreference preferences,
  }) async {
    final response = await _apiService.put(
      '/notifications/preferences',
      body: preferences.toJson(),
      token: token,
    );

    final data = response['data'] is Map ? response['data'] : response;
    return NotificationPreference.fromJson(data as Map<String, dynamic>);
  }

  /// Update specific notification category
  Future<Map<String, dynamic>> updateNotificationCategory(
    String token, {
    required String category, // 'alerts', 'savings', 'updates', 'systemStatus'
    required bool enabled,
  }) async {
    return _apiService.patch(
      '/notifications/preferences/category',
      body: {
        'category': category,
        'enabled': enabled,
      },
      token: token,
    );
  }

  /// Update notification delivery methods
  Future<Map<String, dynamic>> updateDeliveryMethods(
    String token, {
    bool? enableApp,
    bool? enableEmail,
    bool? enableSms,
  }) async {
    final body = <String, dynamic>{};
    if (enableApp != null) body['enableAppNotifications'] = enableApp;
    if (enableEmail != null) body['enableEmailNotifications'] = enableEmail;
    if (enableSms != null) body['enableSmsNotifications'] = enableSms;

    return _apiService.patch(
      '/notifications/preferences/delivery',
      body: body,
      token: token,
    );
  }

  /// Update quiet hours
  Future<Map<String, dynamic>> updateQuietHours(
    String token, {
    required bool enabled,
    String? startTime, // HH:mm format
    String? endTime,   // HH:mm format
  }) async {
    return _apiService.patch(
      '/notifications/preferences/quiet-hours',
      body: {
        'enabled': enabled,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
      },
      token: token,
    );
  }

  /// Update notification frequency
  Future<Map<String, dynamic>> updateNotificationFrequency(
    String token, {
    required String frequency, // 'immediate', 'daily', 'weekly', 'never'
  }) async {
    return _apiService.patch(
      '/notifications/preferences/frequency',
      body: {'frequency': frequency},
      token: token,
    );
  }

  /// Legacy method for backward compatibility
  Future<Map<String, dynamic>> updatePreferences(
    String token, {
    required bool notifications,
  }) async {
    return _apiService.post(
      '/notifications/preferences/legacy',
      body: {'notifications': notifications},
      token: token,
    );
  }
}
