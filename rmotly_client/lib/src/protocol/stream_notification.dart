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

abstract class StreamNotification implements _i1.SerializableModel {
  StreamNotification._({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    this.imageUrl,
    this.actionUrl,
    required this.priority,
    required this.timestamp,
  });

  factory StreamNotification({
    required String id,
    required String title,
    required String body,
    String? data,
    String? imageUrl,
    String? actionUrl,
    required String priority,
    required DateTime timestamp,
  }) = _StreamNotificationImpl;

  factory StreamNotification.fromJson(Map<String, dynamic> jsonSerialization) {
    return StreamNotification(
      id: jsonSerialization['id'] as String,
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      data: jsonSerialization['data'] as String?,
      imageUrl: jsonSerialization['imageUrl'] as String?,
      actionUrl: jsonSerialization['actionUrl'] as String?,
      priority: jsonSerialization['priority'] as String,
      timestamp:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
    );
  }

  /// Unique notification ID
  String id;

  /// Notification title
  String title;

  /// Notification body text
  String body;

  /// Additional notification data as JSON map
  String? data;

  /// Optional image URL
  String? imageUrl;

  /// Optional action URL for tap handling
  String? actionUrl;

  /// Notification priority (low, normal, high, urgent)
  String priority;

  /// Timestamp when notification was created
  DateTime timestamp;

  /// Returns a shallow copy of this [StreamNotification]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StreamNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? data,
    String? imageUrl,
    String? actionUrl,
    String? priority,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      if (data != null) 'data': data,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (actionUrl != null) 'actionUrl': actionUrl,
      'priority': priority,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StreamNotificationImpl extends StreamNotification {
  _StreamNotificationImpl({
    required String id,
    required String title,
    required String body,
    String? data,
    String? imageUrl,
    String? actionUrl,
    required String priority,
    required DateTime timestamp,
  }) : super._(
          id: id,
          title: title,
          body: body,
          data: data,
          imageUrl: imageUrl,
          actionUrl: actionUrl,
          priority: priority,
          timestamp: timestamp,
        );

  /// Returns a shallow copy of this [StreamNotification]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StreamNotification copyWith({
    String? id,
    String? title,
    String? body,
    Object? data = _Undefined,
    Object? imageUrl = _Undefined,
    Object? actionUrl = _Undefined,
    String? priority,
    DateTime? timestamp,
  }) {
    return StreamNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data is String? ? data : this.data,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      actionUrl: actionUrl is String? ? actionUrl : this.actionUrl,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
