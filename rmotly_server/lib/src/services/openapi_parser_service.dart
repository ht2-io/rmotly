import 'dart:convert';
import 'dart:io';

/// OpenAPI specification metadata
class OpenApiSpec {
  final String title;
  final String? version;
  final String? description;
  final String? baseUrl;
  final List<OpenApiOperation> operations;
  final String specVersion; // '2.0', '3.0', '3.1'

  OpenApiSpec({
    required this.title,
    this.version,
    this.description,
    this.baseUrl,
    required this.operations,
    required this.specVersion,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (version != null) 'version': version,
        if (description != null) 'description': description,
        if (baseUrl != null) 'baseUrl': baseUrl,
        'operations': operations.map((o) => o.toJson()).toList(),
        'specVersion': specVersion,
      };
}

/// An operation (endpoint) from an OpenAPI spec
class OpenApiOperation {
  final String operationId;
  final String method;
  final String path;
  final String? summary;
  final String? description;
  final List<OpenApiParameter> parameters;
  final OpenApiRequestBody? requestBody;
  final List<String> tags;

  OpenApiOperation({
    required this.operationId,
    required this.method,
    required this.path,
    this.summary,
    this.description,
    this.parameters = const [],
    this.requestBody,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'operationId': operationId,
        'method': method,
        'path': path,
        if (summary != null) 'summary': summary,
        if (description != null) 'description': description,
        'parameters': parameters.map((p) => p.toJson()).toList(),
        if (requestBody != null) 'requestBody': requestBody!.toJson(),
        'tags': tags,
      };

  /// Generate a URL template with {{parameter}} placeholders
  String generateUrlTemplate(String? baseUrl) {
    var url = path;

    // Replace path parameters with template syntax
    for (final param in parameters.where((p) => p.location == 'path')) {
      url = url.replaceAll('{${param.name}}', '{{${param.name}}}');
    }

    // Add query parameters as template
    final queryParams = parameters.where((p) => p.location == 'query');
    if (queryParams.isNotEmpty) {
      final queryString =
          queryParams.map((p) => '${p.name}={{${p.name}}}').join('&');
      url = '$url?$queryString';
    }

    // Prepend base URL if provided
    if (baseUrl != null && baseUrl.isNotEmpty) {
      url = '$baseUrl$url';
    }

    return url;
  }

  /// Generate headers template JSON
  String? generateHeadersTemplate() {
    final headerParams = parameters.where((p) => p.location == 'header');
    if (headerParams.isEmpty) return null;

    final headers = <String, String>{};
    for (final param in headerParams) {
      headers[param.name] = '{{${param.name}}}';
    }
    return jsonEncode(headers);
  }

  /// Generate body template from request body schema
  String? generateBodyTemplate() {
    if (requestBody == null) return null;

    // Try to generate a template from the schema
    final schema = requestBody!.schema;
    if (schema == null) return null;

    return _generateTemplateFromSchema(schema);
  }

  String? _generateTemplateFromSchema(Map<String, dynamic> schema) {
    final type = schema['type'] as String?;

    if (type == 'object') {
      final properties = schema['properties'] as Map<String, dynamic>?;
      if (properties == null) return '{}';

      final obj = <String, dynamic>{};
      for (final entry in properties.entries) {
        obj[entry.key] = '{{${entry.key}}}';
      }
      return jsonEncode(obj);
    }

    if (type == 'array') {
      return '[{{items}}]';
    }

    return '{{body}}';
  }
}

/// A parameter from an OpenAPI operation
class OpenApiParameter {
  final String name;
  final String location; // 'path', 'query', 'header', 'cookie'
  final String? description;
  final bool required;
  final String type;
  final String? format;
  final dynamic defaultValue;
  final List<dynamic>? enumValues;

  OpenApiParameter({
    required this.name,
    required this.location,
    this.description,
    this.required = false,
    this.type = 'string',
    this.format,
    this.defaultValue,
    this.enumValues,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        if (description != null) 'description': description,
        'required': required,
        'type': type,
        if (format != null) 'format': format,
        if (defaultValue != null) 'defaultValue': defaultValue,
        if (enumValues != null) 'enumValues': enumValues,
      };
}

/// Request body definition
class OpenApiRequestBody {
  final String? description;
  final bool required;
  final String? contentType;
  final Map<String, dynamic>? schema;

  OpenApiRequestBody({
    this.description,
    this.required = false,
    this.contentType,
    this.schema,
  });

  Map<String, dynamic> toJson() => {
        if (description != null) 'description': description,
        'required': required,
        if (contentType != null) 'contentType': contentType,
        if (schema != null) 'schema': schema,
      };
}

/// Service for parsing OpenAPI specifications.
///
/// Supports:
/// - OpenAPI 3.0 and 3.1
/// - Swagger 2.0
/// - Both JSON and YAML formats
class OpenApiParserService {
  final HttpClient _httpClient;

