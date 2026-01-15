import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rmotly_app/shared/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('displays message', (tester) async {
      // Arrange
      const message = 'No items found';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(message: message),
          ),
        ),
      );

      // Assert
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('displays default icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(message: 'Empty'),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'Empty',
              icon: Icons.search_off,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      // Arrange
      const title = 'Nothing here';
      const message = 'Add some items to get started';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: title,
              message: message,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('displays action button when action is provided',
        (tester) async {
      // Arrange
      const actionLabel = 'Add Item';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'Empty',
              actionLabel: actionLabel,
              onAction: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(actionLabel), findsOneWidget);
    });

    testWidgets('does not display action button when onAction is null',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'Empty',
              actionLabel: 'Add Item',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Add Item'), findsNothing);
    });

    testWidgets('calls onAction when action button is tapped', (tester) async {
      // Arrange
      var actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'Empty',
              actionLabel: 'Add Item',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Add Item'));

      // Assert
      expect(actionCalled, isTrue);
    });
  });
}
