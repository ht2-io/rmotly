import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import 'notification_stream_service.dart';
import 'push_service.dart';

/// Delivery status for a notification
enum DeliveryStatus {
  /// Notification is waiting to be sent
  pending,

  /// Notification was delivered via WebSocket
  deliveredWebSocket,

  /// Notification was delivered via WebPush
  deliveredWebPush,

  /// Notification was queued for SSE pickup
  queuedSse,

  /// Delivery failed
  failed,
}

/// Result of a notification delivery attempt
class NotificationDeliveryResult {
  final DeliveryStatus status;
  final String? error;
  final int? webSocketDeliveries;
  final int? pushDeliveries;

  NotificationDeliveryResult({
    required this.status,
    this.error,
    this.webSocketDeliveries,
    this.pushDeliveries,
  });

  bool get isDelivered =>
      status == DeliveryStatus.deliveredWebSocket ||
      status == DeliveryStatus.deliveredWebPush ||
      status == DeliveryStatus.queuedSse;
}

/// Notification data for delivery
class NotificationData {
  final int userId;
  final int? topicId;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String priority;
  final DateTime? expiresAt;

  NotificationData({
    required this.userId,
    this.topicId,
    required this.title,
    required this.body,
    this.data,
    this.priority = 'normal',
    this.expiresAt,
  });
}

/// Service for orchestrating notification delivery through three tiers.
///
/// Implements three-tier delivery strategy:
/// 1. **Tier 1 (WebSocket)**: Real-time delivery to connected clients
/// 2. **Tier 2 (WebPush)**: Push to UnifiedPush endpoints for background apps
/// 3. **Tier 3 (SSE)**: Queue for SSE pickup on restricted networks
///
/// This ensures reliable delivery regardless of app state or network conditions.
class NotificationService {
  final NotificationStreamService _streamService;
  final PushService _pushService;

  /// Queue for SSE fallback (notifications waiting for pickup)
  /// In production, this would be backed by Redis or database
  final Map<int, List<_QueuedNotification>> _sseQueue = {};

  /// Maximum age for SSE queued notifications
  static const sseQueueMaxAge = Duration(hours: 24);

  NotificationService({
    NotificationStreamService? streamService,
    PushService? pushService,
  })  : _streamService = streamService ?? notificationStreamService,
        _pushService = pushService ?? PushService();

  /// Deliver a notification using three-tier strategy
  ///
  /// 1. Try WebSocket first (for foreground apps)
  /// 2. If WebSocket fails, try WebPush (for background apps)
  /// 3. If WebPush fails, queue for SSE (fallback)
  Future<NotificationDeliveryResult> deliver(
    Session session,
    NotificationData notification, {
    List<PushSubscriptionData>? pushSubscriptions,
  }) async {
    final userId = notification.userId;

    // Tier 1: Try WebSocket delivery
    final wsResult = await _deliverViaWebSocket(session, notification);
    if (wsResult.webSocketDeliveries != null && wsResult.webSocketDeliveries! > 0) {
      session.log(
        'Notification delivered via WebSocket to $userId '
        '(${wsResult.webSocketDeliveries} streams)',
        level: LogLevel.debug,
      );
      return wsResult;
    }

    // Tier 2: Try WebPush delivery
    if (pushSubscriptions != null && pushSubscriptions.isNotEmpty) {
      final pushResult = await _deliverViaWebPush(
        session,
        notification,
        pushSubscriptions,
      );
      if (pushResult.pushDeliveries != null && pushResult.pushDeliveries! > 0) {
        session.log(
          'Notification delivered via WebPush to $userId '
          '(${pushResult.pushDeliveries} endpoints)',
          level: LogLevel.debug,
        );
        return pushResult;
      }
    }

    // Tier 3: Queue for SSE fallback
    final sseResult = await _queueForSse(session, notification);
    session.log(
      'Notification queued for SSE pickup for $userId',
      level: LogLevel.debug,
    );
    return sseResult;
  }

  /// Deliver via WebSocket (Tier 1)
  Future<NotificationDeliveryResult> _deliverViaWebSocket(
    Session session,
    NotificationData notification,
  ) async {
    // Check if user has active WebSocket connections
    if (!_streamService.isUserConnected(notification.userId)) {
      return NotificationDeliveryResult(
        status: DeliveryStatus.pending,
        webSocketDeliveries: 0,
      );
    }

    // Create stream notification
    final streamNotification = StreamNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title,
      body: notification.body,
      data: notification.data != null ? jsonEncode(notification.data) : null,
      priority: notification.priority,
      timestamp: DateTime.now(),
    );

