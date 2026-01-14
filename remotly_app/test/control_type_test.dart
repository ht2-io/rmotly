import 'package:flutter_test/flutter_test.dart';
import 'package:remotly_app/core/control_type.dart';

void main() {
  group('ControlType', () {
    group('label', () {
      test('returns correct label for button', () {
        expect(ControlType.button.label, 'Button');
      });

      test('returns correct label for toggle', () {
        expect(ControlType.toggle.label, 'Toggle');
      });

      test('returns correct label for slider', () {
        expect(ControlType.slider.label, 'Slider');
      });

      test('returns correct label for input', () {
        expect(ControlType.input.label, 'Input');
      });

      test('returns correct label for dropdown', () {
        expect(ControlType.dropdown.label, 'Dropdown');
      });
    });

    group('description', () {
      test('returns non-empty description for all types', () {
        for (final type in ControlType.values) {
          expect(type.description.isNotEmpty, isTrue);
        }
      });
    });

    group('payloadDescription', () {
      test('returns correct payload structure for button', () {
        expect(ControlType.button.payloadDescription, '{ "pressed": true }');
      });

      test('returns correct payload structure for toggle', () {
        expect(
          ControlType.toggle.payloadDescription,
          '{ "state": true/false }',
        );
      });

      test('returns correct payload structure for slider', () {
        expect(
          ControlType.slider.payloadDescription,
          '{ "value": 0.0-1.0 }',
        );
      });

      test('returns correct payload structure for input', () {
        expect(
          ControlType.input.payloadDescription,
          '{ "text": "user input" }',
        );
      });

      test('returns correct payload structure for dropdown', () {
        expect(
          ControlType.dropdown.payloadDescription,
          '{ "selected": "option_id" }',
        );
      });
    });

    test('has exactly 5 control types', () {
      expect(ControlType.values.length, 5);
    });
  });
}
