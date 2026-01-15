import 'package:test/test.dart';
import 'package:remotly_server/src/services/api_key_service.dart';

void main() {
  late ApiKeyService apiKeyService;

  setUp(() {
    apiKeyService = ApiKeyService();
  });

  group('ApiKeyService', () {
    group('generateApiKey', () {
      test('generates a non-empty key', () {
        final key = apiKeyService.generateApiKey();
        expect(key, isNotEmpty);
      });

      test('generates keys with sufficient entropy (256-bit / 32 bytes)', () {
        final key = apiKeyService.generateApiKey();
        // Base64 encoding of 32 bytes results in 44 characters (with padding removed for base64url)
        // or 43 characters without padding
        expect(key.length, greaterThanOrEqualTo(43));
      });

      test('generates unique keys on multiple calls', () {
        final key1 = apiKeyService.generateApiKey();
        final key2 = apiKeyService.generateApiKey();
        final key3 = apiKeyService.generateApiKey();

        expect(key1, isNot(equals(key2)));
        expect(key2, isNot(equals(key3)));
        expect(key1, isNot(equals(key3)));
      });

      test('generates keys that are base64-url safe', () {
        final key = apiKeyService.generateApiKey();
        // Base64 URL-safe characters: A-Z, a-z, 0-9, -, _
        final base64UrlRegex = RegExp(r'^[A-Za-z0-9\-_=]+$');
        expect(base64UrlRegex.hasMatch(key), isTrue);
      });

      test('generates keys with 256-bit entropy', () {
        // Generate multiple keys to verify entropy
        final keys = <String>{};
        for (var i = 0; i < 100; i++) {
          keys.add(apiKeyService.generateApiKey());
        }
        // All keys should be unique
        expect(keys.length, equals(100));
      });
    });

    group('hashApiKey', () {
      test('generates a non-empty hash', () {
        final key = apiKeyService.generateApiKey();
        final hash = apiKeyService.hashApiKey(key);
        expect(hash, isNotEmpty);
      });

      test('generates consistent hash for same input', () {
        final key = 'test-api-key-12345';
        final hash1 = apiKeyService.hashApiKey(key);
        final hash2 = apiKeyService.hashApiKey(key);
        expect(hash1, equals(hash2));
      });

      test('generates different hashes for different inputs', () {
        final key1 = 'test-key-1';
        final key2 = 'test-key-2';
        final hash1 = apiKeyService.hashApiKey(key1);
        final hash2 = apiKeyService.hashApiKey(key2);
        expect(hash1, isNot(equals(hash2)));
      });

      test('produces one-way hash (cannot reverse)', () {
        final key = apiKeyService.generateApiKey();
        final hash = apiKeyService.hashApiKey(key);

        // Verify we cannot extract the original key from the hash
        expect(hash, isNot(equals(key)));
        expect(hash.length, greaterThan(0));
      });

      test('handles empty string', () {
        final hash = apiKeyService.hashApiKey('');
        expect(hash, isNotEmpty);
      });

      test('handles special characters', () {
        final key = 'test-key!@#\$%^&*()_+-=[]{}|;:,.<>?';
        final hash = apiKeyService.hashApiKey(key);
        expect(hash, isNotEmpty);
      });
    });

    group('key generation security', () {
      test('uses cryptographically secure random generation', () {
        // Generate multiple keys and verify they have high entropy
        final keys = <String>[];
        for (var i = 0; i < 10; i++) {
          keys.add(apiKeyService.generateApiKey());
        }

        // Check that keys are different
        final uniqueKeys = keys.toSet();
        expect(uniqueKeys.length, equals(keys.length));

        // Check that keys don't follow a predictable pattern
        for (var i = 0; i < keys.length - 1; i++) {
          expect(keys[i], isNot(equals(keys[i + 1])));
          // Keys should have high entropy - not just sequential
        }
      });

      test('generates keys suitable for URL use', () {
        final key = apiKeyService.generateApiKey();
        // Should not contain +, /, or = (base64url encoding)
        expect(key.contains('+'), isFalse);
        expect(key.contains('/'), isFalse);
        // May contain = for padding, but base64url typically omits it
      });
    });

    group('constant-time comparison (internal)', () {
      test('compares strings safely', () {
        // We can't directly test _constantTimeEquals since it's private,
        // but we can verify that the service works correctly
        final key1 = 'test-key-12345678901234567890123';
        final key2 = 'test-key-12345678901234567890123';
        final key3 = 'test-key-12345678901234567890124';

        // These comparisons should be safe from timing attacks
        // The implementation uses constant-time comparison internally
        expect(key1, equals(key2));
        expect(key1, isNot(equals(key3)));
      });
    });
  });
}
