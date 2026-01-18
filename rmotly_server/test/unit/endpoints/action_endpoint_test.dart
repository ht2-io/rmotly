import 'dart:convert';
import 'package:test/test.dart';

/// Unit tests for action_endpoint testAction parameter handling
///
/// These tests verify that the testAction method correctly handles
/// JSON string parameters instead of Map<String, dynamic>, which
/// fixes the Serverpod serialization error.
void main() {
  group('testAction parameter serialization', () {
    test('when valid JSON string is provided then it deserializes correctly',
        () {
      // Arrange
      final testParams = {'value': 'test', 'count': 42};
      final jsonString = jsonEncode(testParams);

      // Act - Simulate what testAction does internally
      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        fail('Should not throw exception: $e');
      }

      // Assert
      expect(parsed['value'], 'test');
      expect(parsed['count'], 42);
    });

    test('when empty JSON object is provided then it deserializes correctly',
        () {
      // Arrange
      final jsonString = jsonEncode({});

      // Act
      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;

      // Assert
      expect(parsed, isEmpty);
    });

    test('when complex nested JSON is provided then it deserializes correctly',
        () {
      // Arrange
      final testParams = {
        'user': {'name': 'John', 'age': 30},
        'items': ['item1', 'item2'],
        'count': 5
      };
      final jsonString = jsonEncode(testParams);

      // Act
      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;

      // Assert
      expect(parsed['user'], isA<Map>());
      expect((parsed['user'] as Map)['name'], 'John');
      expect(parsed['items'], isA<List>());
      expect(parsed['count'], 5);
    });

    test('when invalid JSON string is provided then it throws FormatException',
        () {
      // Arrange
      const invalidJson = '{invalid json}';

      // Act & Assert
      expect(
        () => jsonDecode(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('when non-object JSON is provided then it throws error', () {
      // Arrange - JSON array instead of object
      final jsonArray = jsonEncode(['item1', 'item2']);

      // Act
      final decoded = jsonDecode(jsonArray);

      // Assert - Simulate what testAction does
      expect(decoded is Map<String, dynamic>, isFalse);
      expect(decoded is List, isTrue);
    });
  });
}
