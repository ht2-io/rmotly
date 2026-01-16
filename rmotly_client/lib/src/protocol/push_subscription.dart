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
    this.auth,
    required this.subscriptionType,
    required this.deviceId,
    this.userAgent,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.lastUsedAt,
    required this.failureCount,
  });

  factory PushSubscription({
    int? id,
    required int userId,
    required String endpoint,
    String? p256dh,
    String? auth,
    required String subscriptionType,
    required String deviceId,
    String? userAgent,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastUsedAt,
    required int failureCount,
  }) = _PushSubscriptionImpl;

  factory PushSubscription.fromJson(Map<String, dynamic> jsonSerialization) {
    return PushSubscription(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      endpoint: jsonSerialization['endpoint'] as String,
      p256dh: jsonSerialization['p256dh'] as String?,
      auth: jsonSerialization['auth'] as String?,
      subscriptionType: jsonSerialization['subscriptionType'] as String,
      deviceId: jsonSerialization['deviceId'] as String,
      userAgent: jsonSerialization['userAgent'] as String?,
      active: jsonSerialization['active'] as bool,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsedAt']),
      failureCount: jsonSerialization['failureCount'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Foreign key to the user who owns this subscription
  int userId;

  /// Push endpoint URL (UnifiedPush distributor or WebPush endpoint)
  String endpoint;

  /// WebPush p256dh key for encryption (base64url encoded)
  String? p256dh;

  /// WebPush auth secret for encryption (base64url encoded)
  String? auth;

  /// Subscription type (unifiedpush, webpush)
  String subscriptionType;

  /// Device identifier for managing multiple devices
  String deviceId;

  /// User agent or device description
  String? userAgent;

  /// Whether the subscription is currently active
  bool active;

  /// Timestamp when the subscription was created
  DateTime createdAt;

  /// Timestamp when the subscription was last updated
  DateTime updatedAt;

  /// Timestamp of the last successful push delivery
  DateTime? lastUsedAt;

  /// Number of consecutive delivery failures
  int failureCount;

  /// Returns a shallow copy of this [PushSubscription]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PushSubscription copyWith({
    int? id,
    int? userId,
    String? endpoint,
    String? p256dh,
    String? auth,
    String? subscriptionType,
    String? deviceId,
    String? userAgent,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    int? failureCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'endpoint': endpoint,
      if (p256dh != null) 'p256dh': p256dh,
      if (auth != null) 'auth': auth,
      'subscriptionType': subscriptionType,
      'deviceId': deviceId,
      if (userAgent != null) 'userAgent': userAgent,
      'active': active,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      'failureCount': failureCount,
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
    String? auth,
    required String subscriptionType,
    required String deviceId,
    String? userAgent,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastUsedAt,
    required int failureCount,
  }) : super._(
          id: id,
          userId: userId,
          endpoint: endpoint,
          p256dh: p256dh,
          auth: auth,
          subscriptionType: subscriptionType,
          deviceId: deviceId,
          userAgent: userAgent,
          active: active,
          createdAt: createdAt,
          updatedAt: updatedAt,
          lastUsedAt: lastUsedAt,
          failureCount: failureCount,
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
    Object? auth = _Undefined,
    String? subscriptionType,
    String? deviceId,
    Object? userAgent = _Undefined,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? lastUsedAt = _Undefined,
    int? failureCount,
  }) {
    return PushSubscription(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      endpoint: endpoint ?? this.endpoint,
      p256dh: p256dh is String? ? p256dh : this.p256dh,
      auth: auth is String? ? auth : this.auth,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      deviceId: deviceId ?? this.deviceId,
      userAgent: userAgent is String? ? userAgent : this.userAgent,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsedAt: lastUsedAt is DateTime? ? lastUsedAt : this.lastUsedAt,
      failureCount: failureCount ?? this.failureCount,
    );
  }
}