    // Send to all user's connections
    final delivered = _streamService.sendToUser(
      notification.userId,
      streamNotification,
    );

    if (delivered > 0) {
      return NotificationDeliveryResult(
        status: DeliveryStatus.deliveredWebSocket,
        webSocketDeliveries: delivered,
      );
    }

    return NotificationDeliveryResult(
      status: DeliveryStatus.pending,
      webSocketDeliveries: 0,
    );
  }

  /// Deliver via WebPush (Tier 2)
  Future<NotificationDeliveryResult> _deliverViaWebPush(
    Session session,
    NotificationData notification,
    List<PushSubscriptionData> subscriptions,
  ) async {
    var delivered = 0;
    final errors = <String>[];

    // Build payload
    final payload = {
      'title': notification.title,
      'body': notification.body,
      if (notification.data != null) 'data': notification.data,
      'priority': notification.priority,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Try each subscription
    for (final subscription in subscriptions) {
      final result = await _pushService.sendPushWithRetry(
        subscription,
        payload,
        urgency: _priorityToUrgency(notification.priority),
        session: session,
      );

      if (result.success) {
        delivered++;
      } else {
        if (result.error != null) {
          errors.add(result.error!);
        }

        // Handle endpoint removal if needed
        if (result.shouldRemoveEndpoint) {
          // TODO: Remove subscription from database
          session.log(
            'Removing invalid push subscription: ${subscription.endpoint}',
            level: LogLevel.warning,
          );
        }
      }
    }

    if (delivered > 0) {
      return NotificationDeliveryResult(
        status: DeliveryStatus.deliveredWebPush,
        pushDeliveries: delivered,
      );
    }

    return NotificationDeliveryResult(
      status: DeliveryStatus.pending,
      error: errors.isNotEmpty ? errors.join('; ') : null,
      pushDeliveries: 0,
    );
  }

  /// Queue for SSE pickup (Tier 3)
  Future<NotificationDeliveryResult> _queueForSse(
    Session session,
    NotificationData notification,
  ) async {
    final userId = notification.userId;

    // Clean old entries first
    _cleanSseQueue(userId);

    // Add to queue
    _sseQueue.putIfAbsent(userId, () => []);
    _sseQueue[userId]!.add(_QueuedNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      notification: notification,
      queuedAt: DateTime.now(),
      expiresAt: notification.expiresAt ??
          DateTime.now().add(sseQueueMaxAge),
    ));

    // TODO: In production, persist to Redis or database
    // await _persistSseQueue(userId, _sseQueue[userId]!);

    return NotificationDeliveryResult(
      status: DeliveryStatus.queuedSse,
    );
  }

  /// Get queued notifications for SSE delivery
  ///
  /// Returns notifications for the user and optionally removes them from queue.
  List<NotificationData> getSseQueue(int userId, {bool remove = true}) {
    _cleanSseQueue(userId);

    final queued = _sseQueue[userId];
    if (queued == null || queued.isEmpty) {
      return [];
    }

    final notifications = queued.map((q) => q.notification).toList();

    if (remove) {
      _sseQueue.remove(userId);
    }

    return notifications;
  }

  /// Clean expired entries from SSE queue
  void _cleanSseQueue(int userId) {
    final queued = _sseQueue[userId];
    if (queued == null) return;

    final now = DateTime.now();
    queued.removeWhere((q) => q.expiresAt.isBefore(now));

    if (queued.isEmpty) {
      _sseQueue.remove(userId);
    }
  }

  /// Convert priority string to WebPush urgency
  String _priorityToUrgency(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'low';
      case 'high':
      case 'urgent':
        return 'high';
      default:
        return 'normal';
    }
  }

  /// Send notification to a topic (all subscribed users)
  Future<Map<int, NotificationDeliveryResult>> deliverToTopic(
    Session session, {
    required int topicId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String priority = 'normal',
  }) async {
    // TODO: Query users subscribed to this topic
    // final subscribers = await NotificationTopicSubscription.db.find(
    //   session,
    //   where: (t) => t.topicId.equals(topicId) & t.enabled.equals(true),
    // );

    // For now, return empty results
    // In production, this would iterate over subscribers and call deliver()
    return {};
  }

  /// Clean up resources
  void dispose() {
    _pushService.close();
  }
}

/// Internal class for queued SSE notifications
class _QueuedNotification {
  final String id;
  final NotificationData notification;
  final DateTime queuedAt;
  final DateTime expiresAt;

  _QueuedNotification({
    required this.id,
    required this.notification,
    required this.queuedAt,
    required this.expiresAt,
  });
}
