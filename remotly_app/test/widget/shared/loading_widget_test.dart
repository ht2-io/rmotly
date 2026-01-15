import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remotly_app/shared/widgets/loading_widget.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('displays circular progress indicator', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays message when provided', (tester) async {
      // Arrange
      const message = 'Loading data...';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(message: message),
          ),
        ),
      );

      // Assert
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('does not display message when not provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      // Assert
      expect(find.byType(Text), findsNothing);
    });
  });
}
