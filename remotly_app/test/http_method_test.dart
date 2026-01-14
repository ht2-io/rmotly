import 'package:flutter_test/flutter_test.dart';
import 'package:remotly_app/core/http_method.dart';

void main() {
  group('HttpMethod', () {
    group('value', () {
      test('returns GET for get', () {
        expect(HttpMethod.get.value, 'GET');
      });

      test('returns POST for post', () {
        expect(HttpMethod.post.value, 'POST');
      });

      test('returns PUT for put', () {
        expect(HttpMethod.put.value, 'PUT');
      });

      test('returns PATCH for patch', () {
        expect(HttpMethod.patch.value, 'PATCH');
      });

      test('returns DELETE for delete', () {
        expect(HttpMethod.delete.value, 'DELETE');
      });
    });

    group('label', () {
      test('returns uppercase labels for all methods', () {
        for (final method in HttpMethod.values) {
          expect(method.label, method.label.toUpperCase());
        }
      });
    });

    group('fromString', () {
      test('returns GET for uppercase GET', () {
        expect(HttpMethod.fromString('GET'), HttpMethod.get);
      });

      test('returns POST for lowercase post', () {
        expect(HttpMethod.fromString('post'), HttpMethod.post);
      });

      test('returns PUT for mixed case Put', () {
        expect(HttpMethod.fromString('Put'), HttpMethod.put);
      });

      test('returns PATCH for uppercase PATCH', () {
        expect(HttpMethod.fromString('PATCH'), HttpMethod.patch);
      });

      test('returns DELETE for lowercase delete', () {
        expect(HttpMethod.fromString('delete'), HttpMethod.delete);
      });

      test('returns null for invalid method', () {
        expect(HttpMethod.fromString('INVALID'), isNull);
      });

      test('returns null for empty string', () {
        expect(HttpMethod.fromString(''), isNull);
      });
    });

    test('has exactly 5 HTTP methods', () {
      expect(HttpMethod.values.length, 5);
    });
  });
}
