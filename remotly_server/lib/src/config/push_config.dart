import 'dart:io';

/// Configuration for WebPush VAPID authentication.
///
/// Reads from environment variables or uses development defaults.
/// In production, set these environment variables:
///   - VAPID_SUBJECT: Contact email (mailto:admin@example.com)
///   - VAPID_PUBLIC_KEY: Base64url-encoded public key
///   - VAPID_PRIVATE_KEY: Base64url-encoded private key
class VapidConfig {
  /// Contact email for VAPID (e.g., mailto:admin@example.com)
  final String subject;

  /// Base64url-encoded public key (safe to share with clients)
  final String publicKey;

  /// Base64url-encoded private key (keep secret)
  final String privateKey;

  VapidConfig({
    required this.subject,
    required this.publicKey,
    required this.privateKey,
  });

  /// Development defaults - DO NOT use in production
  static const _devSubject = 'mailto:admin@localhost';
  static const _devPublicKey =
      'BEl62iUYgUivxIkv69yViEuiBIa-Ib9-SkvMeAtA3LFgDzkrxZJjSgSnfckjBJuBkr3qBUYIHBQFLXYp5Nksh8U';
  static const _devPrivateKey = 'UUxI4O8-FbRouADVXGXRV1Nv7bQZwA7UcL1QQXDJ3Gg';

  /// Load VAPID configuration from environment or use development defaults
  factory VapidConfig.fromEnvironment() {
    final subject = Platform.environment['VAPID_SUBJECT'] ?? _devSubject;
    final publicKey = Platform.environment['VAPID_PUBLIC_KEY'] ?? _devPublicKey;
    final privateKey =
        Platform.environment['VAPID_PRIVATE_KEY'] ?? _devPrivateKey;

    if (subject.isEmpty) {
      throw StateError(
          'VAPID_SUBJECT is required (e.g., mailto:admin@example.com)');
    }
    if (publicKey.isEmpty) {
      throw StateError('VAPID_PUBLIC_KEY is required');
    }
    if (privateKey.isEmpty) {
      throw StateError('VAPID_PRIVATE_KEY is required');
    }

    return VapidConfig(
      subject: subject,
      publicKey: publicKey,
      privateKey: privateKey,
    );
  }

  /// Check if using development keys (not safe for production)
  bool get isUsingDevKeys =>
      publicKey == _devPublicKey && privateKey == _devPrivateKey;
}

/// Configuration for ntfy push server.
class NtfyConfig {
  /// Base URL of the ntfy server (e.g., http://localhost:8093)
  final String baseUrl;

  /// Default topic name for notifications
  final String defaultTopic;

  NtfyConfig({
    required this.baseUrl,
    required this.defaultTopic,
  });

  /// Development defaults
  static const _devBaseUrl = 'http://localhost:8093';
  static const _devDefaultTopic = 'remotly';

  /// Load ntfy configuration from environment or use development defaults
  factory NtfyConfig.fromEnvironment() {
    final baseUrl = Platform.environment['NTFY_BASE_URL'] ?? _devBaseUrl;
    final defaultTopic =
        Platform.environment['NTFY_DEFAULT_TOPIC'] ?? _devDefaultTopic;

    if (baseUrl.isEmpty) {
      throw StateError('NTFY_BASE_URL is required');
    }
    if (defaultTopic.isEmpty) {
      throw StateError('NTFY_DEFAULT_TOPIC is required');
    }

    return NtfyConfig(
      baseUrl: baseUrl,
      defaultTopic: defaultTopic,
    );
  }
}

/// Combined push notification configuration
class PushConfig {
  final VapidConfig vapid;
  final NtfyConfig ntfy;

  PushConfig({required this.vapid, required this.ntfy});

  /// Load all push configuration from environment
  factory PushConfig.fromEnvironment() {
    return PushConfig(
      vapid: VapidConfig.fromEnvironment(),
      ntfy: NtfyConfig.fromEnvironment(),
    );
  }

  /// Singleton instance
  static PushConfig? _instance;

  /// Get the singleton instance, loading from environment on first access
  static PushConfig get instance {
    _instance ??= PushConfig.fromEnvironment();
    return _instance!;
  }

  /// Reset the singleton (useful for testing)
  static void reset() {
    _instance = null;
  }
}