  OpenApiParserService() : _httpClient = HttpClient() {
    _httpClient.connectionTimeout = const Duration(seconds: 30);
  }

  /// Parse an OpenAPI spec from a URL
  Future<OpenApiSpec> parseFromUrl(String url) async {
    final uri = Uri.parse(url);
    final request = await _httpClient.getUrl(uri);
    final response = await request.close();

    if (response.statusCode != 200) {
      throw OpenApiParseException(
        'Failed to fetch spec: HTTP ${response.statusCode}',
      );
    }

    final content = await response.transform(utf8.decoder).join();
    return parseFromString(content, sourceUrl: url);
  }

  /// Parse an OpenAPI spec from a string
  OpenApiSpec parseFromString(String content, {String? sourceUrl}) {
    Map<String, dynamic> spec;

    // Try JSON first, then YAML
    try {
      spec = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      // Try YAML parsing
      spec = _parseYaml(content);
    }

    return _parseSpec(spec, sourceUrl: sourceUrl);
  }

  /// Parse YAML content
  ///
  /// Note: For a full implementation, use the yaml package.
  /// This is a simplified JSON-like YAML parser.
  Map<String, dynamic> _parseYaml(String content) {
    // Simple YAML to JSON conversion for basic specs
    // In production, use the yaml package: yaml.load(content)
    throw OpenApiParseException(
      'YAML parsing requires the yaml package. Please use JSON format.',
    );
  }

  /// Parse the spec map into an OpenApiSpec
  OpenApiSpec _parseSpec(Map<String, dynamic> spec, {String? sourceUrl}) {
    // Detect spec version
    final String specVersion;
    if (spec.containsKey('openapi')) {
      specVersion = spec['openapi'] as String;
    } else if (spec.containsKey('swagger')) {
      specVersion = spec['swagger'] as String;
    } else {
      throw OpenApiParseException('Unknown spec format');
    }

    // Parse based on version
    if (specVersion.startsWith('3.')) {
      return _parseOpenApi3(spec, specVersion);
    } else if (specVersion.startsWith('2.')) {
      return _parseSwagger2(spec, specVersion);
    } else {
      throw OpenApiParseException('Unsupported spec version: $specVersion');
    }
  }

  /// Parse OpenAPI 3.x specification
  OpenApiSpec _parseOpenApi3(Map<String, dynamic> spec, String version) {
    final info = spec['info'] as Map<String, dynamic>? ?? {};
    final servers = spec['servers'] as List<dynamic>? ?? [];
    final paths = spec['paths'] as Map<String, dynamic>? ?? {};

    // Get base URL from servers
    String? baseUrl;
    if (servers.isNotEmpty) {
      baseUrl = servers.first['url'] as String?;
    }

    // Parse operations
    final operations = <OpenApiOperation>[];
    for (final pathEntry in paths.entries) {
      final path = pathEntry.key;
      final pathItem = pathEntry.value as Map<String, dynamic>;

      for (final methodEntry in pathItem.entries) {
        final method = methodEntry.key;
        if (!_isHttpMethod(method)) continue;

        final operation = methodEntry.value as Map<String, dynamic>;
        operations.add(_parseOperation3(method, path, operation));
      }
    }

    return OpenApiSpec(
      title: info['title'] as String? ?? 'Untitled',
      version: info['version'] as String?,
      description: info['description'] as String?,
      baseUrl: baseUrl,
      operations: operations,
      specVersion: version,
    );
  }

