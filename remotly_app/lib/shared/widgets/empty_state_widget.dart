import 'package:flutter/material.dart';

/// A reusable empty state widget that displays when no content is available.
///
/// Use this widget to indicate empty lists, no search results,
/// or other scenarios where no content is present.
class EmptyStateWidget extends StatelessWidget {
  /// Creates an [EmptyStateWidget].
  ///
  /// The [message] parameter is required and displays the empty state text.
  /// Optional [icon] and [actionLabel]/[onAction] for a call-to-action button.
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.title,
    this.actionLabel,
    this.onAction,
  });

  /// Optional title displayed above the message.
  final String? title;

  /// The message to display.
  final String message;

  /// Optional icon displayed above the message. Defaults to [Icons.inbox_outlined].
  final IconData? icon;

  /// Optional label for the action button.
  final String? actionLabel;

  /// Optional callback invoked when the action button is pressed.
  final VoidCallback? onAction;

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
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
