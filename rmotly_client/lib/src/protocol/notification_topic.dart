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

abstract class NotificationTopic implements _i1.SerializableModel {
  NotificationTopic._({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.apiKey,
    required this.enabled,
    required this.config,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationTopic({
    int? id,
    required int userId,
    required String name,
    String? description,
    required String apiKey,
    required bool enabled,
    required String config,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationTopicImpl;

  factory NotificationTopic.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotificationTopic(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      apiKey: jsonSerialization['apiKey'] as String,
      enabled: jsonSerialization['enabled'] as bool,
      config: jsonSerialization['config'] as String,
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

  /// Foreign key to the user who owns this topic
  int userId;

  /// Display name for the topic
  String name;

  /// Optional description of what notifications this topic receives
  String? description;

  /// API key for authenticating webhook requests (stored encrypted)
  String apiKey;

  /// Whether the topic is enabled
  bool enabled;

  /// Topic configuration as JSON string (notification template, priority, etc.)
  String config;

  /// Timestamp when the topic was created
  DateTime createdAt;

  /// Timestamp when the topic was last updated
  DateTime updatedAt;

  /// Returns a shallow copy of this [NotificationTopic]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NotificationTopic copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    String? apiKey,
    bool? enabled,
    String? config,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'name': name,
      if (description != null) 'description': description,
      'apiKey': apiKey,
      'enabled': enabled,
      'config': config,
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

class _NotificationTopicImpl extends NotificationTopic {
  _NotificationTopicImpl({
    int? id,
    required int userId,
    required String name,
    String? description,
    required String apiKey,
    required bool enabled,
    required String config,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          userId: userId,
          name: name,
          description: description,
          apiKey: apiKey,
          enabled: enabled,
          config: config,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [NotificationTopic]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NotificationTopic copyWith({
    Object? id = _Undefined,
    int? userId,
    String? name,
    Object? description = _Undefined,
    String? apiKey,
    bool? enabled,
    String? config,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationTopic(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      apiKey: apiKey ?? this.apiKey,
      enabled: enabled ?? this.enabled,
      config: config ?? this.config,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
