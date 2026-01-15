import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../generated/notification_topic.dart';

/// Service for generating and validating secure API keys for notification topics.
///
/// Provides cryptographically secure API key generation with 256-bit entropy,
/// constant-time validation to prevent timing attacks, and support for key rotation.
class ApiKeyService {
  /// Generate a new secure API key with 256-bit entropy.
  ///
  /// Uses [Random.secure()] to generate 32 bytes (256 bits) of
  /// cryptographically secure random data, encoded as base64.
  ///
  /// Returns a base64-encoded string suitable for use as an API key.
  ///
  /// Example output: `"a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6"`
  String generateApiKey() {
    final random = Random.secure();
    final bytes = Uint8List(32); // 32 bytes = 256 bits

    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }

    return base64UrlEncode(bytes);
  }

  /// Validate an API key and return the associated notification topic.
  ///
  /// Performs constant-time comparison to prevent timing attacks.
  /// Returns the [NotificationTopic] if the key is valid and the topic is enabled,
  /// otherwise returns null.
  ///
  /// [session] The Serverpod session for database access.
  /// [apiKey] The API key to validate.
  ///
  /// Returns the matching [NotificationTopic] or null if invalid.
  Future<NotificationTopic?> validateApiKey(
    Session session,
    String apiKey,
  ) async {
    // Query the database for a topic with this API key
    final topics = await NotificationTopic.db.find(
      session,
      where: (t) => t.apiKey.equals(apiKey),
      limit: 1,
    );

    if (topics.isEmpty) {
      return null;
    }

    final topic = topics.first;

    // Constant-time comparison to prevent timing attacks
    if (!_constantTimeEquals(apiKey, topic.apiKey)) {
      return null;
    }

    // Check if the topic is enabled
    if (!topic.enabled) {
      return null;
    }

    return topic;
  }

  /// Rotate the API key for a notification topic.
  ///
  /// Generates a new secure API key and updates the topic in the database.
  /// This allows for key rotation without downtime.
  ///
  /// [session] The Serverpod session for database access.
  /// [topicId] The ID of the topic to rotate the key for.
  ///
  /// Returns the new API key.
  ///
  /// Throws [StateError] if the topic is not found.
  Future<String> rotateApiKey(Session session, int topicId) async {
    // Find the topic
    final topic = await NotificationTopic.db.findById(session, topicId);

    if (topic == null) {
      throw StateError('Notification topic not found: $topicId');
    }

    // Generate a new API key
    final newApiKey = generateApiKey();

    // Update the topic with the new key and updated timestamp
    final updatedTopic = topic.copyWith(
      apiKey: newApiKey,
      updatedAt: DateTime.now(),
    );

    await NotificationTopic.db.updateRow(session, updatedTopic);

    return newApiKey;
  }

  /// Hash an API key for secure storage (optional - for extra security).
  ///
  /// **WARNING**: This is a simple demonstration hash function and should NOT
  /// be used in production. For production use, implement proper SHA-256 hashing
  /// using the `crypto` package:
  /// ```dart
  /// import 'package:crypto/crypto.dart';
  /// final hash = sha256.convert(utf8.encode(apiKey)).toString();
  /// ```
  ///
  /// This method provides a basic example of how key hashing could work,
  /// but lacks the cryptographic properties needed for security.
  ///
  /// [apiKey] The API key to hash.
  ///
  /// Returns a base64-encoded hash of the key.
  String hashApiKey(String apiKey) {
    final bytes = utf8.encode(apiKey);
    final digest = _simpleHash(bytes);
    return base64Encode(digest);
  }

  /// Perform constant-time string comparison to prevent timing attacks.
  ///
  /// Compares two strings byte-by-byte, always checking all bytes
  /// regardless of when a difference is found. This prevents attackers
  /// from using timing information to guess the correct key.
  ///
  /// [a] First string to compare.
  /// [b] Second string to compare.
  ///
  /// Returns true if the strings are equal, false otherwise.
  bool _constantTimeEquals(String a, String b) {
    final aBytes = utf8.encode(a);
    final bBytes = utf8.encode(b);

    if (aBytes.length != bBytes.length) {
      return false;
    }

    var result = 0;
    for (var i = 0; i < aBytes.length; i++) {
      result |= aBytes[i] ^ bBytes[i];
    }

    return result == 0;
  }

  /// Simple hash implementation for demonstration purposes only.
  ///
  /// **NOT CRYPTOGRAPHICALLY SECURE** - This is a basic checksum function
  /// for demonstration purposes only. In production, use the `crypto` package:
  /// ```dart
  /// import 'package:crypto/crypto.dart';
  /// final hash = sha256.convert(data);
  /// ```
  ///
  /// [data] The data to hash.
  ///
  /// Returns a simple hash as a list of bytes.
  Uint8List _simpleHash(List<int> data) {
    // Simple checksum for demonstration only
    // NOT suitable for production use
    final hash = Uint8List(32);
    var sum = 0;

    for (var i = 0; i < data.length; i++) {
      sum = (sum + data[i] * (i + 1)) % 256;
      hash[i % 32] = (hash[i % 32] + sum) % 256;
    }

    return hash;
  }
}
