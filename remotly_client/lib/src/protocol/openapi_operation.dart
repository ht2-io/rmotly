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
import 'openapi_parameter.dart' as _i2;

abstract class OpenApiOperation implements _i1.SerializableModel {
  OpenApiOperation._({
    required this.operationId,
    required this.method,
    required this.path,
    this.summary,
    this.description,
    required this.parameters,
    required this.tags,
  });

  factory OpenApiOperation({
    required String operationId,
    required String method,
    required String path,
    String? summary,
    String? description,
    required List<_i2.OpenApiParameter> parameters,
    required List<String> tags,
  }) = _OpenApiOperationImpl;

  factory OpenApiOperation.fromJson(Map<String, dynamic> jsonSerialization) {
    return OpenApiOperation(
      operationId: jsonSerialization['operationId'] as String,
      method: jsonSerialization['method'] as String,
      path: jsonSerialization['path'] as String,
      summary: jsonSerialization['summary'] as String?,
      description: jsonSerialization['description'] as String?,
      parameters: (jsonSerialization['parameters'] as List)
          .map(
              (e) => _i2.OpenApiParameter.fromJson((e as Map<String, dynamic>)))
          .toList(),
      tags:
          (jsonSerialization['tags'] as List).map((e) => e as String).toList(),
    );
  }

  /// Unique identifier for the operation
  String operationId;

  /// HTTP method (GET, POST, PUT, DELETE, etc.)
  String method;

  /// Path of the operation
  String path;

  /// Short summary of the operation
  String? summary;

  /// Detailed description of the operation
  String? description;

  /// List of parameters for the operation
  List<_i2.OpenApiParameter> parameters;

  /// Tags associated with the operation
  List<String> tags;

  /// Returns a shallow copy of this [OpenApiOperation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OpenApiOperation copyWith({
    String? operationId,
    String? method,
    String? path,
    String? summary,
    String? description,
    List<_i2.OpenApiParameter>? parameters,
    List<String>? tags,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'operationId': operationId,
      'method': method,
      'path': path,
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      'parameters': parameters.toJson(valueToJson: (v) => v.toJson()),
      'tags': tags.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OpenApiOperationImpl extends OpenApiOperation {
  _OpenApiOperationImpl({
    required String operationId,
    required String method,
    required String path,
    String? summary,
    String? description,
    required List<_i2.OpenApiParameter> parameters,
    required List<String> tags,
  }) : super._(
          operationId: operationId,
          method: method,
          path: path,
          summary: summary,
          description: description,
          parameters: parameters,
          tags: tags,
        );

  /// Returns a shallow copy of this [OpenApiOperation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OpenApiOperation copyWith({
    String? operationId,
    String? method,
    String? path,
    Object? summary = _Undefined,
    Object? description = _Undefined,
    List<_i2.OpenApiParameter>? parameters,
    List<String>? tags,
  }) {
    return OpenApiOperation(
      operationId: operationId ?? this.operationId,
      method: method ?? this.method,
      path: path ?? this.path,
      summary: summary is String? ? summary : this.summary,
      description: description is String? ? description : this.description,
      parameters:
          parameters ?? this.parameters.map((e0) => e0.copyWith()).toList(),
      tags: tags ?? this.tags.map((e0) => e0).toList(),
    );
  }
}
