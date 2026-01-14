/// Priority levels for push notifications
///
/// Used to configure notification behavior on Android and iOS devices.
/// Higher priorities are more likely to wake the device and play sounds.
enum NotificationPriority {
  /// Low priority - minimal interruption, no sound
  low,

  /// Default priority - standard notification behavior
  normal,

  /// High priority - immediate delivery, sound and vibration
  high,

  /// Maximum priority - urgent, heads-up notification
  urgent;

  /// Returns a human-readable label for the priority level
  String get label {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  /// Returns the string representation used in API calls
  String get value {
    switch (this) {
      case NotificationPriority.low:
        return 'low';
      case NotificationPriority.normal:
        return 'normal';
      case NotificationPriority.high:
        return 'high';
      case NotificationPriority.urgent:
        return 'urgent';
    }
  }

  /// Returns the Android notification importance level
  ///
  /// Maps to Android's NotificationManager importance constants:
  /// - low: IMPORTANCE_LOW (2)
  /// - normal: IMPORTANCE_DEFAULT (3)
  /// - high: IMPORTANCE_HIGH (4)
  /// - urgent: IMPORTANCE_MAX (5)
  int get androidImportance {
    switch (this) {
      case NotificationPriority.low:
        return 2;
      case NotificationPriority.normal:
        return 3;
      case NotificationPriority.high:
        return 4;
      case NotificationPriority.urgent:
        return 5;
    }
  }

  /// Creates a NotificationPriority from a string value
  ///
  /// The comparison is case-insensitive.
  /// Returns null if the string doesn't match any priority level.
  static NotificationPriority? fromString(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return null;
    }
  }
}
