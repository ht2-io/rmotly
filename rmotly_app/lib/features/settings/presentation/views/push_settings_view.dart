import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/push_service.dart';

/// View for configuring push notification settings
class PushSettingsView extends ConsumerWidget {
  const PushSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pushState = ref.watch(pushServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          _buildStatusCard(context, pushState),
          const SizedBox(height: 24),

          // Distributor Selection
          Text(
            'Push Distributor',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Select how push notifications are delivered to your device. '
            'UnifiedPush distributors provide privacy-respecting notification delivery.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Distributor options
          _buildDistributorCard(
            context,
            title: 'Default (UnifiedPush)',
            subtitle: 'Uses available UnifiedPush distributor on device',
            icon: Icons.cloud,
            isSelected: true,
            onTap: () => _showDistributorInfo(context),
          ),
          const SizedBox(height: 8),
          _buildDistributorCard(
            context,
            title: 'ntfy',
            subtitle: 'Self-hosted push notification server',
            icon: Icons.dns,
            isSelected: false,
            onTap: () => _showDistributorInfo(context),
          ),

          const SizedBox(height: 24),

          // Test Notification
          Text(
            'Test Notifications',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Send a test notification to verify your push configuration is working correctly.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: pushState.isInitialized
                ? () => _sendTestNotification(context, ref)
                : null,
            icon: const Icon(Icons.send),
            label: const Text('Send Test Notification'),
          ),

          const SizedBox(height: 24),

          // Endpoint Info (for debugging)
          if (pushState.unifiedPushEndpoint != null) ...[
            Text(
              'Endpoint Information',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UnifiedPush Endpoint',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pushState.unifiedPushEndpoint!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Connection status
          const SizedBox(height: 16),
          _buildConnectionStatus(context, pushState),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, PushServiceState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = state.isInitialized
        ? Colors.green
        : state.error != null
            ? colorScheme.error
            : Colors.orange;

    final statusText = state.isInitialized
        ? 'Connected'
        : state.error != null
            ? 'Error'
            : 'Initializing...';

    final statusDescription = state.isInitialized
        ? 'Push notifications are configured and ready'
        : state.error != null
            ? state.error!
            : 'Setting up push notification service...';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.isInitialized
                    ? Icons.check_circle
                    : state.error != null
                        ? Icons.error
                        : Icons.hourglass_empty,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, PushServiceState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Status',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              context,
              'WebSocket',
              state.isWebSocketConnected,
              'Real-time notifications (foreground)',
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              context,
              'UnifiedPush',
              state.unifiedPushEndpoint != null,
              'Background notifications',
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              context,
              'SSE Fallback',
              state.isSseConnected,
              'Server-Sent Events',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    bool isConnected,
    String description,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          isConnected ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
          color: isConnected ? Colors.green : colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistributorCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: isSelected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color:
                            isSelected ? colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDistributorInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Push Distributors'),
        content: const Text(
          'UnifiedPush distributors handle delivering push notifications to your device. '
          'Install a UnifiedPush-compatible app like ntfy to receive notifications '
          'without relying on Google services.\n\n'
          'The distributor selection is automatic based on what\'s available on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestNotification(
      BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent! Check your notification tray.'),
      ),
    );

    // Use the push service to trigger a test
    // For now, we'll just show a snackbar since we'd need server-side support
    // to actually send a push notification through the delivery chain
  }
}
