import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/settings_state.dart';
import '../viewmodel/settings_viewmodel.dart';

/// Provider for the settings view model
final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel();
});

/// Provider for notification preferences
final notificationPreferencesProvider =
    Provider<NotificationPreferences>((ref) {
  return ref.watch(settingsViewModelProvider).notificationPreferences;
});

/// Provider to check if notifications are enabled
final notificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationPreferencesProvider).enabled;
});
