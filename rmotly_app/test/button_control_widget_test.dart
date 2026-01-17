import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rmotly_app/features/dashboard/presentation/widgets/button_control_widget.dart';
import 'package:rmotly_client/rmotly_client.dart';

void main() {
  group('ButtonControlWidget', () {
    late Control testControl;

    setUp(() {
      testControl = Control(
        id: 1,
        userId: 1,
        name: 'Test Button',
        controlType: 'button',
        config: '{"label": "Press Me", "icon": "power"}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      required Control control,
      required VoidCallback onPressed,
      bool isExecuting = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ButtonControlWidget(
            control: control,
            onPressed: onPressed,
            isExecuting: isExecuting,
          ),
        ),
      );
    });

    testWidgets('should display button with label from config', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onPressed: () {},
        ),
      );

      // Assert
      expect(find.text('Press Me'), findsOneWidget);
    });

    testWidgets('should display button with icon from config', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onPressed: () {},
        ),
      );

      // Assert
      expect(find.byIcon(Icons.power_settings_new), findsOneWidget);
    });

    testWidgets('should use default label when config is missing', (tester) async {
      // Arrange
      final controlWithoutLabel = Control(
        id: 1,
        userId: 1,
        name: 'Test Button',
        controlType: 'button',
        config: '{}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithoutLabel,
          onPressed: () {},
        ),
      );

      // Assert
      expect(find.text('Press'), findsOneWidget);
    });

    testWidgets('should use default icon when config is missing', (tester) async {
      // Arrange
      final controlWithoutIcon = Control(
        id: 1,
        userId: 1,
        name: 'Test Button',
        controlType: 'button',
        config: '{"label": "Press"}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithoutIcon,
          onPressed: () {},
        ),
      );

      // Assert
      expect(find.byIcon(Icons.touch_app), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      var wasPressed = false;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onPressed: () => wasPressed = true,
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Assert
      expect(wasPressed, true);
    });

    testWidgets('should be disabled when isExecuting is true', (tester) async {
      // Arrange
      var wasPressed = false;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onPressed: () => wasPressed = true,
          isExecuting: true,
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));

      // Assert
      expect(button.onPressed, isNull);
      expect(wasPressed, false);
    });

    testWidgets('should display correct icon for different icon names', (tester) async {
      // Test data: icon name -> expected IconData
      final iconMappings = {
        'play': Icons.play_arrow,
        'stop': Icons.stop,
        'refresh': Icons.refresh,
        'send': Icons.send,
        'light': Icons.lightbulb,
        'lock': Icons.lock,
        'unlock': Icons.lock_open,
        'home': Icons.home,
        'settings': Icons.settings,
        'unknown': Icons.touch_app, // default
      };

      for (final entry in iconMappings.entries) {
        // Arrange
        final control = Control(
          id: 1,
          userId: 1,
          name: 'Test Button',
          controlType: 'button',
          config: '{"label": "Test", "icon": "${entry.key}"}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            control: control,
            onPressed: () {},
          ),
        );

        // Assert
        expect(find.byIcon(entry.value), findsOneWidget,
            reason: 'Icon ${entry.key} should map to ${entry.value}');

        // Cleanup for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('should have minimum size constraints', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onPressed: () {},
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = button.style;

      // Assert
      expect(style?.minimumSize?.resolve({}), const Size(120, 56));
    });

    testWidgets('should handle invalid JSON config gracefully', (tester) async {
      // Arrange
      final controlWithInvalidConfig = Control(
        id: 1,
        userId: 1,
        name: 'Test Button',
        controlType: 'button',
        config: 'invalid json',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert - Should not throw
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithInvalidConfig,
          onPressed: () {},
        ),
      );

      // Should display with default values
      expect(find.text('Press'), findsOneWidget);
      expect(find.byIcon(Icons.touch_app), findsOneWidget);
    });
  });
}
