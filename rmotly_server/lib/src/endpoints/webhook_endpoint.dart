import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../services/notification_service.dart';
import '../services/payload_parser_service.dart';
import '../services/rate_limit_service.dart';

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
  final RateLimitService _rateLimiter;
  final PayloadParserService _payloadParser;

  WebhookHandler(this._pod)
      : _notificationService = NotificationService(),
        _rateLimiter = RateLimitService(RateLimitConfig.webhook),
        _payloadParser = PayloadParserService();

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

      // Parse the notification payload using PayloadParserService
      final parsedPayload = _payloadParser.parse(payload);

      // Create notification data
      final notificationData = NotificationData(
        userId: topic['userId'] as int,
        topicId: topic['id'] as int,
        title: parsedPayload.title,
        body: parsedPayload.body,
        data: parsedPayload.data,
        priority: parsedPayload.priority,
      );

      // Deliver the notification
      final result = await _notificationService.deliver(
        await _pod.createSession(),
        notificationData,
      );

      // Log the request
      final duration = DateTime.now().difference(startTime);
      _pod.logVerbose(
        'Webhook processed: topic=$topicId, format=${parsedPayload.sourceFormat.name}, '
        'status=${result.status}, duration=${duration.inMilliseconds}ms',
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
    final userId = authInfo?.userId;
    if (userId == null) {
      throw StateError('User not authenticated');
    }

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
    final userId = authInfo?.userId;
    if (userId == null) {
      throw StateError('User not authenticated');
    }

    // TODO: Verify topic and create test notification
    return {
      'status': 'sent',
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
