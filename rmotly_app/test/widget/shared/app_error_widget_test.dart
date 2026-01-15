import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rmotly_app/shared/widgets/app_error_widget.dart';

void main() {
  group('AppErrorWidget', () {
    testWidgets('displays error message', (tester) async {
      // Arrange
      const message = 'Something went wrong';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(message: message),
          ),
        ),
      );

      // Assert
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('displays default error icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(message: 'Error'),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Error',
              icon: Icons.wifi_off,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('displays retry button when onRetry is provided',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Error',
              onRetry: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('does not display retry button when onRetry is null',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(message: 'Error'),
          ),
        ),
      );

      // Assert
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      // Arrange
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Error',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Retry'));

      // Assert
      expect(retryCalled, isTrue);
    });
  });
}
