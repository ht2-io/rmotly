import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/settings_state.dart';

/// View model for the settings feature
class SettingsViewModel extends StateNotifier<SettingsState> {
  static const _notificationPrefsKey = 'notification_preferences';

  SettingsViewModel() : super(SettingsState.initial) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifPrefsJson = prefs.getString(_notificationPrefsKey);
      if (notifPrefsJson != null) {
        final notifPrefs = NotificationPreferences.fromJson(
          jsonDecode(notifPrefsJson) as Map<String, dynamic>,
        );
        state = state.copyWith(notificationPreferences: notifPrefs);
      }
    } catch (e) {
      debugPrint('SettingsViewModel: Failed to load preferences: $e');
    }
  }

  Future<void> _saveNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _notificationPrefsKey,
        jsonEncode(state.notificationPreferences.toJson()),
      );
    } catch (e) {
      debugPrint('SettingsViewModel: Failed to save preferences: $e');
    }
  }

  /// Toggle notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(
      notificationPreferences: state.notificationPreferences.copyWith(
        enabled: enabled,
      ),
    );
    await _saveNotificationPreferences();
  }

  /// Toggle quiet hours enabled/disabled
  Future<void> setQuietHoursEnabled(bool enabled) async {
    state = state.copyWith(
      notificationPreferences: state.notificationPreferences.copyWith(
        quietHoursEnabled: enabled,
      ),
    );
    await _saveNotificationPreferences();
  }

  /// Set quiet hours start time
  Future<void> setQuietHoursStart(int hour) async {
    state = state.copyWith(
      notificationPreferences: state.notificationPreferences.copyWith(
        quietHoursStart: hour,
      ),
    );
    await _saveNotificationPreferences();
  }

  /// Set quiet hours end time
  Future<void> setQuietHoursEnd(int hour) async {
    state = state.copyWith(
      notificationPreferences: state.notificationPreferences.copyWith(
        quietHoursEnd: hour,
      ),
    );
    await _saveNotificationPreferences();
  }

  /// Export all configuration to JSON string
  Future<String?> exportConfiguration() async {
    state = state.copyWith(isExporting: true, clearError: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final config = <String, dynamic>{
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'notificationPreferences': state.notificationPreferences.toJson(),
        // Add other settings here as needed
      };

      state = state.copyWith(
        isExporting: false,
        successMessage: 'Configuration exported successfully',
      );

      return jsonEncode(config);
    } catch (e) {
      debugPrint('SettingsViewModel: Failed to export configuration: $e');
      state = state.copyWith(
        isExporting: false,
        error: 'Failed to export configuration',
      );
      return null;
    }
  }

  /// Import configuration from JSON string
  Future<bool> importConfiguration(String jsonString) async {
    state = state.copyWith(isImporting: true, clearError: true);

    try {
      final config = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate version
      final version = config['version'] as int?;
      if (version == null || version > 1) {
        throw Exception('Unsupported configuration version');
      }

      // Import notification preferences
      if (config['notificationPreferences'] != null) {
        final notifPrefs = NotificationPreferences.fromJson(
          config['notificationPreferences'] as Map<String, dynamic>,
        );
        state = state.copyWith(notificationPreferences: notifPrefs);
        await _saveNotificationPreferences();
      }

      state = state.copyWith(
        isImporting: false,
        successMessage: 'Configuration imported successfully',
      );

      return true;
    } catch (e) {
      debugPrint('SettingsViewModel: Failed to import configuration: $e');
      state = state.copyWith(
        isImporting: false,
        error: 'Failed to import configuration: Invalid format',
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear success message
  void clearSuccessMessage() {
    state = state.copyWith(clearSuccessMessage: true);
  }
}
