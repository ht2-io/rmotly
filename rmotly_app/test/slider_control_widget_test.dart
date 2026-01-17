import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rmotly_app/features/dashboard/presentation/widgets/slider_control_widget.dart';
import 'package:rmotly_client/rmotly_client.dart';

void main() {
  group('SliderControlWidget', () {
    late Control testControl;

    setUp(() {
      testControl = Control(
        id: 1,
        userId: 1,
        name: 'Test Slider',
        controlType: 'slider',
        config: '{"min": 0, "max": 100, "value": 50, "divisions": 10, "unit": "°F", "showValue": true}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      required Control control,
      required void Function(double) onChanged,
      bool isExecuting = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SliderControlWidget(
            control: control,
            onChanged: onChanged,
            isExecuting: isExecuting,
          ),
        ),
      );
    }

    testWidgets('should display slider with initial value from config', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (_) {},
        ),
      );

      // Assert
      final sliderWidget = tester.widget<Slider>(find.byType(Slider));
      expect(sliderWidget.value, 50.0);
      expect(sliderWidget.min, 0.0);
      expect(sliderWidget.max, 100.0);
    });

    testWidgets('should display current value with unit', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (_) {},
        ),
      );

      // Assert
      expect(find.text('50°F'), findsOneWidget);
    });

    testWidgets('should display min and max labels with unit', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (_) {},
        ),
      );

      // Assert
      expect(find.text('0°F'), findsOneWidget);
      expect(find.text('100°F'), findsOneWidget);
    });

    testWidgets('should use default values when config is missing', (tester) async {
      // Arrange
      final controlWithMinimalConfig = Control(
        id: 1,
        userId: 1,
        name: 'Test Slider',
        controlType: 'slider',
        config: '{}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithMinimalConfig,
          onChanged: (_) {},
        ),
      );

      // Assert
      final sliderWidget = tester.widget<Slider>(find.byType(Slider));
      expect(sliderWidget.min, 0.0);
      expect(sliderWidget.max, 100.0);
      expect(sliderWidget.value, 0.0);
    });

    testWidgets('should call onChanged when slider is released', (tester) async {
      // Arrange
      double? capturedValue;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (value) => capturedValue = value,
        ),
      );

      // Drag the slider
      await tester.drag(find.byType(Slider), const Offset(100, 0));
      await tester.pumpAndSettle();

      // Assert - onChanged should be called when drag ends
      expect(capturedValue, isNotNull);
      expect(capturedValue, greaterThan(50.0));
    });

    testWidgets('should update visual value while dragging', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (_) {},
        ),
      );

      // Get initial value
      expect(find.text('50°F'), findsOneWidget);

      // Drag the slider
      await tester.drag(find.byType(Slider), const Offset(100, 0));
      await tester.pump();

      // Assert - Value should update during drag
      expect(find.text('50°F'), findsNothing);
    });

    testWidgets('should be disabled when isExecuting is true', (tester) async {
      // Arrange
      double? capturedValue;

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (value) => capturedValue = value,
          isExecuting: true,
        ),
      );

      final sliderWidget = tester.widget<Slider>(find.byType(Slider));

      // Assert
      expect(sliderWidget.onChanged, isNull);
      expect(sliderWidget.onChangeEnd, isNull);
    });

    testWidgets('should respect divisions setting', (tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (_) {},
        ),
      );

      // Assert
      final sliderWidget = tester.widget<Slider>(find.byType(Slider));
      expect(sliderWidget.divisions, 10);
    });

    testWidgets('should hide divisions when set to 0', (tester) async {
      // Arrange
      final controlWithNoDivisions = Control(
        id: 1,
        userId: 1,
        name: 'Test Slider',
        controlType: 'slider',
        config: '{"min": 0, "max": 100, "value": 50, "divisions": 0}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithNoDivisions,
          onChanged: (_) {},
        ),
      );

      // Assert
      final sliderWidget = tester.widget<Slider>(find.byType(Slider));
      expect(sliderWidget.divisions, isNull);
    });

    testWidgets('should hide value when showValue is false', (tester) async {
      // Arrange
      final controlWithHiddenValue = Control(
        id: 1,
        userId: 1,
        name: 'Test Slider',
        controlType: 'slider',
        config: '{"min": 0, "max": 100, "value": 50, "showValue": false}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithHiddenValue,
          onChanged: (_) {},
        ),
      );

      // Assert - Current value text should not be shown
      expect(find.text('50'), findsNothing);
      // Min/max should still be shown
      expect(find.text('0'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('should clamp value to valid range', (tester) async {
      // Arrange - Value outside range
      final controlWithInvalidValue = Control(
        id: 1,
        userId: 1,
        name: 'Test Slider',
        controlType: 'slider',
        config: '{"min": 0, "max": 100, "value": 150}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithInvalidValue,
          onChanged: (_) {},
        ),
      );

      // Assert - Value should be clamped to max
      final sliderWidget = tester.widget<Slider>(find.byType(Slider));
      expect(sliderWidget.value, 100.0);
    });

    testWidgets('should display without unit when unit is empty', (tester) async {
      // Arrange
      final controlWithoutUnit = Control(
        id: 1,
        userId: 1,
        name: 'Test Slider',
        controlType: 'slider',
        config: '{"min": 0, "max": 100, "value": 50}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithoutUnit,
          onChanged: (_) {},
        ),
      );

      // Assert
      expect(find.text('50'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('should update when control config changes', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          control: testControl,
          onChanged: (_) {},
        ),
      );

      expect(find.text('50°F'), findsOneWidget);

      // Act - Update to new control with different value
      final updatedControl = Control(
        id: 1,
        userId: 1,
        name: 'Test Slider',
        controlType: 'slider',
        config: '{"min": 0, "max": 100, "value": 75, "unit": "°F"}',
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
      expect(find.text('75°F'), findsOneWidget);
      final sliderWidget = tester.widget<Slider>(find.byType(Slider));
      expect(sliderWidget.value, 75.0);
    });

    testWidgets('should handle invalid JSON config gracefully', (tester) async {
      // Arrange
      final controlWithInvalidConfig = Control(
        id: 1,
        userId: 1,
        name: 'Test Slider',
        controlType: 'slider',
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
      final sliderWidget = tester.widget<Slider>(find.byType(Slider));
      expect(sliderWidget.min, 0.0);
      expect(sliderWidget.max, 100.0);
    });

    testWidgets('should handle numeric config values as both int and double', (tester) async {
      // Arrange - Mix of int and double
      final controlWithMixedNumbers = Control(
        id: 1,
        userId: 1,
        name: 'Test Slider',
        controlType: 'slider',
        config: '{"min": 10, "max": 90.5, "value": 50}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          control: controlWithMixedNumbers,
          onChanged: (_) {},
        ),
      );

      // Assert - Should convert to double
      final sliderWidget = tester.widget<Slider>(find.byType(Slider));
      expect(sliderWidget.min, 10.0);
      expect(sliderWidget.max, 90.5);
      expect(sliderWidget.value, 50.0);
    });
  });
}
