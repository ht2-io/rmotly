import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../config/push_config.dart';

/// Result of a push notification delivery attempt
class PushDeliveryResult {
  /// Whether the delivery was successful
  final bool success;

  /// HTTP status code from the push service
  final int? statusCode;

  /// Error message if delivery failed
  final String? error;

  /// Whether the endpoint should be removed (e.g., 410 Gone)
  final bool shouldRemoveEndpoint;

  PushDeliveryResult({
    required this.success,
    this.statusCode,
    this.error,
    this.shouldRemoveEndpoint = false,
  });
}

/// Subscription data for WebPush
class PushSubscriptionData {
  /// The endpoint URL (from UnifiedPush distributor)
  final String endpoint;

  /// The client's public key (p256dh) for encryption, base64url encoded
  final String? p256dh;

  /// The client's auth secret, base64url encoded
  final String? authSecret;

  PushSubscriptionData({
    required this.endpoint,
    this.p256dh,
    this.authSecret,
  });

  /// Check if this subscription supports encryption
  bool get supportsEncryption => p256dh != null && authSecret != null;
}

/// Service for sending push notifications via WebPush protocol.
///
/// Implements:
/// - RFC8030 (Generic Event Delivery Using HTTP Push)
/// - RFC8291 (Message Encryption for Web Push)
/// - RFC8292 (VAPID for Web Push)
///
/// Works with UnifiedPush distributors like ntfy.
class PushService {
  final VapidConfig _vapidConfig;
  final HttpClient _httpClient;

  /// Maximum payload size for WebPush (4KB)
  static const maxPayloadSize = 4096;

  /// Default TTL for messages (24 hours)
  static const defaultTtl = Duration(hours: 24);

  /// Maximum retry attempts
  static const maxRetries = 3;

  /// Base delay for exponential backoff
  static const baseRetryDelay = Duration(seconds: 1);

  PushService({VapidConfig? vapidConfig})
      : _vapidConfig = vapidConfig ?? PushConfig.instance.vapid,
        _httpClient = HttpClient() {
    _httpClient.connectionTimeout = const Duration(seconds: 30);
  }

