import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

/// Service for encrypting and decrypting sensitive data such as action credentials.
///
/// Uses AES-256-GCM for encryption with a key derived from a master key.
/// Each encrypted value has its own initialization vector (IV) for security.
///
/// Key management:
/// - The encryption key should be stored securely (environment variable, secrets manager)
/// - Key rotation should be implemented for production systems
/// - Never commit encryption keys to version control
class EncryptionService {
  /// Master encryption key (32 bytes for AES-256)
  /// In production, load from secure environment variable
  late final Key _key;

  /// Singleton instance
  static final EncryptionService _instance = EncryptionService._internal();

  factory EncryptionService() => _instance;

  EncryptionService._internal() {
    // Initialize with key from environment or generate for development
    final keyString = _getKeyFromEnvironment();
    _key = Key.fromBase64(keyString);
  }

  /// Initialize with a custom key (for testing)
  EncryptionService.withKey(String base64Key) {
    _key = Key.fromBase64(base64Key);
  }

  /// Get encryption key from environment or generate for development
  String _getKeyFromEnvironment() {
    // Try to get from environment variable
    final envKey = const String.fromEnvironment('RMOTLY_ENCRYPTION_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }

    // Check if running in production
    final isProduction = const bool.fromEnvironment('dart.vm.product');
    if (isProduction) {
      throw StateError(
        'RMOTLY_ENCRYPTION_KEY environment variable is required in production. '
        'Generate a key with: dart run lib/src/services/encryption_service.dart generate-key',
      );
    }

    // For development only, generate a temporary key
    // WARNING: This key is not persisted and will change on restart
    print('⚠️  WARNING: Using temporary encryption key for development');
    print('⚠️  Set RMOTLY_ENCRYPTION_KEY environment variable for production');
    
    final random = Random.secure();
    final keyBytes = Uint8List.fromList(
      List<int>.generate(32, (i) => random.nextInt(256)),
    );
    return base64Url.encode(keyBytes);
  }

  /// Encrypt a string value
  ///
  /// Returns a base64-encoded string in format: IV:CIPHERTEXT
  /// where IV is 16 bytes and CIPHERTEXT is the encrypted data with authentication tag.
  ///
  /// Example:
  /// ```dart
  /// final encrypted = service.encrypt('my-secret-api-key');
  /// ```
  String encrypt(String plaintext) {
    if (plaintext.isEmpty) {
      throw ArgumentError('Cannot encrypt empty string');
    }

    // Generate random IV (16 bytes for AES)
    final iv = IV.fromSecureRandom(16);

    // Create encrypter with AES GCM mode
    final encrypter = Encrypter(AES(_key, mode: AESMode.gcm));

    // Encrypt the plaintext
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    // Combine IV and ciphertext: IV:CIPHERTEXT
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypt a previously encrypted string
  ///
  /// Expects input in format: IV:CIPHERTEXT
  ///
  /// Example:
  /// ```dart
  /// final plaintext = service.decrypt(encryptedValue);
  /// ```
  String decrypt(String ciphertext) {
    if (ciphertext.isEmpty) {
      throw ArgumentError('Cannot decrypt empty string');
    }

    try {
      // Split IV and ciphertext
      final parts = ciphertext.split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid encrypted format. Expected IV:CIPHERTEXT');
      }

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);

      // Create decrypter with AES GCM mode
      final encrypter = Encrypter(AES(_key, mode: AESMode.gcm));

      // Decrypt the ciphertext
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw EncryptionException('Failed to decrypt: $e');
    }
  }

  /// Encrypt a map of credentials
  ///
  /// Useful for encrypting multiple credential fields at once.
  /// Returns a JSON string of the encrypted map.
  ///
  /// Example:
  /// ```dart
  /// final credentials = {'apiKey': 'secret', 'token': 'bearer xyz'};
  /// final encrypted = service.encryptMap(credentials);
  /// ```
  String encryptMap(Map<String, String> credentials) {
    if (credentials.isEmpty) {
      throw ArgumentError('Cannot encrypt empty map');
    }

    final encryptedMap = <String, String>{};
    credentials.forEach((key, value) {
      encryptedMap[key] = encrypt(value);
    });

    return jsonEncode(encryptedMap);
  }

  /// Decrypt a map of credentials
  ///
  /// Decrypts a JSON string created by encryptMap.
  ///
  /// Example:
  /// ```dart
  /// final decrypted = service.decryptMap(encryptedJson);
  /// ```
  Map<String, String> decryptMap(String encryptedJson) {
    if (encryptedJson.isEmpty) {
      throw ArgumentError('Cannot decrypt empty string');
    }

    try {
      final encryptedMap = jsonDecode(encryptedJson) as Map<String, dynamic>;
      final decryptedMap = <String, String>{};

      encryptedMap.forEach((key, value) {
        if (value is String) {
          decryptedMap[key] = decrypt(value);
        }
      });

      return decryptedMap;
    } catch (e) {
      throw EncryptionException('Failed to decrypt map: $e');
    }
  }

  /// Generate a new random encryption key (for key rotation)
  ///
  /// Returns a base64-encoded 32-byte key suitable for AES-256.
  /// Store this securely and never commit to version control.
  ///
  /// Example:
  /// ```dart
  /// final newKey = EncryptionService.generateKey();
  /// // Store newKey in secure location
  /// ```
  static String generateKey() {
    final random = Random.secure();
    final keyBytes = Uint8List.fromList(
      List<int>.generate(32, (i) => random.nextInt(256)),
    );
    return base64Url.encode(keyBytes);
  }

  /// Re-encrypt data with a new key (for key rotation)
  ///
  /// Decrypts with the current key and encrypts with the new key.
  ///
  /// Example:
  /// ```dart
  /// final oldService = EncryptionService();
  /// final newKey = EncryptionService.generateKey();
  /// final newService = EncryptionService.withKey(newKey);
  /// final reencrypted = oldService.reencrypt(oldCiphertext, newService);
  /// ```
  String reencrypt(String oldCiphertext, EncryptionService newService) {
    final plaintext = decrypt(oldCiphertext);
    return newService.encrypt(plaintext);
  }
}

/// Exception thrown when encryption/decryption fails
class EncryptionException implements Exception {
  final String message;

  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
