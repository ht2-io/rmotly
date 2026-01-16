import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';

import '../services/notification_service.dart';
import '../services/notification_stream_service.dart';

/// Server-Sent Events (SSE) endpoint for notification delivery.
///
/// This provides a fallback delivery mechanism for restricted networks
/// where WebSocket connections are blocked.
///
/// SSE uses HTTP long-polling with `text/event-stream` content type,
/// which is more likely to pass through corporate firewalls and proxies.
///
/// Route: GET /api/sse/notifications
///
/// Note: This requires custom route registration in the Serverpod server.
/// Add to server setup:
/// ```dart
/// server.webServer.addRoute(
///   RouteDefinition(
///     '/api/sse/notifications',
///     SseHandler(server),
///   ),
/// );
/// ```
class SseHandler {
  final Serverpod _pod;
  final NotificationService _notificationService;

  /// Event ID counter for resumption support
  int _eventIdCounter = 0;

  SseHandler(this._pod) : _notificationService = NotificationService();

  /// Handle incoming SSE connection request
  Future<void> handleRequest(HttpRequest request) async {
    final response = request.response;

    // Only accept GET requests
    if (request.method != 'GET') {
      response.statusCode = HttpStatus.methodNotAllowed;
      response.write('Method not allowed');
      await response.close();
      return;
    }

    // Authenticate the request
    final userId = await _authenticateRequest(request);
    if (userId == null) {
      response.statusCode = HttpStatus.unauthorized;
      response.write('Unauthorized');
      await response.close();
      return;
    }

    // Set SSE headers
    response.headers.set('Content-Type', 'text/event-stream');
    response.headers.set('Cache-Control', 'no-cache');
    response.headers.set('Connection', 'keep-alive');
    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set('X-Accel-Buffering', 'no'); // Disable nginx buffering

    // Check for Last-Event-ID header for resumption
    final lastEventId = request.headers.value('Last-Event-ID');
    int? resumeFromId;
    if (lastEventId != null) {
      resumeFromId = int.tryParse(lastEventId);
    }

    // Send initial connection event
    _sendEvent(response, 'connected', {'userId': userId, 'timestamp': DateTime.now().toIso8601String()});

    // Send any queued notifications (SSE fallback queue)
    final queued = _notificationService.getSseQueue(userId);
    for (final notification in queued) {
      _sendNotificationEvent(response, notification);
    }

    // Create a stream subscription for real-time notifications
    final stream = notificationStreamService.createStream(
      await _createSession(userId),
      userId,
    );

    // Keep connection alive with periodic heartbeats
    final heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sendHeartbeat(response),
    );

    try {
      // Stream notifications to client
      await for (final notification in stream) {
        _sendNotificationEvent(response, NotificationData(
          userId: userId,
          title: notification.title,
          body: notification.body,
          data: notification.data,
          priority: notification.priority,
        ));
      }
    } catch (e) {
      // Connection closed or error
      _pod.logVerbose('SSE connection closed for user $userId: $e');
    } finally {
      heartbeatTimer.cancel();
      await response.close();
    }
  }

  /// Authenticate request from query params or headers
  Future<int?> _authenticateRequest(HttpRequest request) async {
    // Try Authorization header first
    final authHeader = request.headers.value('Authorization');
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      final token = authHeader.substring(7);
      return await _validateToken(token);
    }

    // Try query parameter
    final token = request.uri.queryParameters['token'];
    if (token != null) {
      return await _validateToken(token);
    }

    return null;
  }

  /// Validate authentication token and return user ID
  Future<int?> _validateToken(String token) async {
    // TODO: Implement actual token validation
    // This should validate the session token from Serverpod auth
    // For now, return null (unauthenticated)

    // In production:
    // final session = await _pod.createSession();
    // try {
    //   final authInfo = await session.auth.getAuthenticatedUserInfo(token);
    //   return authInfo?.userId;
    // } finally {
    //   await session.close();
    // }

    return null;
  }

  /// Create a session for the user
  Future<Session> _createSession(int userId) async {
    // Create a new session for streaming
    // Note: In production, this would use proper session management
    return await _pod.createSession();
  }

  /// Send an SSE event
  void _sendEvent(HttpResponse response, String event, Map<String, dynamic> data) {
    final id = ++_eventIdCounter;
    response.write('id: $id\n');
    response.write('event: $event\n');
    response.write('data: ${jsonEncode(data)}\n\n');
  }

  /// Send a notification event
  void _sendNotificationEvent(HttpResponse response, NotificationData notification) {
    final id = ++_eventIdCounter;
    response.write('id: $id\n');
    response.write('event: notification\n');
    response.write('data: ${jsonEncode({
      'title': notification.title,
      'body': notification.body,
      'data': notification.data,
      'priority': notification.priority,
      'timestamp': DateTime.now().toIso8601String(),
    })}\n\n');
  }

  /// Send a heartbeat to keep connection alive
  void _sendHeartbeat(HttpResponse response) {
    response.write(':heartbeat\n\n');
  }
}

/// SSE endpoint wrapper for Serverpod endpoint pattern
///
/// This provides a Serverpod endpoint interface for SSE functionality.
/// Note: Actual SSE streaming requires the custom SseHandler above.
class SseEndpoint extends Endpoint {
  /// Get SSE connection info for the authenticated user.
  ///
  /// Returns the SSE endpoint URL and authentication token.
  Future<Map<String, dynamic>> getConnectionInfo(Session session) async {
    final userId = await session.auth.authenticatedUserId;
    if (userId == null) {
      throw StateError('User not authenticated');
    }

    // Generate a temporary token for SSE connection
    // TODO: Implement proper token generation
    final token = 'temp_token_$userId';

    return {
      'endpoint': '/api/sse/notifications',
      'token': token,
      'heartbeatInterval': 30,
      'reconnectDelay': 5,
    };
  }

  /// Get queued notifications for SSE pickup.
  ///
  /// This is used when the client connects and wants to retrieve
  /// any notifications that were queued while disconnected.
  Future<List<Map<String, dynamic>>> getQueuedNotifications(Session session) async {
    final userId = await session.auth.authenticatedUserId;
    if (userId == null) {
      throw StateError('User not authenticated');
    }

    final notificationService = NotificationService();
    final queued = notificationService.getSseQueue(userId);

    return queued.map((n) => {
      'title': n.title,
      'body': n.body,
      'data': n.data,
      'priority': n.priority,
    }).toList();
  }
}
