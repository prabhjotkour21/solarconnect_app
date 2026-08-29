class NotificationPreference {
  final String id;
  final String userId;
  
  // Category toggles
  bool enableAlerts;
  bool enableSavings;
  bool enableUpdates;
  bool enableSystemStatus;
  
  // Delivery methods
  bool enableAppNotifications;
  bool enableEmailNotifications;
  bool enableSmsNotifications;
  
  // Frequency preferences
  String frequency; // 'immediate', 'daily', 'weekly', 'never'
  String? quietHoursStart; // HH:mm format (e.g., "22:00")
  String? quietHoursEnd;   // HH:mm format (e.g., "08:00")
  bool quietHoursEnabled;
  
  // Additional settings
  bool enableVibration;
  bool enableSound;
  String? language;
  
  DateTime? updatedAt;
  DateTime? createdAt;

  NotificationPreference({
    this.id = '',
    this.userId = '',
    this.enableAlerts = true,
    this.enableSavings = true,
    this.enableUpdates = true,
    this.enableSystemStatus = true,
    this.enableAppNotifications = true,
    this.enableEmailNotifications = false,
    this.enableSmsNotifications = false,
    this.frequency = 'immediate',
    this.quietHoursStart,
    this.quietHoursEnd,
    this.quietHoursEnabled = false,
    this.enableVibration = true,
    this.enableSound = true,
    this.language,
    this.updatedAt,
    this.createdAt,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      enableAlerts: json['enableAlerts'] ?? true,
      enableSavings: json['enableSavings'] ?? true,
      enableUpdates: json['enableUpdates'] ?? true,
      enableSystemStatus: json['enableSystemStatus'] ?? true,
      enableAppNotifications: json['enableAppNotifications'] ?? true,
      enableEmailNotifications: json['enableEmailNotifications'] ?? false,
      enableSmsNotifications: json['enableSmsNotifications'] ?? false,
      frequency: json['frequency']?.toString() ?? 'immediate',
      quietHoursStart: json['quietHoursStart']?.toString(),
      quietHoursEnd: json['quietHoursEnd']?.toString(),
      quietHoursEnabled: json['quietHoursEnabled'] ?? false,
      enableVibration: json['enableVibration'] ?? true,
      enableSound: json['enableSound'] ?? true,
      language: json['language']?.toString(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'enableAlerts': enableAlerts,
      'enableSavings': enableSavings,
      'enableUpdates': enableUpdates,
      'enableSystemStatus': enableSystemStatus,
      'enableAppNotifications': enableAppNotifications,
      'enableEmailNotifications': enableEmailNotifications,
      'enableSmsNotifications': enableSmsNotifications,
      'frequency': frequency,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'quietHoursEnabled': quietHoursEnabled,
      'enableVibration': enableVibration,
      'enableSound': enableSound,
      'language': language,
    };
  }

  static NotificationPreference defaultPreferences() {
    return NotificationPreference(
      enableAlerts: true,
      enableSavings: true,
      enableUpdates: true,
      enableSystemStatus: true,
      enableAppNotifications: true,
      enableEmailNotifications: false,
      enableSmsNotifications: false,
      frequency: 'immediate',
      quietHoursEnabled: false,
      enableVibration: true,
      enableSound: true,
    );
  }

  NotificationPreference copyWith({
    String? id,
    String? userId,
    bool? enableAlerts,
    bool? enableSavings,
    bool? enableUpdates,
    bool? enableSystemStatus,
    bool? enableAppNotifications,
    bool? enableEmailNotifications,
    bool? enableSmsNotifications,
    String? frequency,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? quietHoursEnabled,
    bool? enableVibration,
    bool? enableSound,
    String? language,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return NotificationPreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      enableAlerts: enableAlerts ?? this.enableAlerts,
      enableSavings: enableSavings ?? this.enableSavings,
      enableUpdates: enableUpdates ?? this.enableUpdates,
      enableSystemStatus: enableSystemStatus ?? this.enableSystemStatus,
      enableAppNotifications:
          enableAppNotifications ?? this.enableAppNotifications,
      enableEmailNotifications:
          enableEmailNotifications ?? this.enableEmailNotifications,
      enableSmsNotifications:
          enableSmsNotifications ?? this.enableSmsNotifications,
      frequency: frequency ?? this.frequency,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      enableVibration: enableVibration ?? this.enableVibration,
      enableSound: enableSound ?? this.enableSound,
      language: language ?? this.language,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
