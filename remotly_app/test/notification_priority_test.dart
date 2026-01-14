import 'package:flutter_test/flutter_test.dart';
import 'package:remotly_app/core/notification_priority.dart';

void main() {
  group('NotificationPriority', () {
    group('label', () {
      test('returns correct label for low', () {
        expect(NotificationPriority.low.label, 'Low');
      });

      test('returns correct label for normal', () {
        expect(NotificationPriority.normal.label, 'Normal');
      });

      test('returns correct label for high', () {
        expect(NotificationPriority.high.label, 'High');
      });

      test('returns correct label for urgent', () {
        expect(NotificationPriority.urgent.label, 'Urgent');
      });
    });

    group('value', () {
      test('returns low for low priority', () {
        expect(NotificationPriority.low.value, 'low');
      });

      test('returns normal for normal priority', () {
        expect(NotificationPriority.normal.value, 'normal');
      });

      test('returns high for high priority', () {
        expect(NotificationPriority.high.value, 'high');
      });

      test('returns urgent for urgent priority', () {
        expect(NotificationPriority.urgent.value, 'urgent');
      });
    });

    group('androidImportance', () {
      test('returns 2 for low priority', () {
        expect(NotificationPriority.low.androidImportance, 2);
      });

      test('returns 3 for normal priority', () {
        expect(NotificationPriority.normal.androidImportance, 3);
      });

      test('returns 4 for high priority', () {
        expect(NotificationPriority.high.androidImportance, 4);
      });

      test('returns 5 for urgent priority', () {
        expect(NotificationPriority.urgent.androidImportance, 5);
      });

      test('returns increasing values in correct order', () {
        final priorities = NotificationPriority.values;
        for (var i = 0; i < priorities.length - 1; i++) {
          expect(
            priorities[i].androidImportance <
                priorities[i + 1].androidImportance,
            isTrue,
            reason:
                '${priorities[i].label} should have lower importance than ${priorities[i + 1].label}',
          );
        }
      });
    });

    group('fromString', () {
      test('returns low for lowercase low', () {
        expect(
          NotificationPriority.fromString('low'),
          NotificationPriority.low,
        );
      });

      test('returns normal for uppercase NORMAL', () {
        expect(
          NotificationPriority.fromString('NORMAL'),
          NotificationPriority.normal,
        );
      });

      test('returns high for mixed case High', () {
        expect(
          NotificationPriority.fromString('High'),
          NotificationPriority.high,
        );
      });

      test('returns urgent for lowercase urgent', () {
        expect(
          NotificationPriority.fromString('urgent'),
          NotificationPriority.urgent,
        );
      });

      test('returns null for invalid priority', () {
        expect(NotificationPriority.fromString('invalid'), isNull);
      });

      test('returns null for empty string', () {
        expect(NotificationPriority.fromString(''), isNull);
      });
    });

    test('has exactly 4 priority levels', () {
      expect(NotificationPriority.values.length, 4);
    });

    test('value and fromString are inverse operations', () {
      for (final priority in NotificationPriority.values) {
        expect(NotificationPriority.fromString(priority.value), priority);
      }
    });
  });
}
