/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class NotificationQueue implements _i1.SerializableModel {
  NotificationQueue._({
    this.id,
    required this.userId,
    this.subscriptionId,
    required this.title,
    required this.body,
    this.payload,
    required this.priority,
    required this.status,
    this.deliveryTier,
    required this.attemptCount,
    required this.maxAttempts,
    this.lastError,
    required this.createdAt,
    required this.scheduledAt,
    required this.expiresAt,
    this.deliveredAt,
  });

  factory NotificationQueue({
    int? id,
    required int userId,
    int? subscriptionId,
    required String title,
    required String body,
    String? payload,
    required String priority,
    required String status,
    String? deliveryTier,
    required int attemptCount,
    required int maxAttempts,
    String? lastError,
    required DateTime createdAt,
    required DateTime scheduledAt,
    required DateTime expiresAt,
    DateTime? deliveredAt,
  }) = _NotificationQueueImpl;

  factory NotificationQueue.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotificationQueue(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      subscriptionId: jsonSerialization['subscriptionId'] as int?,
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      payload: jsonSerialization['payload'] as String?,
      priority: jsonSerialization['priority'] as String,
      status: jsonSerialization['status'] as String,
      deliveryTier: jsonSerialization['deliveryTier'] as String?,
      attemptCount: jsonSerialization['attemptCount'] as int,
      maxAttempts: jsonSerialization['maxAttempts'] as int,
      lastError: jsonSerialization['lastError'] as String?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      scheduledAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['scheduledAt']),
      expiresAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      deliveredAt: jsonSerialization['deliveredAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['deliveredAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Foreign key to the user who will receive the notification
  int userId;

  /// Foreign key to the push subscription (optional, null for broadcast)
  int? subscriptionId;

  /// Notification title
  String title;

  /// Notification body/message
  String body;

  /// Notification payload as JSON string (additional data)
  String? payload;

  /// Priority level (low, normal, high, urgent)
  String priority;

  /// Current delivery status (pending, sending, delivered, failed, expired)
  String status;

  /// Delivery tier attempted (websocket, webpush, sse)
  String? deliveryTier;

  /// Number of delivery attempts
  int attemptCount;

  /// Maximum number of delivery attempts before marking as failed
  int maxAttempts;

  /// Last error message if delivery failed
  String? lastError;

  /// Timestamp when the notification was queued
  DateTime createdAt;

  /// Timestamp when delivery should be attempted next
  DateTime scheduledAt;

  /// Timestamp when the notification expires (no more retries)
  DateTime expiresAt;

  /// Timestamp when the notification was delivered (null if not yet delivered)
  DateTime? deliveredAt;

  /// Returns a shallow copy of this [NotificationQueue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NotificationQueue copyWith({
    int? id,
    int? userId,
    int? subscriptionId,
    String? title,
    String? body,
    String? payload,
    String? priority,
    String? status,
    String? deliveryTier,
    int? attemptCount,
    int? maxAttempts,
    String? lastError,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    DateTime? deliveredAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      if (subscriptionId != null) 'subscriptionId': subscriptionId,
      'title': title,
      'body': body,
      if (payload != null) 'payload': payload,
      'priority': priority,
      'status': status,
      if (deliveryTier != null) 'deliveryTier': deliveryTier,
      'attemptCount': attemptCount,
      'maxAttempts': maxAttempts,
      if (lastError != null) 'lastError': lastError,
      'createdAt': createdAt.toJson(),
      'scheduledAt': scheduledAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (deliveredAt != null) 'deliveredAt': deliveredAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationQueueImpl extends NotificationQueue {
  _NotificationQueueImpl({
    int? id,
    required int userId,
    int? subscriptionId,
    required String title,
    required String body,
    String? payload,
    required String priority,
    required String status,
    String? deliveryTier,
    required int attemptCount,
    required int maxAttempts,
    String? lastError,
    required DateTime createdAt,
    required DateTime scheduledAt,
    required DateTime expiresAt,
    DateTime? deliveredAt,
  }) : super._(
          id: id,
          userId: userId,
          subscriptionId: subscriptionId,
          title: title,
          body: body,
          payload: payload,
          priority: priority,
          status: status,
          deliveryTier: deliveryTier,
          attemptCount: attemptCount,
          maxAttempts: maxAttempts,
          lastError: lastError,
          createdAt: createdAt,
          scheduledAt: scheduledAt,
          expiresAt: expiresAt,
          deliveredAt: deliveredAt,
        );

  /// Returns a shallow copy of this [NotificationQueue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NotificationQueue copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? subscriptionId = _Undefined,
    String? title,
    String? body,
    Object? payload = _Undefined,
    String? priority,
    String? status,
    Object? deliveryTier = _Undefined,
    int? attemptCount,
    int? maxAttempts,
    Object? lastError = _Undefined,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    Object? deliveredAt = _Undefined,
  }) {
    return NotificationQueue(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      subscriptionId:
          subscriptionId is int? ? subscriptionId : this.subscriptionId,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload is String? ? payload : this.payload,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      deliveryTier: deliveryTier is String? ? deliveryTier : this.deliveryTier,
      attemptCount: attemptCount ?? this.attemptCount,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      lastError: lastError is String? ? lastError : this.lastError,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      expiresAt: expiresAt ?? this.expiresAt,
      deliveredAt: deliveredAt is DateTime? ? deliveredAt : this.deliveredAt,
    );
  }
}
