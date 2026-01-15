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
import 'openapi_operation.dart' as _i2;

abstract class OpenApiSpec implements _i1.SerializableModel {
  OpenApiSpec._({
    required this.title,
    this.version,
    this.description,
    this.baseUrl,
    required this.specVersion,
    required this.operations,
  });

  factory OpenApiSpec({
    required String title,
    String? version,
    String? description,
    String? baseUrl,
    required String specVersion,
    required List<_i2.OpenApiOperation> operations,
  }) = _OpenApiSpecImpl;

  factory OpenApiSpec.fromJson(Map<String, dynamic> jsonSerialization) {
    return OpenApiSpec(
      title: jsonSerialization['title'] as String,
      version: jsonSerialization['version'] as String?,
      description: jsonSerialization['description'] as String?,
      baseUrl: jsonSerialization['baseUrl'] as String?,
      specVersion: jsonSerialization['specVersion'] as String,
      operations: (jsonSerialization['operations'] as List)
          .map(
              (e) => _i2.OpenApiOperation.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  /// Title of the API
  String title;

  /// Version of the API
  String? version;

  /// Description of the API
  String? description;

  /// Base URL for the API
  String? baseUrl;

  /// OpenAPI spec version (e.g., '2.0', '3.0', '3.1')
  String specVersion;

  /// List of operations in the specification
  List<_i2.OpenApiOperation> operations;

  /// Returns a shallow copy of this [OpenApiSpec]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OpenApiSpec copyWith({
    String? title,
    String? version,
    String? description,
    String? baseUrl,
    String? specVersion,
    List<_i2.OpenApiOperation>? operations,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (version != null) 'version': version,
      if (description != null) 'description': description,
      if (baseUrl != null) 'baseUrl': baseUrl,
      'specVersion': specVersion,
      'operations': operations.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OpenApiSpecImpl extends OpenApiSpec {
  _OpenApiSpecImpl({
    required String title,
    String? version,
    String? description,
    String? baseUrl,
    required String specVersion,
    required List<_i2.OpenApiOperation> operations,
  }) : super._(
          title: title,
          version: version,
          description: description,
          baseUrl: baseUrl,
          specVersion: specVersion,
          operations: operations,
        );

  /// Returns a shallow copy of this [OpenApiSpec]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OpenApiSpec copyWith({
    String? title,
    Object? version = _Undefined,
    Object? description = _Undefined,
    Object? baseUrl = _Undefined,
    String? specVersion,
    List<_i2.OpenApiOperation>? operations,
  }) {
    return OpenApiSpec(
      title: title ?? this.title,
      version: version is String? ? version : this.version,
      description: description is String? ? description : this.description,
      baseUrl: baseUrl is String? ? baseUrl : this.baseUrl,
      specVersion: specVersion ?? this.specVersion,
      operations:
          operations ?? this.operations.map((e0) => e0.copyWith()).toList(),
    );
  }
}
