import 'package:flutter/material.dart';

/// A reusable error widget that displays an error message with retry option.
///
/// Use this widget to show errors to the user with an optional retry button.
/// Named [AppErrorWidget] to avoid conflict with Flutter's built-in [ErrorWidget].
class AppErrorWidget extends StatelessWidget {
  /// Creates an [AppErrorWidget].
  ///
  /// The [message] parameter is required and displays the error text.
  /// The optional [onRetry] callback enables a retry button when provided.
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  /// The error message to display.
  final String message;

  /// Optional callback invoked when the retry button is pressed.
  final VoidCallback? onRetry;

  /// Optional custom icon. Defaults to [Icons.error_outline].
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
