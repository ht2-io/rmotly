import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rmotly_app/features/dashboard/presentation/widgets/control_card.dart';
import 'package:rmotly_client/rmotly_client.dart';

void main() {
  group('ControlCard', () {
    late Control testControl;

    setUp(() {
      testControl = Control(
        id: 1,
        userId: 1,
        name: 'Test Control',
        controlType: 'button',
        config: '{}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      required Control control,
      Widget? child,
      bool isExecuting = false,
      VoidCallback? onLongPress,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: ControlCard(
              control: control,
              isExecuting: isExecuting,
              onLongPress: onLongPress,
              onEdit: onEdit,
              onDelete: onDelete,
              child: child ?? const Text('Child Widget'),
            ),
          ),
        ),
      );
    }

    testWidgets('should display control name', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(control: testControl));

      // Assert
      expect(find.text('Test Control'), findsOneWidget);
    });

    testWidgets('should display control type icon', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(control: testControl));

      // Assert
      expect(find.byIcon(Icons.touch_app), findsOneWidget);
    });

    testWidgets('should display child widget', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          child: const Text('Custom Child'),
        ),
      );

      // Assert
      expect(find.text('Custom Child'), findsOneWidget);
    });

    testWidgets('should show elevated card when executing', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          isExecuting: true,
        ),
      );

      // Assert - Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should call onLongPress when long pressed', (tester) async {
      // Arrange
      var wasLongPressed = false;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onLongPress: () => wasLongPressed = true,
        ),
      );

      await tester.longPress(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Assert
      expect(wasLongPressed, true);
    });

    testWidgets('should show menu button when onEdit or onDelete provided', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onEdit: () {},
          onDelete: () {},
        ),
      );

      // Assert
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should not show menu button when no callbacks provided', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(control: testControl),
      );

      // Assert
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('should show edit menu item and call onEdit', (tester) async {
      // Arrange
      var wasEditCalled = false;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onEdit: () => wasEditCalled = true,
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert - Edit menu item is visible
      expect(find.text('Edit'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);

      // Act - Tap edit
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Assert
      expect(wasEditCalled, true);
    });

    testWidgets('should show delete menu item and call onDelete', (tester) async {
      // Arrange
      var wasDeleteCalled = false;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onDelete: () => wasDeleteCalled = true,
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert - Delete menu item is visible
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);

      // Act - Tap delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(wasDeleteCalled, true);
    });

    testWidgets('should show both edit and delete when both provided', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onEdit: () {},
          onDelete: () {},
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should display correct icon for different control types', (tester) async {
      // Test data: control type -> expected icon
      final iconMappings = {
        'button': Icons.touch_app,
        'toggle': Icons.toggle_on,
        'slider': Icons.linear_scale,
        'input': Icons.text_fields,
        'dropdown': Icons.arrow_drop_down_circle,
      };

      for (final entry in iconMappings.entries) {
        // Arrange
        final control = Control(
          id: 1,
          userId: 1,
          name: 'Test Control',
          controlType: entry.key,
          config: '{}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(createTestWidget(control: control));

        // Assert
        expect(find.byIcon(entry.value), findsOneWidget,
            reason: 'Control type ${entry.key} should show icon ${entry.value}');

        // Cleanup for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('should use default icon for unknown control type', (tester) async {
      // Arrange
      final unknownControl = Control(
        id: 1,
        userId: 1,
        name: 'Unknown Control',
        controlType: 'unknown',
        config: '{}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(createTestWidget(control: unknownControl));

      // Assert
      expect(find.byIcon(Icons.widgets), findsOneWidget);
    });

    testWidgets('should truncate long control names', (tester) async {
      // Arrange
      final longNameControl = Control(
        id: 1,
        userId: 1,
        name: 'This is a very long control name that should be truncated',
        controlType: 'button',
        config: '{}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(control: longNameControl),
      );

      // Assert - Should render without overflow
      expect(tester.takeException(), isNull);
      
      final text = tester.widget<Text>(find.text(longNameControl.name));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should show loading overlay only when executing', (tester) async {
      // Act - Not executing
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          isExecuting: false,
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Act - Executing
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          isExecuting: true,
        ),
      );
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