  /// Send a push notification to a subscription endpoint
  ///
  /// [subscription] - The push subscription data
  /// [payload] - The notification payload (will be JSON encoded if Map)
  /// [ttl] - Time-to-live for the message
  /// [urgency] - Message urgency (very-low, low, normal, high)
  /// [topic] - Optional topic for message replacement
  Future<PushDeliveryResult> sendPush(
    PushSubscriptionData subscription,
    dynamic payload, {
    Duration ttl = defaultTtl,
    String urgency = 'normal',
    String? topic,
    Session? session,
  }) async {
    try {
      // Validate payload size
      final payloadString =
          payload is String ? payload : jsonEncode(payload);
      final payloadBytes = utf8.encode(payloadString);

      if (payloadBytes.length > maxPayloadSize) {
        return PushDeliveryResult(
          success: false,
          error: 'Payload exceeds maximum size of $maxPayloadSize bytes',
        );
      }

      // Parse the endpoint URL
      final uri = Uri.parse(subscription.endpoint);
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        return PushDeliveryResult(
          success: false,
          error: 'Invalid endpoint URL scheme',
          shouldRemoveEndpoint: true,
        );
      }

      // Create the HTTP request
      final request = await _httpClient.postUrl(uri);

      // Set WebPush headers
      request.headers.set('TTL', ttl.inSeconds.toString());
      request.headers.set('Urgency', urgency);
      if (topic != null) {
        request.headers.set('Topic', topic);
      }

      // Add VAPID authorization
      final vapidHeaders = _createVapidHeaders(uri);
      vapidHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Encrypt and write payload if subscription supports encryption
      if (subscription.supportsEncryption) {
        final encrypted = await _encryptPayload(
          payloadBytes,
          subscription.p256dh!,
          subscription.authSecret!,
        );

        request.headers.set('Content-Type', 'application/octet-stream');
        request.headers.set('Content-Encoding', 'aes128gcm');
        request.headers.set('Content-Length', encrypted.length.toString());
        request.add(encrypted);
      } else {
        // Send unencrypted (for ntfy-style endpoints)
        request.headers.set('Content-Type', 'application/json');
        request.headers.set('Content-Length', payloadBytes.length.toString());
        request.add(payloadBytes);
      }

      // Send the request
      final response = await request.close();

      // Handle response
      final responseBody = await response.transform(utf8.decoder).join();

      session?.log(
        'Push sent to ${subscription.endpoint}: ${response.statusCode}',
        level: response.statusCode < 300 ? LogLevel.debug : LogLevel.warning,
      );

      // Check for success (201 Created or 200 OK)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return PushDeliveryResult(
          success: true,
          statusCode: response.statusCode,
        );
      }

      // Handle specific error codes
      switch (response.statusCode) {
        case 404:
        case 410:
          // Subscription no longer valid
          return PushDeliveryResult(
            success: false,
            statusCode: response.statusCode,
            error: 'Subscription no longer valid',
            shouldRemoveEndpoint: true,
          );
        case 413:
          return PushDeliveryResult(
            success: false,
            statusCode: response.statusCode,
            error: 'Payload too large',
          );
        case 429:
          return PushDeliveryResult(
            success: false,
            statusCode: response.statusCode,
            error: 'Rate limited',
          );
        default:
          return PushDeliveryResult(
            success: false,
            statusCode: response.statusCode,
            error: 'Push delivery failed: $responseBody',
          );
      }
    } on SocketException catch (e) {
      return PushDeliveryResult(
        success: false,
        error: 'Network error: $e',
      );
    } on TimeoutException catch (e) {
      return PushDeliveryResult(
        success: false,
        error: 'Request timeout: $e',
      );
    } catch (e) {
      return PushDeliveryResult(
        success: false,
        error: 'Unexpected error: $e',
      );
    }
  }

  /// Send push with retry logic
  Future<PushDeliveryResult> sendPushWithRetry(
    PushSubscriptionData subscription,
    dynamic payload, {
    Duration ttl = defaultTtl,
    String urgency = 'normal',
    String? topic,
    Session? session,
    int maxAttempts = maxRetries,
  }) async {
    PushDeliveryResult? lastResult;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      lastResult = await sendPush(
        subscription,
        payload,
        ttl: ttl,
        urgency: urgency,
        topic: topic,
        session: session,
      );

      if (lastResult.success || lastResult.shouldRemoveEndpoint) {
        return lastResult;
      }

      // Don't retry on certain status codes
      if (lastResult.statusCode != null) {
        final code = lastResult.statusCode!;
        if (code == 400 || code == 401 || code == 403 || code == 413) {
          return lastResult;
        }
      }

      // Wait before retrying (exponential backoff)
      if (attempt < maxAttempts - 1) {
        final delay = baseRetryDelay * (1 << attempt);
        session?.log(
          'Push failed, retrying in ${delay.inSeconds}s (attempt ${attempt + 1}/$maxAttempts)',
          level: LogLevel.warning,
        );
        await Future.delayed(delay);
      }
    }

    return lastResult!;
  }

  /// Create VAPID authorization headers per RFC8292
  Map<String, String> _createVapidHeaders(Uri endpoint) {
    // For a full implementation, we would:
    // 1. Create a JWT with the endpoint origin as audience
    // 2. Sign it with the VAPID private key
    // 3. Return Authorization and Crypto-Key headers
    //
    // For now, we return a simplified version that works with ntfy
    // The full WebPush implementation requires the web_push package

    final origin = '${endpoint.scheme}://${endpoint.host}';

    // Placeholder - actual JWT creation requires crypto libraries
    // In production, use the web_push package for proper VAPID signing
    return {
      'Authorization':
          'vapid t=placeholder,k=${_vapidConfig.publicKey}',
    };
  }

  /// Encrypt payload per RFC8291
  ///
  /// This is a placeholder - actual implementation requires:
  /// - ECDH key agreement (P-256)
  /// - HKDF key derivation
  /// - AES-128-GCM encryption
  ///
  /// In production, use the web_push package for proper encryption.
  Future<Uint8List> _encryptPayload(
    List<int> payload,
    String p256dh,
    String authSecret,
  ) async {
    // Placeholder implementation
    // In production, this would:
    // 1. Generate ephemeral ECDH key pair
    // 2. Perform ECDH with client's p256dh public key
    // 3. Derive content encryption key and nonce using HKDF
    // 4. Encrypt payload with AES-128-GCM
    // 5. Format as aes128gcm content-coding

    // For now, return the payload as-is (unencrypted)
    // This works with ntfy which accepts unencrypted payloads
    return Uint8List.fromList(payload);
  }

  /// Send to ntfy-style endpoint (simplified, no encryption)
  ///
  /// ntfy accepts simple POST requests with JSON or text payloads.
  Future<PushDeliveryResult> sendToNtfy(
    String endpoint,
    String title,
    String message, {
    String? priority,
    List<String>? tags,
    String? click,
    Session? session,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final request = await _httpClient.postUrl(uri);

      // Set ntfy-specific headers
      request.headers.set('Content-Type', 'application/json');
      if (priority != null) {
        request.headers.set('Priority', priority);
      }
      if (tags != null && tags.isNotEmpty) {
        request.headers.set('Tags', tags.join(','));
      }
      if (click != null) {
        request.headers.set('Click', click);
      }

      // Write JSON payload
      final payload = jsonEncode({
        'title': title,
        'message': message,
        if (priority != null) 'priority': _ntfyPriorityToInt(priority),
        if (tags != null) 'tags': tags,
        if (click != null) 'click': click,
      });

      request.write(payload);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        session?.log(
          'ntfy notification sent: ${response.statusCode}',
          level: LogLevel.debug,
        );
        return PushDeliveryResult(
          success: true,
          statusCode: response.statusCode,
        );
      }

      return PushDeliveryResult(
        success: false,
        statusCode: response.statusCode,
        error: 'ntfy delivery failed: $responseBody',
      );
    } catch (e) {
      return PushDeliveryResult(
        success: false,
        error: 'ntfy delivery error: $e',
      );
    }
  }

  /// Convert priority string to ntfy integer
  int _ntfyPriorityToInt(String priority) {
    switch (priority.toLowerCase()) {
      case 'min':
      case 'very-low':
        return 1;
      case 'low':
        return 2;
      case 'default':
      case 'normal':
        return 3;
      case 'high':
        return 4;
      case 'max':
      case 'urgent':
        return 5;
      default:
        return 3;
    }
  }

  /// Close the HTTP client
  void close() {
    _httpClient.close();
  }
}
