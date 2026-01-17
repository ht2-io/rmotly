import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/services/auth_service.dart';
import '../providers/settings_providers.dart';

/// Main settings view with all configuration options
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(settingsViewModelProvider);

    // Show error snackbar
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: colorScheme.error,
          ),
        );
        ref.read(settingsViewModelProvider.notifier).clearError();
      });
    }

    // Show success snackbar
    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.successMessage!)),
        );
        ref.read(settingsViewModelProvider.notifier).clearSuccessMessage();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildAccountSection(context, ref),

          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          _buildNotificationsSection(context, ref, state),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildAppearanceSection(context, ref),

          // Data Section
          _buildSectionHeader(context, 'Data'),
          _buildDataSection(context, ref, state),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildAboutSection(context),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);
    final authService = ref.read(authServiceProvider.notifier);

    return Column(
      children: [
        if (authState.userInfo != null)
          ListTile(
            leading: CircleAvatar(
              child: Text(
                (authState.userInfo!.email ??
                        authState.userInfo!.userName ??
                        'U')
                    .substring(0, 1)
                    .toUpperCase(),
              ),
            ),
            title: Text(authState.userInfo!.email ??
                authState.userInfo!.userName ??
                'User'),
            subtitle: const Text('Signed in'),
          ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign Out'),
          onTap: () async {
            final confirmed = await _showConfirmDialog(
              context,
              title: 'Sign Out',
              message: 'Are you sure you want to sign out?',
              confirmLabel: 'Sign Out',
            );
            if (confirmed) {
              await authService.signOut();
            }
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(
    BuildContext context,
    WidgetRef ref,
    state,
  ) {
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final prefs = state.notificationPreferences;

    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive push notifications'),
          value: prefs.enabled,
          onChanged: (value) => viewModel.setNotificationsEnabled(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.bedtime),
          title: const Text('Quiet Hours'),
          subtitle: Text(
            prefs.quietHoursEnabled
                ? '${_formatHour(prefs.quietHoursStart)} - ${_formatHour(prefs.quietHoursEnd)}'
                : 'Disabled',
          ),
          value: prefs.quietHoursEnabled,
          onChanged: prefs.enabled
              ? (value) => viewModel.setQuietHoursEnabled(value)
              : null,
        ),
        if (prefs.quietHoursEnabled) ...[
          ListTile(
            leading: const SizedBox(width: 24),
            title: const Text('Start Time'),
            trailing: TextButton(
              onPressed: () => _showTimePicker(
                context,
                initialHour: prefs.quietHoursStart,
                onSelected: (hour) => viewModel.setQuietHoursStart(hour),
              ),
              child: Text(_formatHour(prefs.quietHoursStart)),
            ),
          ),
          ListTile(
            leading: const SizedBox(width: 24),
            title: const Text('End Time'),
            trailing: TextButton(
              onPressed: () => _showTimePicker(
                context,
                initialHour: prefs.quietHoursEnd,
                onSelected: (hour) => viewModel.setQuietHoursEnd(hour),
              ),
              child: Text(_formatHour(prefs.quietHoursEnd)),
            ),
          ),
        ],
        ListTile(
          leading: const Icon(Icons.tune),
          title: const Text('Push Settings'),
          subtitle: const Text('Configure push notification delivery'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/push-settings'),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Theme'),
          subtitle: Text(_getThemeLabel(currentTheme)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(context, currentTheme, themeNotifier),
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context, WidgetRef ref, state) {
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text('Export Configuration'),
          subtitle: const Text('Save settings to clipboard'),
          trailing: state.isExporting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          onTap: state.isExporting
              ? null
              : () async {
                  final json = await viewModel.exportConfiguration();
                  if (json != null) {
                    await Clipboard.setData(ClipboardData(text: json));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Configuration copied to clipboard'),
                        ),
                      );
                    }
                  }
                },
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Import Configuration'),
          subtitle: const Text('Load settings from clipboard'),
          trailing: state.isImporting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          onTap: state.isImporting
              ? null
              : () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null && data!.text!.isNotEmpty) {
                    await viewModel.importConfiguration(data.text!);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Clipboard is empty'),
                        ),
                      );
                    }
                  }
                },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Licenses'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'Rmotly',
            applicationVersion: '1.0.0',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Open privacy policy URL
          },
        ),
      ],
    );
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  Future<void> _showTimePicker(
    BuildContext context, {
    required int initialHour,
    required void Function(int) onSelected,
  }) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (time != null) {
      onSelected(time.hour);
    }
  }

  Future<void> _showThemeDialog(
    BuildContext context,
    AppThemeMode currentTheme,
    ThemeModeNotifier notifier,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(_getThemeLabel(mode)),
              value: mode,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  notifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
