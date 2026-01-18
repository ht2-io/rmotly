import 'dart:async';

/// Configuration for rate limiting
class RateLimitConfig {
  /// Maximum number of requests allowed in the time window
  final int maxRequests;

  /// Time window for rate limiting
  final Duration window;

  const RateLimitConfig({
    required this.maxRequests,
    required this.window,
  });

  /// Default configuration for webhook endpoints (100 req/min)
  static const webhook = RateLimitConfig(
    maxRequests: 100,
    window: Duration(minutes: 1),
  );

  /// Default configuration for user events (1000 req/min)
  static const userEvents = RateLimitConfig(
    maxRequests: 1000,
    window: Duration(minutes: 1),
  );

  /// Default configuration for OpenAPI operations (10 req/min)
  static const openApi = RateLimitConfig(
    maxRequests: 10,
    window: Duration(minutes: 1),
  );

  /// Strict configuration for auth endpoints (5 req/min)
  static const auth = RateLimitConfig(
    maxRequests: 5,
    window: Duration(minutes: 1),
  );
}

/// Service for rate limiting API requests.
///
/// Implements a sliding window rate limiter that tracks requests per key.
/// Keys can represent users, API keys, topics, or any other identifier.
///
/// Features:
/// - Sliding window algorithm (more accurate than fixed window)
/// - Automatic cleanup of old request records
/// - Memory-efficient storage
/// - Thread-safe operations
///
/// Example:
/// ```dart
/// final rateLimiter = RateLimitService(RateLimitConfig.webhook);
///
/// if (rateLimiter.isRateLimited('user-123')) {
///   throw RateLimitException('Too many requests');
/// }
/// ```
class RateLimitService {
  /// Rate limit configuration
  final RateLimitConfig config;

  /// Map of keys to their request timestamps
  final Map<String, List<DateTime>> _requests = {};

  /// Timer for periodic cleanup of old records
  Timer? _cleanupTimer;

  RateLimitService(this.config) {
    // Start periodic cleanup every 5 minutes
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanup();
    });
  }

  /// Check if a key is rate limited and record the request
  ///
  /// Returns true if the key has exceeded the rate limit.
  /// If not rate limited, records the current request.
  ///
  /// [key] - Unique identifier (user ID, API key, topic ID, etc.)
  ///
  /// Example:
  /// ```dart
  /// if (rateLimiter.isRateLimited('user-123')) {
  ///   return Response(429, 'Too Many Requests');
  /// }
  /// ```
  bool isRateLimited(String key) {
    final now = DateTime.now();
    final windowStart = now.subtract(config.window);

    // Clean old requests for this key
    _requests[key]?.removeWhere((t) => t.isBefore(windowStart));

    // Check if limit exceeded
    final count = _requests[key]?.length ?? 0;
    if (count >= config.maxRequests) {
      return true;
    }

    // Record this request
    _requests.putIfAbsent(key, () => []);
    _requests[key]!.add(now);

    return false;
  }

  /// Check if a key is rate limited without recording the request
  ///
  /// Useful for checking rate limit status without counting towards the limit.
  ///
  /// [key] - Unique identifier to check
  ///
  /// Returns true if the key has exceeded the rate limit.
  bool checkRateLimit(String key) {
    final now = DateTime.now();
    final windowStart = now.subtract(config.window);

    // Count requests in current window
    final requests = _requests[key];
    if (requests == null) return false;

    final validRequests = requests.where((t) => t.isAfter(windowStart)).length;
    return validRequests >= config.maxRequests;
  }

  /// Get remaining requests for a key
  ///
  /// Returns the number of requests remaining before rate limit is hit.
  ///
  /// [key] - Unique identifier to check
  int getRemainingRequests(String key) {
    final now = DateTime.now();
    final windowStart = now.subtract(config.window);

    final requests = _requests[key];
    if (requests == null) return config.maxRequests;

    final validRequests = requests.where((t) => t.isAfter(windowStart)).length;
    return (config.maxRequests - validRequests).clamp(0, config.maxRequests);
  }

  /// Get time until rate limit resets for a key
  ///
  /// Returns null if not currently rate limited, or the duration until
  /// the oldest request expires from the window.
  ///
  /// [key] - Unique identifier to check
  Duration? getResetTime(String key) {
    final requests = _requests[key];
    if (requests == null || requests.isEmpty) return null;

    final now = DateTime.now();
    final windowStart = now.subtract(config.window);
    final validRequests =
        requests.where((t) => t.isAfter(windowStart)).toList();

    if (validRequests.length < config.maxRequests) return null;

    // Time until oldest request expires
    validRequests.sort();
    final oldestRequest = validRequests.first;
    final resetTime = oldestRequest.add(config.window);
    return resetTime.difference(now);
  }

  /// Get rate limit info for a key
  ///
  /// Returns a map with rate limit information useful for response headers.
  ///
  /// [key] - Unique identifier to check
  Map<String, dynamic> getRateLimitInfo(String key) {
    final remaining = getRemainingRequests(key);
    final resetTime = getResetTime(key);

    return {
      'limit': config.maxRequests,
      'remaining': remaining,
      'reset': resetTime != null
          ? DateTime.now().add(resetTime).toUtc().toIso8601String()
          : null,
      'resetInSeconds': resetTime?.inSeconds,
    };
  }

  /// Reset rate limit for a specific key
  ///
  /// Useful for testing or manual intervention.
  ///
  /// [key] - Unique identifier to reset
  void reset(String key) {
    _requests.remove(key);
  }

  /// Reset rate limits for all keys
  ///
  /// Use with caution - this clears all rate limit tracking.
  void resetAll() {
    _requests.clear();
  }

  /// Clean up old request records for all keys
  ///
  /// Removes expired requests to free memory.
  /// Called automatically by periodic timer.
  void _cleanup() {
    final now = DateTime.now();
    final windowStart = now.subtract(config.window);

    // Collect keys to remove
    final keysToRemove = <String>[];

    // Remove expired requests
    _requests.forEach((key, requests) {
      requests.removeWhere((t) => t.isBefore(windowStart));
      if (requests.isEmpty) {
        keysToRemove.add(key);
      }
    });

    // Remove empty entries
    for (final key in keysToRemove) {
      _requests.remove(key);
    }
  }

  /// Dispose of the rate limiter
  ///
  /// Cancels the cleanup timer and clears all data.
  /// Should be called when the rate limiter is no longer needed.
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _requests.clear();
  }
}

/// Exception thrown when rate limit is exceeded
class RateLimitException implements Exception {
  final String message;
  final RateLimitInfo? info;

  RateLimitException(this.message, {this.info});

  @override
  String toString() => 'RateLimitException: $message';
}

/// Rate limit information for error responses
class RateLimitInfo {
  final int limit;
  final int remaining;
  final DateTime? resetAt;

  RateLimitInfo({
    required this.limit,
    required this.remaining,
    this.resetAt,
  });

  Map<String, dynamic> toJson() => {
        'limit': limit,
        'remaining': remaining,
        if (resetAt != null) 'resetAt': resetAt!.toIso8601String(),
      };
}
