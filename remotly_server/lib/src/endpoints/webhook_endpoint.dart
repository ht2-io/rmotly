import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../services/notification_service.dart';

/// Rate limiting configuration
class _RateLimitConfig {
  final int maxRequests;
  final Duration window;
  final Map<String, List<DateTime>> _requests = {};

  _RateLimitConfig({
    this.maxRequests = 100,
    this.window = const Duration(minutes: 1),
  });

  bool isRateLimited(String key) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    // Clean old requests
    _requests[key]?.removeWhere((t) => t.isBefore(windowStart));

    // Check limit
    final count = _requests[key]?.length ?? 0;
    if (count >= maxRequests) {
      return true;
    }

    // Record request
    _requests.putIfAbsent(key, () => []);
    _requests[key]!.add(now);
    return false;
  }
}

/// Webhook handler for external notification ingestion.
///
/// Route: POST /api/notify/{topicId}
///
/// This handler receives notifications from external services
/// and queues them for delivery to users.
///
/// Authentication is via API key in the X-API-Key header.
///
/// Note: This requires custom route registration in Serverpod:
/// ```dart
/// server.webServer.addRoute(
///   RouteDefinition(
///     '/api/notify/:topicId',
///     WebhookHandler(server),
///   ),
/// );
/// ```
class WebhookHandler {
  final Serverpod _pod;
  final NotificationService _notificationService;
  final _RateLimitConfig _rateLimiter;

  WebhookHandler(this._pod)
      : _notificationService = NotificationService(),
        _rateLimiter = _RateLimitConfig();

