/// OpenAPI specification models for parsing and displaying API operations

/// Represents a parsed OpenAPI specification
class OpenApiSpec {
  final String title;
  final String? description;
  final String version;
  final String? baseUrl;
  final List<OpenApiServer> servers;
  final List<OpenApiOperation> operations;
  final Map<String, dynamic> rawSpec;

  const OpenApiSpec({
    required this.title,
    this.description,
    required this.version,
    this.baseUrl,
    required this.servers,
    required this.operations,
    required this.rawSpec,
  });

  /// Get effective base URL
  String? get effectiveBaseUrl =>
      baseUrl ?? (servers.isNotEmpty ? servers.first.url : null);
}

/// Represents an OpenAPI server definition
class OpenApiServer {
  final String url;
  final String? description;

  const OpenApiServer({
    required this.url,
    this.description,
  });
}

/// Represents an API operation from OpenAPI spec
class OpenApiOperation {
  final String operationId;
  final String path;
  final String method;
  final String? summary;
  final String? description;
  final List<String> tags;
  final List<OpenApiParameter> parameters;
  final OpenApiRequestBody? requestBody;
  final Map<String, OpenApiResponse> responses;
  final bool deprecated;

  const OpenApiOperation({
    required this.operationId,
    required this.path,
    required this.method,
    this.summary,
    this.description,
    required this.tags,
    required this.parameters,
    this.requestBody,
    required this.responses,
    this.deprecated = false,
  });

  /// Get display name (summary or operationId)
  String get displayName => summary ?? operationId;

  /// Get all path parameters
  List<OpenApiParameter> get pathParameters =>
      parameters.where((p) => p.location == ParameterLocation.path).toList();

  /// Get all query parameters
  List<OpenApiParameter> get queryParameters =>
      parameters.where((p) => p.location == ParameterLocation.query).toList();

  /// Get all header parameters
  List<OpenApiParameter> get headerParameters =>
      parameters.where((p) => p.location == ParameterLocation.header).toList();

  /// Get all required parameters
  List<OpenApiParameter> get requiredParameters =>
      parameters.where((p) => p.required).toList();
}

/// Parameter location in request
enum ParameterLocation { path, query, header, cookie }

/// Represents an API parameter
class OpenApiParameter {
  final String name;
  final ParameterLocation location;
  final bool required;
  final String? description;
  final OpenApiSchema? schema;
  final dynamic defaultValue;
  final dynamic example;

  const OpenApiParameter({
    required this.name,
    required this.location,
    required this.required,
    this.description,
    this.schema,
    this.defaultValue,
    this.example,
  });

  /// Get parameter type as string
  String get typeString => schema?.type ?? 'string';
}

/// Represents a request body definition
class OpenApiRequestBody {
  final String? description;
  final bool required;
  final Map<String, OpenApiMediaType> content;

  const OpenApiRequestBody({
    this.description,
    required this.required,
    required this.content,
  });

  /// Get JSON content type if available
  OpenApiMediaType? get jsonContent =>
      content['application/json'] ?? content['application/*'];

  /// Check if request expects JSON
  bool get expectsJson => content.containsKey('application/json');
}

/// Represents a media type content
class OpenApiMediaType {
  final OpenApiSchema? schema;
  final dynamic example;

  const OpenApiMediaType({
    this.schema,
    this.example,
  });
}

/// Represents a response definition
class OpenApiResponse {
  final String statusCode;
  final String? description;
  final Map<String, OpenApiMediaType>? content;

  const OpenApiResponse({
    required this.statusCode,
    this.description,
    this.content,
  });
}

/// Represents a schema definition
class OpenApiSchema {
  final String? type;
  final String? format;
  final String? description;
  final List<String>? enumValues;
  final OpenApiSchema? items; // For arrays
  final Map<String, OpenApiSchema>? properties; // For objects
  final List<String>? requiredProperties;
  final dynamic defaultValue;
  final dynamic example;

  const OpenApiSchema({
    this.type,
    this.format,
    this.description,
    this.enumValues,
    this.items,
    this.properties,
    this.requiredProperties,
    this.defaultValue,
    this.example,
  });

  /// Check if this is an array type
  bool get isArray => type == 'array';

  /// Check if this is an object type
  bool get isObject => type == 'object';

  /// Get type display string
  String get typeDisplayString {
    if (isArray && items != null) {
      return '${items!.typeDisplayString}[]';
    }
    if (format != null) {
      return '$type ($format)';
    }
    return type ?? 'any';
  }
}
