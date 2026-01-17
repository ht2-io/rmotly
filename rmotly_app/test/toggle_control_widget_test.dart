import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rmotly_app/features/dashboard/presentation/widgets/toggle_control_widget.dart';
import 'package:rmotly_client/rmotly_client.dart';

void main() {
  group('ToggleControlWidget', () {
    late Control testControl;

    setUp(() {
      testControl = Control(
        id: 1,
        userId: 1,
        name: 'Test Toggle',
        controlType: 'toggle',
        config: '{"state": false, "onLabel": "Active", "offLabel": "Inactive"}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      required Control control,
      required void Function(bool) onChanged,
      bool isExecuting = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ToggleControlWidget(
            control: control,
            onChanged: onChanged,
            isExecuting: isExecuting,
          ),
        ),
      );
    }

    testWidgets('should display toggle with initial state from config', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (_) {},
        ),
      );

      // Assert
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, false);
      expect(find.text('Inactive'), findsOneWidget);
    });

    testWidgets('should display custom on/off labels', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (_) {},
        ),
      );

      // Assert - Initially off, should show off label
      expect(find.text('Inactive'), findsOneWidget);
      expect(find.text('Active'), findsNothing);
    });

    testWidgets('should use default labels when config is missing', (tester) async {
      // Arrange
      final controlWithoutLabels = Control(
        id: 1,
        userId: 1,
        name: 'Test Toggle',
        controlType: 'toggle',
        config: '{"state": false}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithoutLabels,
          onChanged: (_) {},
        ),
      );

      // Assert
      expect(find.text('OFF'), findsOneWidget);
    });

    testWidgets('should toggle state when switched', (tester) async {
      // Arrange
      bool? receivedValue;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (value) => receivedValue = value,
        ),
      );

      // Tap the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert
      expect(receivedValue, true);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Inactive'), findsNothing);
    });

    testWidgets('should call onChanged with new value', (tester) async {
      // Arrange
      bool? capturedValue;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (value) => capturedValue = value,
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert
      expect(capturedValue, true);
    });

    testWidgets('should be disabled when isExecuting is true', (tester) async {
      // Arrange
      bool? receivedValue;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (value) => receivedValue = value,
          isExecuting: true,
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));

      // Assert
      expect(switchWidget.onChanged, isNull);
    });

    testWidgets('should update state when control config changes', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Inactive'), findsOneWidget);

      // Act - Update to new control with different state
      final updatedControl = Control(
        id: 1,
        userId: 1,
        name: 'Test Toggle',
        controlType: 'toggle',
        config: '{"state": true, "onLabel": "Active", "offLabel": "Inactive"}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          control: updatedControl,
          onChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Active'), findsOneWidget);
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);
    });

    testWidgets('should handle multiple toggles', (tester) async {
      // Arrange
      final values = <bool>[];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: values.add,
        ),
      );

      // Toggle on
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Toggle off
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Toggle on again
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert
      expect(values, [true, false, true]);
    });

    testWidgets('should show correct text style for active state', (tester) async {
      // Arrange
      final activeControl = Control(
        id: 1,
        userId: 1,
        name: 'Test Toggle',
        controlType: 'toggle',
        config: '{"state": true, "onLabel": "ON", "offLabel": "OFF"}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: activeControl,
          onChanged: (_) {},
        ),
      );

      // Assert - Active state should have primary color and bold font
      final text = tester.widget<Text>(find.text('ON'));
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('should handle invalid JSON config gracefully', (tester) async {
      // Arrange
      final controlWithInvalidConfig = Control(
        id: 1,
        userId: 1,
        name: 'Test Toggle',
        controlType: 'toggle',
        config: 'invalid json',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert - Should not throw
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithInvalidConfig,
          onChanged: (_) {},
        ),
      );

      // Should display with default values
      expect(find.text('OFF'), findsOneWidget);
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, false);
    });
  });
}
