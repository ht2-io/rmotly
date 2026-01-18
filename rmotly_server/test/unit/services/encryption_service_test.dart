import 'package:test/test.dart';
import 'package:rmotly_server/src/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    late EncryptionService service;
    const testKey =
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='; // 32 bytes base64

    setUp(() {
      service = EncryptionService.withKey(testKey);
    });

    test('encrypts and decrypts a string correctly', () {
      const plaintext = 'my-secret-api-key';
      final encrypted = service.encrypt(plaintext);
      final decrypted = service.decrypt(encrypted);

      expect(decrypted, equals(plaintext));
    });

    test('encrypted value contains IV and ciphertext', () {
      const plaintext = 'test-value';
      final encrypted = service.encrypt(plaintext);

      // Should be in format IV:CIPHERTEXT
      expect(encrypted, contains(':'));
      final parts = encrypted.split(':');
      expect(parts.length, equals(2));
    });

    test('different encryptions produce different ciphertexts', () {
      const plaintext = 'same-value';
      final encrypted1 = service.encrypt(plaintext);
      final encrypted2 = service.encrypt(plaintext);

      // Due to random IV, ciphertexts should be different
      expect(encrypted1, isNot(equals(encrypted2)));

      // But both should decrypt to same plaintext
      expect(service.decrypt(encrypted1), equals(plaintext));
      expect(service.decrypt(encrypted2), equals(plaintext));
    });

    test('throws on empty string encryption', () {
      expect(
        () => service.encrypt(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on empty string decryption', () {
      expect(
        () => service.decrypt(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on invalid encrypted format', () {
      expect(
        () => service.decrypt('invalid-format'),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('throws on corrupted ciphertext', () {
      const plaintext = 'test';
      final encrypted = service.encrypt(plaintext);

      // Corrupt the IV part
      final parts = encrypted.split(':');
      final corruptedIv = parts[0].replaceFirst(parts[0][0], 'X');
      final corrupted = '$corruptedIv:${parts[1]}';

      expect(
        () => service.decrypt(corrupted),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('encrypts and decrypts a map correctly', () {
      final credentials = {
        'apiKey': 'secret-key-123',
        'token': 'bearer-xyz-789',
        'password': 'super-secret',
      };

      final encrypted = service.encryptMap(credentials);
      final decrypted = service.decryptMap(encrypted);

      expect(decrypted, equals(credentials));
    });

    test('throws on empty map encryption', () {
      expect(
        () => service.encryptMap({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('generates valid encryption key', () {
      final key = EncryptionService.generateKey();

      // Should be base64 encoded
      expect(key, isNotEmpty);

      // Should be usable for creating a service
      final testService = EncryptionService.withKey(key);
      const plaintext = 'test';
      final encrypted = testService.encrypt(plaintext);
      final decrypted = testService.decrypt(encrypted);

      expect(decrypted, equals(plaintext));
    });

    test('reencrypts with new key', () {
      const plaintext = 'original-secret';
      final oldService = EncryptionService.withKey(testKey);
      final newKey = EncryptionService.generateKey();
      final newService = EncryptionService.withKey(newKey);

      // Encrypt with old key
      final oldEncrypted = oldService.encrypt(plaintext);

      // Reencrypt with new key
      final newEncrypted = oldService.reencrypt(oldEncrypted, newService);

      // Should decrypt with new key
      final decrypted = newService.decrypt(newEncrypted);
      expect(decrypted, equals(plaintext));

      // Should not decrypt with old key
      expect(
        () => oldService.decrypt(newEncrypted),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('handles special characters', () {
      const plaintext = 'key-with-!@#\$%^&*()_+-=[]{}|;:\'",.<>?/~`';
      final encrypted = service.encrypt(plaintext);
      final decrypted = service.decrypt(encrypted);

      expect(decrypted, equals(plaintext));
    });

    test('handles unicode characters', () {
      const plaintext = 'こんにちは世界 🌍 مرحبا';
      final encrypted = service.encrypt(plaintext);
      final decrypted = service.decrypt(encrypted);

      expect(decrypted, equals(plaintext));
    });

    test('handles long strings', () {
      final plaintext = 'x' * 10000;
      final encrypted = service.encrypt(plaintext);
      final decrypted = service.decrypt(encrypted);

      expect(decrypted, equals(plaintext));
    });
  });
}
