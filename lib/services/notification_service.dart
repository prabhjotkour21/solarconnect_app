import 'api_service.dart';

class NotificationService {
  NotificationService(this._apiService);

  final ApiService _apiService;

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

  Future<Map<String, dynamic>> updatePreferences(
    String token, {
    required bool notifications,
  }) async {
    return _apiService.post(
      '/notifications/preferences',
      body: {'notifications': notifications},
      token: token,
    );
  }
}
