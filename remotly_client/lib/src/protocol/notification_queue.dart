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
    this.topicId,
    required this.title,
    required this.body,
    this.data,
    required this.status,
    required this.attempts,
    required this.priority,
    required this.createdAt,
    required this.expiresAt,
  });

  factory NotificationQueue({
    int? id,
    required int userId,
    int? topicId,
    required String title,
    required String body,
    String? data,
    required String status,
    required int attempts,
    required String priority,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) = _NotificationQueueImpl;

  factory NotificationQueue.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotificationQueue(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      topicId: jsonSerialization['topicId'] as int?,
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      data: jsonSerialization['data'] as String?,
      status: jsonSerialization['status'] as String,
      attempts: jsonSerialization['attempts'] as int,
      priority: jsonSerialization['priority'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Foreign key to the user receiving the notification
  int userId;

  /// Optional foreign key to the notification topic (if from webhook)
  int? topicId;

  /// Notification title
  String title;

  /// Notification body text
  String body;

  /// Optional JSON payload for additional data
  String? data;

  /// Notification status: 'pending', 'sent', 'delivered', 'failed'
  String status;

  /// Number of delivery attempts
  int attempts;

  /// Notification priority: 'low', 'normal', 'high'
  String priority;

  /// Timestamp when the notification was created
  DateTime createdAt;

  /// Timestamp when the notification expires
  DateTime expiresAt;

  /// Returns a shallow copy of this [NotificationQueue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NotificationQueue copyWith({
    int? id,
    int? userId,
    int? topicId,
    String? title,
    String? body,
    String? data,
    String? status,
    int? attempts,
    String? priority,
    DateTime? createdAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      if (topicId != null) 'topicId': topicId,
      'title': title,
      'body': body,
      if (data != null) 'data': data,
      'status': status,
      'attempts': attempts,
      'priority': priority,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
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
    int? topicId,
    required String title,
    required String body,
    String? data,
    required String status,
    required int attempts,
    required String priority,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) : super._(
          id: id,
          userId: userId,
          topicId: topicId,
          title: title,
          body: body,
          data: data,
          status: status,
          attempts: attempts,
          priority: priority,
          createdAt: createdAt,
          expiresAt: expiresAt,
        );

  /// Returns a shallow copy of this [NotificationQueue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NotificationQueue copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? topicId = _Undefined,
    String? title,
    String? body,
    Object? data = _Undefined,
    String? status,
    int? attempts,
    String? priority,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return NotificationQueue(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      topicId: topicId is int? ? topicId : this.topicId,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data is String? ? data : this.data,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
