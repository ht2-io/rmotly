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

abstract class Action implements _i1.SerializableModel {
  Action._({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.httpMethod,
    required this.urlTemplate,
    this.headersTemplate,
    this.bodyTemplate,
    this.openApiSpecUrl,
    this.openApiOperationId,
    this.parameters,
    this.encryptedCredentials,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Action({
    int? id,
    required int userId,
    required String name,
    String? description,
    required String httpMethod,
    required String urlTemplate,
    String? headersTemplate,
    String? bodyTemplate,
    String? openApiSpecUrl,
    String? openApiOperationId,
    String? parameters,
    String? encryptedCredentials,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ActionImpl;

  factory Action.fromJson(Map<String, dynamic> jsonSerialization) {
    return Action(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      httpMethod: jsonSerialization['httpMethod'] as String,
      urlTemplate: jsonSerialization['urlTemplate'] as String,
      headersTemplate: jsonSerialization['headersTemplate'] as String?,
      bodyTemplate: jsonSerialization['bodyTemplate'] as String?,
      openApiSpecUrl: jsonSerialization['openApiSpecUrl'] as String?,
      openApiOperationId: jsonSerialization['openApiOperationId'] as String?,
      parameters: jsonSerialization['parameters'] as String?,
      encryptedCredentials:
          jsonSerialization['encryptedCredentials'] as String?,
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

  /// Foreign key to the user who owns this action
  int userId;

  /// Display name for the action
  String name;

  /// Optional description of what the action does
  String? description;

  /// HTTP method (GET, POST, PUT, DELETE, PATCH)
  String httpMethod;

  /// URL template with {{variable}} placeholders
  String urlTemplate;

  /// Optional headers template as JSON string
  String? headersTemplate;

  /// Optional body template with {{variable}} placeholders
  String? bodyTemplate;

  /// Optional OpenAPI spec URL for documentation
  String? openApiSpecUrl;

  /// Optional OpenAPI operation ID if imported from spec
  String? openApiOperationId;

  /// Optional parameters definition as JSON string
  String? parameters;

  /// Encrypted credentials for authentication (API keys, tokens, etc.)
  /// Format: encrypted JSON map of credential key-value pairs
  String? encryptedCredentials;

  /// Timestamp when the action was created
  DateTime createdAt;

  /// Timestamp when the action was last updated
  DateTime updatedAt;

  /// Returns a shallow copy of this [Action]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Action copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    String? httpMethod,
    String? urlTemplate,
    String? headersTemplate,
    String? bodyTemplate,
    String? openApiSpecUrl,
    String? openApiOperationId,
    String? parameters,
    String? encryptedCredentials,
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
      'httpMethod': httpMethod,
      'urlTemplate': urlTemplate,
      if (headersTemplate != null) 'headersTemplate': headersTemplate,
      if (bodyTemplate != null) 'bodyTemplate': bodyTemplate,
      if (openApiSpecUrl != null) 'openApiSpecUrl': openApiSpecUrl,
      if (openApiOperationId != null) 'openApiOperationId': openApiOperationId,
      if (parameters != null) 'parameters': parameters,
      if (encryptedCredentials != null)
        'encryptedCredentials': encryptedCredentials,
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

class _ActionImpl extends Action {
  _ActionImpl({
    int? id,
    required int userId,
    required String name,
    String? description,
    required String httpMethod,
    required String urlTemplate,
    String? headersTemplate,
    String? bodyTemplate,
    String? openApiSpecUrl,
    String? openApiOperationId,
    String? parameters,
    String? encryptedCredentials,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          userId: userId,
          name: name,
          description: description,
          httpMethod: httpMethod,
          urlTemplate: urlTemplate,
          headersTemplate: headersTemplate,
          bodyTemplate: bodyTemplate,
          openApiSpecUrl: openApiSpecUrl,
          openApiOperationId: openApiOperationId,
          parameters: parameters,
          encryptedCredentials: encryptedCredentials,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [Action]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Action copyWith({
    Object? id = _Undefined,
    int? userId,
    String? name,
    Object? description = _Undefined,
    String? httpMethod,
    String? urlTemplate,
    Object? headersTemplate = _Undefined,
    Object? bodyTemplate = _Undefined,
    Object? openApiSpecUrl = _Undefined,
    Object? openApiOperationId = _Undefined,
    Object? parameters = _Undefined,
    Object? encryptedCredentials = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Action(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      httpMethod: httpMethod ?? this.httpMethod,
      urlTemplate: urlTemplate ?? this.urlTemplate,
      headersTemplate:
          headersTemplate is String? ? headersTemplate : this.headersTemplate,
      bodyTemplate: bodyTemplate is String? ? bodyTemplate : this.bodyTemplate,
      openApiSpecUrl:
          openApiSpecUrl is String? ? openApiSpecUrl : this.openApiSpecUrl,
      openApiOperationId: openApiOperationId is String?
          ? openApiOperationId
          : this.openApiOperationId,
      parameters: parameters is String? ? parameters : this.parameters,
      encryptedCredentials: encryptedCredentials is String?
          ? encryptedCredentials
          : this.encryptedCredentials,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
