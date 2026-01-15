import 'package:flutter/material.dart';

/// A reusable confirmation dialog widget.
///
/// Use this widget to prompt users for confirmation before performing
/// destructive or important actions.
class ConfirmationDialog extends StatelessWidget {
  /// Creates a [ConfirmationDialog].
  ///
  /// The [title] and [message] parameters are required.
  /// The [confirmLabel] defaults to 'Confirm' and [cancelLabel] to 'Cancel'.
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    this.icon,
  });

  /// The dialog title.
  final String title;

  /// The dialog message.
  final String message;

  /// The label for the confirm button.
  final String confirmLabel;

  /// The label for the cancel button.
  final String cancelLabel;

  /// Whether this is a destructive action (uses error color for confirm button).
  final bool isDestructive;

  /// Optional icon displayed in the dialog.
  final IconData? icon;

  /// Shows the confirmation dialog and returns `true` if confirmed, `false` otherwise.
  ///
  /// This is a convenience method for showing the dialog.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: icon != null
          ? Icon(
              icon,
              color: isDestructive ? colorScheme.error : null,
            )
          : null,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        if (isDestructive)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(confirmLabel),
          )
        else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
      ],
    );
  }
}
