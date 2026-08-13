import 'dart:async';

import 'package:flutter/material.dart';
import '../../models/notification_item.dart';
import '../../services/service_locator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_dialogs.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  int _unreadCount = 0;
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _listenForRealtimeNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _listenForRealtimeNotifications() async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      return;
    }

    final socketService = ServiceLocator.instance.socketService;
    if (!socketService.isConnected) {
      socketService.connect(
        url: AppConstants.websocketUrl,
        token: token,
      );
    }

    _notificationSubscription = socketService.liveNotificationStream.listen((payload) {
      if (!mounted) {
        return;
      }

      final notification = NotificationItem(
        id: payload['_id']?.toString() ??
            payload['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: payload['title']?.toString() ?? 'New notification',
        description: payload['message']?.toString() ??
            payload['description']?.toString() ??
            'You have a new update from SolarConnect.',
        timestamp: DateTime.tryParse(payload['timestamp']?.toString() ?? '') ?? DateTime.now(),
        type: payload['category']?.toString() ?? 'update',
        isRead: false,
      );

      setState(() {
        final alreadyExists = _notifications.any((item) => item.id == notification.id);
        if (!alreadyExists) {
          _notifications.insert(0, notification);
          _unreadCount += 1;
        }
      });
    });
  }

  Future<void> _loadNotifications({bool refreshing = false}) async {
    if (refreshing) {
      setState(() {
        _isRefreshing = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Authentication required. Please login again.';
        _isLoading = false;
        _isRefreshing = false;
      });
      return;
    }

    try {
      final response = await ServiceLocator.instance.notificationService.getNotifications(
        token,
        queryParams: {'limit': 50},
      );

      final rawData = response['data'];
      final notifications = <NotificationItem>[];
      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map<String, dynamic>) {
            notifications.add(NotificationItem.fromJson(item));
          } else if (item is Map) {
            notifications.add(NotificationItem.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      final unreadCount = await ServiceLocator.instance.notificationService.getUnreadCount(token);

      setState(() {
        _notifications
          ..clear()
          ..addAll(notifications);
        _unreadCount = unreadCount;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _notifications.clear();
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications(refreshing: true);
  }

  Future<void> _markAllRead() async {
    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Authentication required. Please login again.');
      return;
    }

    try {
      await ServiceLocator.instance.notificationService.markAllAsRead(token);
      await _loadNotifications();
      AppDialogs.showSuccessSnackBar(context, 'All notifications marked as read.');
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _markAsRead(NotificationItem item) async {
    if (item.isRead) {
      return;
    }

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Authentication required. Please login again.');
      return;
    }

    try {
      await ServiceLocator.instance.notificationService.markAsRead(item.id, token);
      await _loadNotifications();
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _deleteNotification(NotificationItem item) async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context,
      title: 'Delete Notification',
      message: 'Are you sure you want to remove this notification?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirmed != true) {
      return;
    }

    final token = await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Authentication required. Please login again.');
      return;
    }

    try {
      await ServiceLocator.instance.notificationService.deleteNotification(item.id, token);
      await _loadNotifications();
      AppDialogs.showSuccessSnackBar(context, 'Notification deleted.');
    } catch (e) {
      AppDialogs.showErrorSnackBar(context, e.toString());
    }
  }

  String _getNotificationIcon(String type) {
    switch (type) {
      case 'alert':
        return '🚨';
      case 'saving':
        return '💰';
      case 'update':
        return 'ℹ️';
      default:
        return '📢';
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'alert':
        return AppColors.error;
      case 'saving':
        return AppColors.success;
      case 'update':
        return AppColors.primary;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Text('Notifications', style: AppTextStyles.headingLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading && _notifications.isNotEmpty)
            TextButton(
              onPressed: _unreadCount > 0 ? _markAllRead : null,
              child: Text(
                'Mark all read',
                style: AppTextStyles.labelSmall.copyWith(
                  color: _unreadCount > 0 ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: _errorMessage != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$_errorMessage',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadNotifications,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  : _notifications.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return GestureDetector(
                              onTap: () => _markAsRead(notification),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDark,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border(
                                    left: BorderSide(
                                      color: _getNotificationColor(notification.type),
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _getNotificationColor(notification.type)
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getNotificationIcon(notification.type),
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notification.title,
                                                style: AppTextStyles.labelLarge.copyWith(
                                                  color: AppColors.textPrimary,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                notification.description,
                                                style: AppTextStyles.bodySmall.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: AppColors.textSecondary,
                                          ),
                                          onPressed: () => _deleteNotification(notification),
                                        ),
                                        if (!notification.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.only(top: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatTime(notification.timestamp),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
