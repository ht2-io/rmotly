import 'dart:convert';
import 'dart:math';

/// Service for generating and validating API keys.
///
/// API keys are used for external authentication to notification topics.
class ApiKeyService {
  static final _random = Random.secure();

  /// Generate a secure API key.
  ///
  /// Returns a URL-safe base64-encoded random string.
  /// Format: remotly_{32_chars}
  ///
  /// Example: remotly_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
  String generateApiKey() {
    // Generate 24 random bytes (will be 32 base64 characters)
    final bytes = List<int>.generate(24, (_) => _random.nextInt(256));
    final encoded = base64Url.encode(bytes).replaceAll('=', '');
    return 'remotly_$encoded';
  }

  /// Validate API key format.
  ///
  /// Returns true if the key has the correct format:
  /// - Starts with 'remotly_'
  /// - Followed by 32+ base64url characters
  bool isValidFormat(String apiKey) {
    if (!apiKey.startsWith('remotly_')) {
      return false;
    }

    final keyPart = apiKey.substring(8); // Remove 'remotly_' prefix
    if (keyPart.length < 32) {
      return false;
    }

    // Check if it's valid base64url characters
    final base64UrlPattern = RegExp(r'^[A-Za-z0-9_-]+$');
    return base64UrlPattern.hasMatch(keyPart);
  }
}
