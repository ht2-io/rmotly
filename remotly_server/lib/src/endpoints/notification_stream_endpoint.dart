import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../services/notification_stream_service.dart';

/// Endpoint for real-time notification streaming via WebSocket.
///
/// This endpoint uses Serverpod's built-in streaming support to deliver
/// notifications to connected clients in real-time (Tier 1 delivery).
///
/// Usage:
/// ```dart
/// // In Flutter client
/// final stream = client.notificationStream.streamNotifications();
/// await for (final notification in stream) {
///   print('Received: ${notification.title}');
/// }
/// ```
class NotificationStreamEndpoint extends Endpoint {
  /// Stream notifications to the connected client.
  ///
  /// This method establishes a WebSocket connection and streams
  /// notifications to the authenticated user in real-time.
  ///
  /// The stream remains open until the client disconnects or
  /// the server closes the connection.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  Stream<StreamNotification> streamNotifications(Session session) async* {
    // Get authenticated user
    final userId = await session.auth.authenticatedUserId;
    if (userId == null) {
      session.log(
        'Unauthenticated stream request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    session.log(
      'Starting notification stream for user $userId',
      level: LogLevel.info,
    );

    // Create a stream from the notification service
    final stream = notificationStreamService.createStream(session, userId);

    // Yield notifications as they arrive
    try {
      await for (final notification in stream) {
        yield notification;
      }
    } catch (e) {
      session.log(
        'Stream error for user $userId: $e',
        level: LogLevel.error,
      );
      rethrow;
    } finally {
      session.log(
        'Notification stream closed for user $userId',
        level: LogLevel.info,
      );
    }
  }

  /// Get the current connection status for the authenticated user.
  ///
  /// Returns the number of active WebSocket connections for this user.
  Future<int> getConnectionCount(Session session) async {
    final userId = await session.auth.authenticatedUserId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    return notificationStreamService.getConnectionCount(userId);
  }

  /// Send a test notification to the authenticated user.
  ///
  /// This is useful for testing the notification stream.
  /// Returns the number of connections that received the notification.
  Future<int> sendTestNotification(
    Session session, {
    String title = 'Test Notification',
    String body = 'This is a test notification from Remotly.',
  }) async {
    final userId = await session.auth.authenticatedUserId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    final notification = StreamNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      data: {'test': true},
      priority: 'normal',
    );

    final delivered = notificationStreamService.sendToUser(userId, notification);

    session.log(
      'Test notification sent to user $userId: $delivered connections',
      level: LogLevel.info,
    );

    return delivered;
  }
}

/// Exception thrown when authentication fails
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}