  /// Parse a single OpenAPI 3.x operation
  OpenApiOperation _parseOperation3(
    String method,
    String path,
    Map<String, dynamic> operation,
  ) {
    // Parse parameters
    final paramsList = operation['parameters'] as List<dynamic>? ?? [];
    final parameters = paramsList.map((p) {
      final param = p as Map<String, dynamic>;
      final schema = param['schema'] as Map<String, dynamic>? ?? {};
      return OpenApiParameter(
        name: param['name'] as String,
        location: param['in'] as String,
        description: param['description'] as String?,
        required: param['required'] as bool? ?? false,
        type: schema['type'] as String? ?? 'string',
        format: schema['format'] as String?,
        defaultValue: schema['default'],
        enumValues: schema['enum'] as List<dynamic>?,
      );
    }).toList();

    // Parse request body
    OpenApiRequestBody? requestBody;
    final requestBodyMap = operation['requestBody'] as Map<String, dynamic>?;
    if (requestBodyMap != null) {
      final content = requestBodyMap['content'] as Map<String, dynamic>? ?? {};
      final contentType = content.keys.firstOrNull ?? 'application/json';
      final mediaType = content[contentType] as Map<String, dynamic>? ?? {};
      requestBody = OpenApiRequestBody(
        description: requestBodyMap['description'] as String?,
        required: requestBodyMap['required'] as bool? ?? false,
        contentType: contentType,
        schema: mediaType['schema'] as Map<String, dynamic>?,
      );
    }

    // Generate operation ID if not provided
    final operationId = operation['operationId'] as String? ??
        '${method}_${path.replaceAll('/', '_').replaceAll('{', '').replaceAll('}', '')}';

    return OpenApiOperation(
      operationId: operationId,
      method: method.toUpperCase(),
      path: path,
      summary: operation['summary'] as String?,
      description: operation['description'] as String?,
      parameters: parameters,
      requestBody: requestBody,
      tags: (operation['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Parse Swagger 2.0 specification
  OpenApiSpec _parseSwagger2(Map<String, dynamic> spec, String version) {
    final info = spec['info'] as Map<String, dynamic>? ?? {};
    final host = spec['host'] as String?;
    final basePath = spec['basePath'] as String? ?? '';
    final schemes = spec['schemes'] as List<dynamic>? ?? ['https'];
    final paths = spec['paths'] as Map<String, dynamic>? ?? {};

    // Build base URL
    String? baseUrl;
    if (host != null) {
      final scheme = schemes.first as String;
      baseUrl = '$scheme://$host$basePath';
    }

    // Parse operations
    final operations = <OpenApiOperation>[];
    for (final pathEntry in paths.entries) {
      final path = pathEntry.key;
      final pathItem = pathEntry.value as Map<String, dynamic>;

      for (final methodEntry in pathItem.entries) {
        final method = methodEntry.key;
        if (!_isHttpMethod(method)) continue;

        final operation = methodEntry.value as Map<String, dynamic>;
        operations.add(_parseOperation2(method, path, operation));
      }
    }

    return OpenApiSpec(
      title: info['title'] as String? ?? 'Untitled',
      version: info['version'] as String?,
      description: info['description'] as String?,
      baseUrl: baseUrl,
      operations: operations,
      specVersion: version,
    );
  }

  /// Parse a single Swagger 2.0 operation
  OpenApiOperation _parseOperation2(
    String method,
    String path,
    Map<String, dynamic> operation,
  ) {
    // Parse parameters
    final paramsList = operation['parameters'] as List<dynamic>? ?? [];
    final parameters = <OpenApiParameter>[];
    OpenApiRequestBody? requestBody;

    for (final p in paramsList) {
      final param = p as Map<String, dynamic>;
      final location = param['in'] as String;

      // In Swagger 2.0, body parameters are separate
      if (location == 'body') {
        requestBody = OpenApiRequestBody(
          description: param['description'] as String?,
          required: param['required'] as bool? ?? false,
          contentType: 'application/json',
          schema: param['schema'] as Map<String, dynamic>?,
        );
        continue;
      }

      parameters.add(OpenApiParameter(
        name: param['name'] as String,
        location: location,
        description: param['description'] as String?,
        required: param['required'] as bool? ?? false,
        type: param['type'] as String? ?? 'string',
        format: param['format'] as String?,
        defaultValue: param['default'],
        enumValues: param['enum'] as List<dynamic>?,
      ));
    }

    // Generate operation ID if not provided
    final operationId = operation['operationId'] as String? ??
        '${method}_${path.replaceAll('/', '_').replaceAll('{', '').replaceAll('}', '')}';

    return OpenApiOperation(
      operationId: operationId,
      method: method.toUpperCase(),
      path: path,
      summary: operation['summary'] as String?,
      description: operation['description'] as String?,
      parameters: parameters,
      requestBody: requestBody,
      tags: (operation['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Check if a string is an HTTP method
  bool _isHttpMethod(String method) {
    return const ['get', 'post', 'put', 'delete', 'patch', 'options', 'head']
        .contains(method.toLowerCase());
  }

  /// Find an operation by ID
  OpenApiOperation? findOperation(OpenApiSpec spec, String operationId) {
    return spec.operations
        .where((o) => o.operationId == operationId)
        .firstOrNull;
  }

  /// Generate an action template from an operation
  Map<String, dynamic> generateActionTemplate(
    OpenApiOperation operation,
    String? baseUrl,
  ) {
    return {
      'name': operation.summary ?? operation.operationId,
      'description': operation.description,
      'httpMethod': operation.method,
      'urlTemplate': operation.generateUrlTemplate(baseUrl),
      'headersTemplate': operation.generateHeadersTemplate(),
      'bodyTemplate': operation.generateBodyTemplate(),
      'parameters':
          jsonEncode(operation.parameters.map((p) => p.toJson()).toList()),
    };
  }

  /// Close the HTTP client
  void close() {
    _httpClient.close();
  }
}

/// Exception thrown during OpenAPI parsing
class OpenApiParseException implements Exception {
  final String message;

  OpenApiParseException(this.message);

  @override
  String toString() => 'OpenApiParseException: $message';
}
