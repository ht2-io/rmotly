import 'dart:async';

import 'package:serverpod/serverpod.dart';

/// A notification to be streamed to clients
class StreamNotification {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;
  final String priority;
  final DateTime timestamp;

  StreamNotification({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    this.imageUrl,
    this.actionUrl,
    this.priority = 'normal',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        if (data != null) 'data': data,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (actionUrl != null) 'actionUrl': actionUrl,
        'priority': priority,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Connection info for a user's stream
class _UserConnection {
  final int userId;
  final StreamController<StreamNotification> controller;
  final DateTime connectedAt;
  String? sessionId;

  _UserConnection({
    required this.userId,
    required this.controller,
    this.sessionId,
  }) : connectedAt = DateTime.now();

  bool get isActive => !controller.isClosed;
}

/// Service for managing real-time notification streaming via WebSocket.
///
/// Uses Serverpod's built-in streaming support to deliver notifications
/// to connected clients in real-time (Tier 1 delivery method).
///
/// Features:
/// - Multiple connections per user
/// - Connection lifecycle management
/// - Broadcast to all user connections
/// - Automatic cleanup of stale connections
class NotificationStreamService {
  /// Map of userId -> list of active connections
  final Map<int, List<_UserConnection>> _connections = {};

  /// Lock for thread-safe connection management
  final _lock = Object();

  /// Total active connections
  int get totalConnections =>
      _connections.values.fold(0, (sum, list) => sum + list.length);

  /// Get active connection count for a user
  int getConnectionCount(int userId) {
    return _connections[userId]?.where((c) => c.isActive).length ?? 0;
  }

  /// Create a new stream for a user
  ///
  /// Returns a Stream that the endpoint can yield notifications from.
  /// The stream will receive all notifications sent to this user.
  Stream<StreamNotification> createStream(
    Session session,
    int userId,
  ) {
    final controller = StreamController<StreamNotification>();
    final connection = _UserConnection(
      userId: userId,
      controller: controller,
      sessionId: session.sessionId.toString(),
    );

    // Add to connections map
    _connections.putIfAbsent(userId, () => []);
    _connections[userId]!.add(connection);

    session.log(
      'Stream created for user $userId (total: ${getConnectionCount(userId)})',
      level: LogLevel.debug,
    );

    // Clean up when the stream is cancelled
    controller.onCancel = () {
      _removeConnection(userId, connection);
      session.log(
        'Stream closed for user $userId (remaining: ${getConnectionCount(userId)})',
        level: LogLevel.debug,
      );
    };

    return controller.stream;
  }

  /// Send a notification to a specific user's streams
  ///
  /// Returns the number of streams that received the notification.
  int sendToUser(int userId, StreamNotification notification) {
    final userConnections = _connections[userId];
    if (userConnections == null || userConnections.isEmpty) {
      return 0;
    }

    var delivered = 0;
    final toRemove = <_UserConnection>[];

    for (final connection in userConnections) {
      if (connection.isActive) {
        try {
          connection.controller.add(notification);
          delivered++;
        } catch (e) {
          // Controller is closed, mark for removal
          toRemove.add(connection);
        }
      } else {
        toRemove.add(connection);
      }
    }

    // Clean up dead connections
    for (final connection in toRemove) {
      _removeConnection(userId, connection);
    }

    return delivered;
  }

  /// Send a notification to multiple users
  ///
  /// Returns a map of userId -> delivery count.
  Map<int, int> sendToUsers(
    List<int> userIds,
    StreamNotification notification,
  ) {
    final results = <int, int>{};
    for (final userId in userIds) {
      results[userId] = sendToUser(userId, notification);
    }
    return results;
  }

  /// Broadcast a notification to all connected users
  ///
  /// Returns total number of streams that received the notification.
  int broadcast(StreamNotification notification) {
    var delivered = 0;
    for (final userId in _connections.keys.toList()) {
      delivered += sendToUser(userId, notification);
    }
    return delivered;
  }

  /// Check if a user has any active connections
  bool isUserConnected(int userId) {
    final connections = _connections[userId];
    if (connections == null) return false;
    return connections.any((c) => c.isActive);
  }

  /// Get list of all connected user IDs
  List<int> getConnectedUserIds() {
    return _connections.entries
        .where((e) => e.value.any((c) => c.isActive))
        .map((e) => e.key)
        .toList();
  }

  /// Remove a specific connection
  void _removeConnection(int userId, _UserConnection connection) {
    final connections = _connections[userId];
    if (connections == null) return;

    connections.remove(connection);
    if (!connection.controller.isClosed) {
      connection.controller.close();
    }

    // Clean up empty user entries
    if (connections.isEmpty) {
      _connections.remove(userId);
    }
  }

  /// Close all connections for a user
  void closeUserConnections(int userId) {
    final connections = _connections[userId];
    if (connections == null) return;

    for (final connection in connections) {
      if (!connection.controller.isClosed) {
        connection.controller.close();
      }
    }
    _connections.remove(userId);
  }

  /// Clean up stale connections (connections that are no longer active)
  int cleanupStaleConnections() {
    var cleaned = 0;

    for (final userId in _connections.keys.toList()) {
      final connections = _connections[userId]!;
      final stale = connections.where((c) => !c.isActive).toList();

      for (final connection in stale) {
        _removeConnection(userId, connection);
        cleaned++;
      }
    }

    return cleaned;
  }

  /// Close all connections and clean up
  void dispose() {
    for (final connections in _connections.values) {
      for (final connection in connections) {
        if (!connection.controller.isClosed) {
          connection.controller.close();
        }
      }
    }
    _connections.clear();
  }
}

/// Singleton instance of the notification stream service
///
/// This is a global instance because streams need to persist
/// across multiple endpoint calls.
final notificationStreamService = NotificationStreamService();
