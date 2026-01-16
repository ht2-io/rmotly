import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive data on the device.
///
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: KeyStore
/// - Web: Encrypted storage with Web Crypto API
///
/// Use this for storing:
/// - Authentication tokens
/// - API keys
/// - User credentials
/// - Sensitive user preferences
///
/// Example:
/// ```dart
/// final storage = SecureStorageService();
/// await storage.write('apiKey', 'secret-key-123');
/// final apiKey = await storage.read('apiKey');
/// ```
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();

  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  /// The underlying secure storage implementation
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Write a value to secure storage
  ///
  /// [key] - The key to store the value under
  /// [value] - The value to store (will be stored as string)
  ///
  /// Example:
  /// ```dart
  /// await storage.write('auth_token', 'bearer xyz123');
  /// ```
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException('Failed to write to secure storage: $e');
    }
  }

  /// Read a value from secure storage
  ///
  /// [key] - The key to retrieve the value for
  /// Returns the stored value or null if not found
  ///
  /// Example:
  /// ```dart
  /// final token = await storage.read('auth_token');
  /// ```
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to read from secure storage: $e');
    }
  }

  /// Delete a value from secure storage
  ///
  /// [key] - The key to delete
  ///
  /// Example:
  /// ```dart
  /// await storage.delete('auth_token');
  /// ```
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to delete from secure storage: $e');
    }
  }

  /// Delete all values from secure storage
  ///
  /// Use with caution - this will remove all stored data
  ///
  /// Example:
  /// ```dart
  /// await storage.deleteAll();
  /// ```
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to clear secure storage: $e');
    }
  }

  /// Check if a key exists in secure storage
  ///
  /// [key] - The key to check
  /// Returns true if the key exists, false otherwise
  ///
  /// Example:
  /// ```dart
  /// if (await storage.containsKey('auth_token')) {
  ///   // Token exists
  /// }
  /// ```
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to check secure storage: $e');
    }
  }

  /// Read all keys from secure storage
  ///
  /// Returns a map of all stored key-value pairs
  /// Use sparingly as this reads all stored data
  ///
  /// Example:
  /// ```dart
  /// final allData = await storage.readAll();
  /// ```
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw SecureStorageException('Failed to read all from secure storage: $e');
    }
  }

  // Common keys used throughout the app
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String apiKeyKey = 'api_key';

  /// Convenience method to store authentication token
  Future<void> saveAuthToken(String token) => write(authTokenKey, token);

  /// Convenience method to get authentication token
  Future<String?> getAuthToken() => read(authTokenKey);

  /// Convenience method to delete authentication token
  Future<void> deleteAuthToken() => delete(authTokenKey);

  /// Convenience method to store refresh token
  Future<void> saveRefreshToken(String token) => write(refreshTokenKey, token);

  /// Convenience method to get refresh token
  Future<String?> getRefreshToken() => read(refreshTokenKey);

  /// Convenience method to clear all authentication data
  Future<void> clearAuthData() async {
    await delete(authTokenKey);
    await delete(refreshTokenKey);
    await delete(userIdKey);
  }
}

/// Exception thrown when secure storage operations fail
class SecureStorageException implements Exception {
  final String message;

  SecureStorageException(this.message);

  @override
  String toString() => 'SecureStorageException: $message';
}
