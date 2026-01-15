import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rmotly_app/shared/widgets/confirmation_dialog.dart';

void main() {
  group('ConfirmationDialog', () {
    testWidgets('displays title and message', (tester) async {
      // Arrange
      const title = 'Delete Item';
      const message = 'Are you sure you want to delete this item?';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
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

    testWidgets('displays default button labels', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays custom button labels when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
              title: 'Title',
              message: 'Message',
              confirmLabel: 'Delete',
              cancelLabel: 'Keep',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Keep'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
              title: 'Title',
              message: 'Message',
              icon: Icons.delete,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('show() returns true when confirmed', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialog.show(
                  context: context,
                  title: 'Delete Item',
                  message: 'Are you sure?',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isTrue);
    });

    testWidgets('show() returns false when cancelled', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialog.show(
                  context: context,
                  title: 'Confirm',
                  message: 'Are you sure?',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isFalse);
    });

    testWidgets('show() returns false when dismissed', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialog.show(
                  context: context,
                  title: 'Confirm',
                  message: 'Are you sure?',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      // Dismiss by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isFalse);
    });
  });
}
