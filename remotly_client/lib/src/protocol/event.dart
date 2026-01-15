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

abstract class Event implements _i1.SerializableModel {
  Event._({
    this.id,
    required this.userId,
    required this.sourceType,
    required this.sourceId,
    required this.eventType,
    this.payload,
    this.actionResult,
    required this.timestamp,
  });

  factory Event({
    int? id,
    required int userId,
    required String sourceType,
    required String sourceId,
    required String eventType,
    String? payload,
    String? actionResult,
    required DateTime timestamp,
  }) = _EventImpl;

  factory Event.fromJson(Map<String, dynamic> jsonSerialization) {
    return Event(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      sourceType: jsonSerialization['sourceType'] as String,
      sourceId: jsonSerialization['sourceId'] as String,
      eventType: jsonSerialization['eventType'] as String,
      payload: jsonSerialization['payload'] as String?,
      actionResult: jsonSerialization['actionResult'] as String?,
      timestamp:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Foreign key to the user who owns this event
  int userId;

  /// Source type (control, webhook, system)
  String sourceType;

  /// Source identifier (control ID, topic ID, etc.)
  String sourceId;

  /// Type of event (button_press, toggle_change, webhook_received, etc.)
  String eventType;

  /// Optional event payload as JSON string
  String? payload;

  /// Optional action execution result as JSON string
  String? actionResult;

  /// Timestamp when the event occurred
  DateTime timestamp;

  /// Returns a shallow copy of this [Event]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Event copyWith({
    int? id,
    int? userId,
    String? sourceType,
    String? sourceId,
    String? eventType,
    String? payload,
    String? actionResult,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'sourceType': sourceType,
      'sourceId': sourceId,
      'eventType': eventType,
      if (payload != null) 'payload': payload,
      if (actionResult != null) 'actionResult': actionResult,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EventImpl extends Event {
  _EventImpl({
    int? id,
    required int userId,
    required String sourceType,
    required String sourceId,
    required String eventType,
    String? payload,
    String? actionResult,
    required DateTime timestamp,
  }) : super._(
          id: id,
          userId: userId,
          sourceType: sourceType,
          sourceId: sourceId,
          eventType: eventType,
          payload: payload,
          actionResult: actionResult,
          timestamp: timestamp,
        );

  /// Returns a shallow copy of this [Event]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Event copyWith({
    Object? id = _Undefined,
    int? userId,
    String? sourceType,
    String? sourceId,
    String? eventType,
    Object? payload = _Undefined,
    Object? actionResult = _Undefined,
    DateTime? timestamp,
  }) {
    return Event(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      eventType: eventType ?? this.eventType,
      payload: payload is String? ? payload : this.payload,
      actionResult: actionResult is String? ? actionResult : this.actionResult,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
