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

abstract class OpenApiParameter implements _i1.SerializableModel {
  OpenApiParameter._({
    required this.name,
    required this.location,
    this.description,
    required this.required,
    required this.type,
    this.format,
  });

  factory OpenApiParameter({
    required String name,
    required String location,
    String? description,
    required bool required,
    required String type,
    String? format,
  }) = _OpenApiParameterImpl;

  factory OpenApiParameter.fromJson(Map<String, dynamic> jsonSerialization) {
    return OpenApiParameter(
      name: jsonSerialization['name'] as String,
      location: jsonSerialization['location'] as String,
      description: jsonSerialization['description'] as String?,
      required: jsonSerialization['required'] as bool,
      type: jsonSerialization['type'] as String,
      format: jsonSerialization['format'] as String?,
    );
  }

  /// Name of the parameter
  String name;

  /// Location of the parameter (path, query, header, cookie)
  String location;

  /// Description of the parameter
  String? description;

  /// Whether the parameter is required
  bool required;

  /// Data type of the parameter
  String type;

  /// Format of the parameter (e.g., int32, date-time)
  String? format;

  /// Returns a shallow copy of this [OpenApiParameter]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OpenApiParameter copyWith({
    String? name,
    String? location,
    String? description,
    bool? required,
    String? type,
    String? format,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      if (description != null) 'description': description,
      'required': required,
      'type': type,
      if (format != null) 'format': format,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OpenApiParameterImpl extends OpenApiParameter {
  _OpenApiParameterImpl({
    required String name,
    required String location,
    String? description,
    required bool required,
    required String type,
    String? format,
  }) : super._(
          name: name,
          location: location,
          description: description,
          required: required,
          type: type,
          format: format,
        );

  /// Returns a shallow copy of this [OpenApiParameter]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OpenApiParameter copyWith({
    String? name,
    String? location,
    Object? description = _Undefined,
    bool? required,
    String? type,
    Object? format = _Undefined,
  }) {
    return OpenApiParameter(
      name: name ?? this.name,
      location: location ?? this.location,
      description: description is String? ? description : this.description,
      required: required ?? this.required,
      type: type ?? this.type,
      format: format is String? ? format : this.format,
    );
  }
}
