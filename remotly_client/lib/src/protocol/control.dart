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

abstract class Control implements _i1.SerializableModel {
  Control._({
    this.id,
    required this.userId,
    required this.name,
    required this.controlType,
    this.actionId,
    required this.config,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Control({
    int? id,
    required int userId,
    required String name,
    required String controlType,
    int? actionId,
    required String config,
    required int position,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ControlImpl;

  factory Control.fromJson(Map<String, dynamic> jsonSerialization) {
    return Control(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      name: jsonSerialization['name'] as String,
      controlType: jsonSerialization['controlType'] as String,
      actionId: jsonSerialization['actionId'] as int?,
      config: jsonSerialization['config'] as String,
      position: jsonSerialization['position'] as int,
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

  /// Foreign key to the user who owns this control
  int userId;

  /// Display name for the control
  String name;

  /// Type of control (button, toggle, slider, input, dropdown)
  String controlType;

  /// Optional foreign key to the action triggered by this control
  int? actionId;

  /// Control configuration as JSON string
  String config;

  /// Position/order in the dashboard
  int position;

  /// Timestamp when the control was created
  DateTime createdAt;

  /// Timestamp when the control was last updated
  DateTime updatedAt;

  /// Returns a shallow copy of this [Control]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Control copyWith({
    int? id,
    int? userId,
    String? name,
    String? controlType,
    int? actionId,
    String? config,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'name': name,
      'controlType': controlType,
      if (actionId != null) 'actionId': actionId,
      'config': config,
      'position': position,
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

class _ControlImpl extends Control {
  _ControlImpl({
    int? id,
    required int userId,
    required String name,
    required String controlType,
    int? actionId,
    required String config,
    required int position,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          userId: userId,
          name: name,
          controlType: controlType,
          actionId: actionId,
          config: config,
          position: position,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [Control]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Control copyWith({
    Object? id = _Undefined,
    int? userId,
    String? name,
    String? controlType,
    Object? actionId = _Undefined,
    String? config,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Control(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      controlType: controlType ?? this.controlType,
      actionId: actionId is int? ? actionId : this.actionId,
      config: config ?? this.config,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
