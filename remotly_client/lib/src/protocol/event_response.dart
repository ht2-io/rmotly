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

abstract class EventResponse implements _i1.SerializableModel {
  EventResponse._({
    required this.success,
    this.eventId,
    this.error,
  });

  factory EventResponse({
    required bool success,
    int? eventId,
    String? error,
  }) = _EventResponseImpl;

  factory EventResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return EventResponse(
      success: jsonSerialization['success'] as bool,
      eventId: jsonSerialization['eventId'] as int?,
      error: jsonSerialization['error'] as String?,
    );
  }

  /// Whether the event was successfully created
  bool success;

  /// ID of the created event (if successful)
  int? eventId;

  /// Error message (if unsuccessful)
  String? error;

  /// Returns a shallow copy of this [EventResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventResponse copyWith({
    bool? success,
    int? eventId,
    String? error,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (eventId != null) 'eventId': eventId,
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EventResponseImpl extends EventResponse {
  _EventResponseImpl({
    required bool success,
    int? eventId,
    String? error,
  }) : super._(
          success: success,
          eventId: eventId,
          error: error,
        );

  /// Returns a shallow copy of this [EventResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventResponse copyWith({
    bool? success,
    Object? eventId = _Undefined,
    Object? error = _Undefined,
  }) {
    return EventResponse(
      success: success ?? this.success,
      eventId: eventId is int? ? eventId : this.eventId,
      error: error is String? ? error : this.error,
    );
  }
}
