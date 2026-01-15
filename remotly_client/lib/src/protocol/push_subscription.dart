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

abstract class PushSubscription implements _i1.SerializableModel {
  PushSubscription._({
    this.id,
    required this.userId,
    required this.endpoint,
    this.p256dh,
    this.authSecret,
    required this.deliveryMethod,
    required this.enabled,
    this.lastUsed,
    required this.failureCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PushSubscription({
    int? id,
    required int userId,
    required String endpoint,
    String? p256dh,
    String? authSecret,
    required String deliveryMethod,
    required bool enabled,
    DateTime? lastUsed,
    required int failureCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PushSubscriptionImpl;

  factory PushSubscription.fromJson(Map<String, dynamic> jsonSerialization) {
    return PushSubscription(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      endpoint: jsonSerialization['endpoint'] as String,
      p256dh: jsonSerialization['p256dh'] as String?,
      authSecret: jsonSerialization['authSecret'] as String?,
      deliveryMethod: jsonSerialization['deliveryMethod'] as String,
      enabled: jsonSerialization['enabled'] as bool,
      lastUsed: jsonSerialization['lastUsed'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsed']),
      failureCount: jsonSerialization['failureCount'] as int,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Foreign key to the user who owns this subscription
  int userId;

  /// UnifiedPush/WebPush endpoint URL
  String endpoint;

  /// WebPush encryption key (base64-encoded, optional for non-WebPush methods)
  String? p256dh;

  /// WebPush auth secret (base64-encoded, optional for non-WebPush methods)
  String? authSecret;

  /// Delivery method: 'webpush', 'sse', 'websocket'
  String deliveryMethod;

  /// Whether the subscription is enabled
  bool enabled;

  /// Timestamp when the subscription was last successfully used
  DateTime? lastUsed;

  /// Number of consecutive delivery failures
  int failureCount;

  /// Timestamp when the subscription was created
  DateTime createdAt;

  /// Timestamp when the subscription was last updated
  DateTime updatedAt;

  /// Returns a shallow copy of this [PushSubscription]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PushSubscription copyWith({
    int? id,
    int? userId,
    String? endpoint,
    String? p256dh,
    String? authSecret,
    String? deliveryMethod,
    bool? enabled,
    DateTime? lastUsed,
    int? failureCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'endpoint': endpoint,
      if (p256dh != null) 'p256dh': p256dh,
      if (authSecret != null) 'authSecret': authSecret,
      'deliveryMethod': deliveryMethod,
      'enabled': enabled,
      if (lastUsed != null) 'lastUsed': lastUsed?.toJson(),
      'failureCount': failureCount,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PushSubscriptionImpl extends PushSubscription {
  _PushSubscriptionImpl({
    int? id,
    required int userId,
    required String endpoint,
    String? p256dh,
    String? authSecret,
    required String deliveryMethod,
    required bool enabled,
    DateTime? lastUsed,
    required int failureCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          userId: userId,
          endpoint: endpoint,
          p256dh: p256dh,
          authSecret: authSecret,
          deliveryMethod: deliveryMethod,
          enabled: enabled,
          lastUsed: lastUsed,
          failureCount: failureCount,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [PushSubscription]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PushSubscription copyWith({
    Object? id = _Undefined,
    int? userId,
    String? endpoint,
    Object? p256dh = _Undefined,
    Object? authSecret = _Undefined,
    String? deliveryMethod,
    bool? enabled,
    Object? lastUsed = _Undefined,
    int? failureCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PushSubscription(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      endpoint: endpoint ?? this.endpoint,
      p256dh: p256dh is String? ? p256dh : this.p256dh,
      authSecret: authSecret is String? ? authSecret : this.authSecret,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      enabled: enabled ?? this.enabled,
      lastUsed: lastUsed is DateTime? ? lastUsed : this.lastUsed,
      failureCount: failureCount ?? this.failureCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
