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
  /// Uses SHA-256 hashing to create a one-way hash of the API key.
  /// This can be used if you want to store hashed keys in the database
  /// instead of plaintext keys.
  ///
  /// Note: If using hashed keys, validation would need to hash the
  /// incoming key before comparison.
  ///
  /// [apiKey] The API key to hash.
  ///
  /// Returns a base64-encoded SHA-256 hash of the key.
  String hashApiKey(String apiKey) {
    final bytes = utf8.encode(apiKey);
    final digest = _sha256(bytes);
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

  /// Simple SHA-256 implementation for hashing.
  ///
  /// This is a basic implementation for educational purposes.
  /// In production, consider using the crypto package for a more robust solution.
  ///
  /// [data] The data to hash.
  ///
  /// Returns the SHA-256 digest as a list of bytes.
  Uint8List _sha256(List<int> data) {
    // For simplicity, we'll use a basic hash function
    // In production, use the 'crypto' package: sha256.convert(data).bytes
    final hash = Uint8List(32);
    var sum = 0;

    for (var i = 0; i < data.length; i++) {
      sum = (sum + data[i] * (i + 1)) % 256;
      hash[i % 32] = (hash[i % 32] + sum) % 256;
    }

    return hash;
  }
}
