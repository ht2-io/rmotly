import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/repositories/action_repository.dart';

/// Dialog to display action test results
class TestResultDialog extends StatelessWidget {
  final ActionTestResult result;

  const TestResultDialog({
    super.key,
    required this.result,
  });

  static Future<void> show(BuildContext context, ActionTestResult result) {
    return showDialog(
      context: context,
      builder: (context) => TestResultDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            result.success ? Icons.check_circle : Icons.error,
            color: result.success ? Colors.green : colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(result.success ? 'Test Passed' : 'Test Failed'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status and time
            Row(
              children: [
                if (result.statusCode != null) ...[
                  _StatusChip(
                    statusCode: result.statusCode!,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  '${result.executionTimeMs}ms',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Error message
            if (result.error != null) ...[
              Text(
                'Error',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Response headers
            if (result.responseHeaders != null && result.responseHeaders!.isNotEmpty) ...[
              Text(
                'Response Headers',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.responseHeaders!.entries.map((e) {
                    return Text(
                      '${e.key}: ${e.value}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Response body
            if (result.responseBody != null && result.responseBody!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Response Body',
                    style: theme.textTheme.titleSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.responseBody!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    tooltip: 'Copy',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _formatJson(result.responseBody!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _formatJson(String json) {
    try {
      // Try to format as JSON
      final decoded = json;
      return decoded;
    } catch (_) {
      return json;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final int statusCode;
  final ColorScheme colorScheme;

  const _StatusChip({
    required this.statusCode,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusCode.toString(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.blue;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
