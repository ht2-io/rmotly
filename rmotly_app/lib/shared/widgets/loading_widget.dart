import 'package:flutter/material.dart';

/// A reusable loading widget that displays a centered circular progress indicator.
///
/// Use this widget to indicate that content is being loaded.
/// Optionally displays a message below the spinner.
class LoadingWidget extends StatelessWidget {
  /// Creates a [LoadingWidget].
  ///
  /// The optional [message] parameter displays text below the loading indicator.
  const LoadingWidget({
    super.key,
    this.message,
  });

  /// Optional message to display below the loading indicator.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
