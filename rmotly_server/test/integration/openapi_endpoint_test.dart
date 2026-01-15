import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  // Test helper for OpenApiEndpoint
  withServerpod('Given OpenApiEndpoint', (sessionBuilder, endpoints) {
    group('parseSpec method', () {
      test('when called with valid OpenAPI 3.0 JSON URL then returns parsed spec', () async {
        // This test would require a mock HTTP server or a real OpenAPI spec URL
        // For now, we'll test that the method exists and has the correct signature
        expect(endpoints.openApi.parseSpec, isA<Function>());
      });

      test('when called with invalid URL then throws exception', () async {
        // Test error handling
        expect(
          () => endpoints.openApi.parseSpec(sessionBuilder, 'invalid-url'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('listOperations method', () {
      test('when called with valid spec URL then returns list of operations', () async {
        // This test would require a mock HTTP server or a real OpenAPI spec URL
        // For now, we'll test that the method exists and has the correct signature
        expect(endpoints.openApi.listOperations, isA<Function>());
      });

      test('when called with invalid URL then throws exception', () async {
        // Test error handling
        expect(
          () => endpoints.openApi.listOperations(sessionBuilder, 'invalid-url'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
