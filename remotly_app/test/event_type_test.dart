import 'package:flutter_test/flutter_test.dart';
import 'package:remotly_app/core/event_type.dart';

void main() {
  group('EventType', () {
    group('label', () {
      test('returns correct label for buttonPress', () {
        expect(EventType.buttonPress.label, 'Button Press');
      });

      test('returns correct label for toggleChange', () {
        expect(EventType.toggleChange.label, 'Toggle Change');
      });

      test('returns correct label for sliderChange', () {
        expect(EventType.sliderChange.label, 'Slider Change');
      });

      test('returns correct label for inputSubmit', () {
        expect(EventType.inputSubmit.label, 'Input Submit');
      });

      test('returns correct label for dropdownSelect', () {
        expect(EventType.dropdownSelect.label, 'Dropdown Select');
      });
    });

    group('value', () {
      test('returns button_press for buttonPress', () {
        expect(EventType.buttonPress.value, 'button_press');
      });

      test('returns toggle_change for toggleChange', () {
        expect(EventType.toggleChange.value, 'toggle_change');
      });

      test('returns slider_change for sliderChange', () {
        expect(EventType.sliderChange.value, 'slider_change');
      });

      test('returns input_submit for inputSubmit', () {
        expect(EventType.inputSubmit.value, 'input_submit');
      });

      test('returns dropdown_select for dropdownSelect', () {
        expect(EventType.dropdownSelect.value, 'dropdown_select');
      });
    });

    group('fromString', () {
      test('returns buttonPress for button_press', () {
        expect(EventType.fromString('button_press'), EventType.buttonPress);
      });

      test('returns toggleChange for toggle_change', () {
        expect(EventType.fromString('toggle_change'), EventType.toggleChange);
      });

      test('returns sliderChange for slider_change', () {
        expect(EventType.fromString('slider_change'), EventType.sliderChange);
      });

      test('returns inputSubmit for input_submit', () {
        expect(EventType.fromString('input_submit'), EventType.inputSubmit);
      });

      test('returns dropdownSelect for dropdown_select', () {
        expect(
          EventType.fromString('dropdown_select'),
          EventType.dropdownSelect,
        );
      });

      test('returns null for invalid event type', () {
        expect(EventType.fromString('invalid_event'), isNull);
      });

      test('returns null for empty string', () {
        expect(EventType.fromString(''), isNull);
      });
    });

    test('has exactly 5 event types', () {
      expect(EventType.values.length, 5);
    });

    test('value and fromString are inverse operations', () {
      for (final eventType in EventType.values) {
        expect(EventType.fromString(eventType.value), eventType);
      }
    });
  });
}