  /// Handle incoming webhook request
  Future<void> handleRequest(HttpRequest request, String topicId) async {
    final response = request.response;
    final startTime = DateTime.now();

    try {
      // Only accept POST requests
      if (request.method != 'POST') {
        await _sendError(response, HttpStatus.methodNotAllowed, 'Method not allowed');
        return;
      }

      // Extract API key
      final apiKey = request.headers.value('X-API-Key');
      if (apiKey == null || apiKey.isEmpty) {
        await _sendError(response, HttpStatus.unauthorized, 'Missing API key');
        return;
      }

      // Rate limiting by API key
      if (_rateLimiter.isRateLimited(apiKey)) {
        await _sendError(response, HttpStatus.tooManyRequests, 'Rate limit exceeded');
        return;
      }

      // Validate API key and get topic
      final topic = await _validateApiKey(apiKey, topicId);
      if (topic == null) {
        await _sendError(response, HttpStatus.unauthorized, 'Invalid API key');
        return;
      }

      // Parse request body
      final body = await utf8.decoder.bind(request).join();
      if (body.isEmpty) {
        await _sendError(response, HttpStatus.badRequest, 'Empty request body');
        return;
      }

      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        await _sendError(response, HttpStatus.badRequest, 'Invalid JSON payload');
        return;
      }

      // Parse the notification payload
      final notification = _parsePayload(payload);

      // Create notification data
      final notificationData = NotificationData(
        userId: topic['userId'] as int,
        topicId: topic['id'] as int,
        title: notification['title'] as String? ?? 'Notification',
        body: notification['body'] as String? ?? '',
        data: notification['data'] as Map<String, dynamic>?,
        priority: notification['priority'] as String? ?? 'normal',
      );

      // Deliver the notification
      final result = await _notificationService.deliver(
        await _pod.createSession(),
        notificationData,
      );

      // Log the request
      final duration = DateTime.now().difference(startTime);
      _pod.logVerbose(
        'Webhook processed: topic=$topicId, status=${result.status}, '
        'duration=${duration.inMilliseconds}ms',
      );

      // Send success response
      response.statusCode = HttpStatus.ok;
      response.headers.set('Content-Type', 'application/json');
      response.write(jsonEncode({
        'status': 'queued',
        'deliveryStatus': result.status.name,
        'timestamp': DateTime.now().toIso8601String(),
      }));
      await response.close();
    } catch (e, st) {
      _pod.logVerbose('Webhook error: $e\n$st');
      await _sendError(response, HttpStatus.internalServerError, 'Internal error');
    }
  }

  /// Validate API key and return topic info
  Future<Map<String, dynamic>?> _validateApiKey(
    String apiKey,
    String topicId,
  ) async {
    // TODO: Implement actual API key validation
    // This should:
    // 1. Look up the API key in the database
    // 2. Verify it belongs to the specified topic
    // 3. Check the topic is enabled
    // 4. Return topic info including userId

    // Placeholder implementation
    // In production:
    // final session = await _pod.createSession();
    // try {
    //   final topic = await NotificationTopic.db.findFirstRow(
    //     session,
    //     where: (t) => t.apiKey.equals(apiKey) & t.id.equals(int.parse(topicId)),
    //   );
    //   if (topic == null || !topic.enabled) return null;
    //   return {
    //     'id': topic.id,
    //     'userId': topic.userId,
    //     'name': topic.name,
    //   };
    // } finally {
    //   await session.close();
    // }

    return null;
  }

  /// Parse notification payload, detecting format automatically
  Map<String, dynamic> _parsePayload(Map<String, dynamic> payload) {
    // Try Firebase format
    if (payload.containsKey('notification')) {
      final notification = payload['notification'] as Map<String, dynamic>;
      return {
        'title': notification['title'],
        'body': notification['body'],
        'data': payload['data'],
        'priority': payload['priority'],
      };
    }

    // Try Pushover format
    if (payload.containsKey('message') && !payload.containsKey('body')) {
      return {
        'title': payload['title'],
        'body': payload['message'],
        'data': payload['extras'],
        'priority': _pushoverPriorityToString(payload['priority']),
      };
    }

    // Try ntfy format
    if (payload.containsKey('topic') && payload.containsKey('message')) {
      return {
        'title': payload['title'],
        'body': payload['message'],
        'data': payload['extras'],
        'priority': _ntfyPriorityToString(payload['priority']),
      };
    }

    // Try Gotify format
    if (payload.containsKey('message') && payload.containsKey('extras')) {
      return {
        'title': payload['title'],
        'body': payload['message'],
        'data': payload['extras'],
        'priority': _gotifyPriorityToString(payload['priority']),
      };
    }

    // Generic format
    return {
      'title': payload['title'] ?? 'Notification',
      'body': payload['body'] ?? payload['message'] ?? payload['text'] ?? '',
      'data': payload['data'] ?? payload['extras'],
      'priority': payload['priority']?.toString() ?? 'normal',
    };
  }

  /// Convert Pushover priority (-2 to 2) to string
  String _pushoverPriorityToString(dynamic priority) {
    if (priority == null) return 'normal';
    final p = priority is int ? priority : int.tryParse(priority.toString()) ?? 0;
    if (p <= -2) return 'low';
    if (p <= -1) return 'low';
    if (p == 0) return 'normal';
    if (p == 1) return 'high';
    return 'urgent';
  }

  /// Convert ntfy priority (1-5) to string
  String _ntfyPriorityToString(dynamic priority) {
    if (priority == null) return 'normal';
    final p = priority is int ? priority : int.tryParse(priority.toString()) ?? 3;
    if (p <= 1) return 'low';
    if (p <= 2) return 'low';
    if (p == 3) return 'normal';
    if (p == 4) return 'high';
    return 'urgent';
  }

  /// Convert Gotify priority (1-10) to string
  String _gotifyPriorityToString(dynamic priority) {
    if (priority == null) return 'normal';
    final p = priority is int ? priority : int.tryParse(priority.toString()) ?? 5;
    if (p <= 3) return 'low';
    if (p <= 6) return 'normal';
    if (p <= 8) return 'high';
    return 'urgent';
  }

  /// Send error response
  Future<void> _sendError(HttpResponse response, int statusCode, String message) async {
    response.statusCode = statusCode;
    response.headers.set('Content-Type', 'application/json');
    response.write(jsonEncode({
      'error': message,
      'timestamp': DateTime.now().toIso8601String(),
    }));
    await response.close();
  }
}

/// Serverpod endpoint for webhook management
///
/// This provides authenticated methods for managing webhooks.
class WebhookEndpoint extends Endpoint {
  /// Get webhook URL for a topic
  Future<String> getWebhookUrl(Session session, int topicId) async {
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw StateError('User not authenticated');
    }
    final userId = authInfo.userId;

    // TODO: Verify topic belongs to user
    // final topic = await NotificationTopic.db.findById(session, topicId);
    // if (topic == null || topic.userId != userId) {
    //   throw StateError('Topic not found');
    // }

    // Return webhook URL
    // In production, use actual server URL from config
    return '/api/notify/$topicId';
  }

  /// Test webhook endpoint
  Future<Map<String, dynamic>> testWebhook(
    Session session,
    int topicId, {
    String title = 'Test Notification',
    String body = 'This is a test webhook notification.',
  }) async {
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw StateError('User not authenticated');
    }
    final userId = authInfo.userId;

    // TODO: Verify topic and create test notification
    return {
      'status': 'sent',
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
