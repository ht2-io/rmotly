/// State for notification preferences
class NotificationPreferences {
  final bool enabled;
  final bool quietHoursEnabled;
  final int quietHoursStart; // Hour of day (0-23)
  final int quietHoursEnd; // Hour of day (0-23)

  const NotificationPreferences({
    this.enabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 7,
  });

  NotificationPreferences copyWith({
    bool? enabled,
    bool? quietHoursEnabled,
    int? quietHoursStart,
    int? quietHoursEnd,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'quietHoursEnabled': quietHoursEnabled,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enabled: json['enabled'] as bool? ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as int? ?? 22,
      quietHoursEnd: json['quietHoursEnd'] as int? ?? 7,
    );
  }
}

/// State for the settings feature
class SettingsState {
  final NotificationPreferences notificationPreferences;
  final bool isExporting;
  final bool isImporting;
  final String? error;
  final String? successMessage;

  const SettingsState({
    this.notificationPreferences = const NotificationPreferences(),
    this.isExporting = false,
    this.isImporting = false,
    this.error,
    this.successMessage,
  });

  static const initial = SettingsState();

  SettingsState copyWith({
    NotificationPreferences? notificationPreferences,
    bool? isExporting,
    bool? isImporting,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return SettingsState(
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      isExporting: isExporting ?? this.isExporting,
      isImporting: isImporting ?? this.isImporting,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}
