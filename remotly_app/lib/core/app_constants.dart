/// Application-wide constants
///
/// Contains default values, timeouts, limits, and other configuration
/// used throughout the Remotly app.
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'Remotly';
  static const String appVersion = '1.0.0';

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(minutes: 2);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;

  // Control Grid
  static const int defaultGridCrossAxisCount = 2;
  static const double controlCardMinHeight = 100.0;
  static const double controlCardAspectRatio = 1.5;

  // Limits
  static const int maxControlNameLength = 50;
  static const int maxActionNameLength = 50;
  static const int maxTopicNameLength = 50;
  static const int maxDescriptionLength = 200;
  static const int maxUrlLength = 2048;
  static const int maxControls = 50;
  static const int maxActions = 100;
  static const int maxTopics = 20;

  // Local Storage Keys
  static const String themeKey = 'theme_mode';
  static const String userPreferencesKey = 'user_preferences';
  static const String cachedControlsKey = 'cached_controls';
  static const String cachedActionsKey = 'cached_actions';
  static const String cachedTopicsKey = 'cached_topics';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Default Values
  static const int defaultSliderMin = 0;
  static const int defaultSliderMax = 100;
  static const int defaultSliderStep = 1;
  static const bool defaultConfirmationRequired = false;
  static const bool defaultNotificationsEnabled = true;
}
