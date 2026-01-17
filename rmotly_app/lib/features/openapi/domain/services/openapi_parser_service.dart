import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/openapi_models.dart';

/// Service for parsing OpenAPI specifications
class OpenApiParserService {
  final Dio? _dio;

  OpenApiParserService({Dio? dio}) : _dio = dio;

  Dio get _client => _dio ?? Dio();

  /// Fetch and parse an OpenAPI spec from a URL
  Future<OpenApiSpec> parseFromUrl(String url) async {
    try {
      final response = await _client.get<dynamic>(url);

      if (response.statusCode != 200) {
        throw OpenApiParseException(
          'Failed to fetch OpenAPI spec: HTTP ${response.statusCode}',
        );
      }

      Map<String, dynamic> spec;

      // Handle response data - Dio automatically parses JSON
      if (response.data is Map<String, dynamic>) {
        spec = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        // Try to parse as JSON if it's a string
        try {
          spec = json.decode(response.data as String) as Map<String, dynamic>;
        } catch (_) {
          throw OpenApiParseException(
            'Failed to parse OpenAPI spec: Invalid JSON format',
          );
        }
      } else {
        throw OpenApiParseException(
          'Failed to parse OpenAPI spec: Unexpected response format',
        );
      }

      return parseSpec(spec, baseUrl: _extractBaseUrl(url));
    } on DioException catch (e) {
      throw OpenApiParseException('Failed to fetch OpenAPI spec: ${e.message}');
    } catch (e) {
      if (e is OpenApiParseException) rethrow;
      throw OpenApiParseException('Failed to fetch OpenAPI spec: $e');
    }
  }

  /// Parse an OpenAPI spec from a JSON string
  Future<OpenApiSpec> parseFromJson(String jsonContent) async {
    try {
      final spec = json.decode(jsonContent) as Map<String, dynamic>;
      return parseSpec(spec);
    } catch (e) {
      if (e is OpenApiParseException) rethrow;
      throw OpenApiParseException('Failed to parse OpenAPI spec: $e');
    }
  }

  /// Parse an OpenAPI spec from a Map
  OpenApiSpec parseSpec(Map<String, dynamic> spec, {String? baseUrl}) {
    // Detect OpenAPI version
    final openApiVersion = spec['openapi'] as String?;
    final swaggerVersion = spec['swagger'] as String?;

    if (openApiVersion != null && openApiVersion.startsWith('3')) {
      return _parseOpenApi3(spec, baseUrl: baseUrl);
    } else if (swaggerVersion != null && swaggerVersion.startsWith('2')) {
      return _parseSwagger2(spec, baseUrl: baseUrl);
    } else {
      throw OpenApiParseException(
        'Unsupported OpenAPI version. Expected OpenAPI 3.x or Swagger 2.x',
      );
    }
  }

  /// Parse OpenAPI 3.x specification
  OpenApiSpec _parseOpenApi3(Map<String, dynamic> spec, {String? baseUrl}) {
    final info = spec['info'] as Map<String, dynamic>? ?? {};
    final serversRaw = spec['servers'] as List<dynamic>? ?? [];
    final pathsRaw = spec['paths'] as Map<String, dynamic>? ?? {};

    // Parse servers
    final servers = serversRaw.map((s) {
      final server = s as Map<String, dynamic>;
      return OpenApiServer(
        url: server['url'] as String? ?? '',
        description: server['description'] as String?,
      );
    }).toList();

    // Parse operations from paths
    final operations = <OpenApiOperation>[];
    pathsRaw.forEach((path, pathItem) {
      if (pathItem is Map<String, dynamic>) {
        _parsePathItem(path, pathItem, operations, spec);
      }
    });

    return OpenApiSpec(
      title: info['title'] as String? ?? 'Untitled API',
      description: info['description'] as String?,
      version: info['version'] as String? ?? '1.0.0',
      baseUrl: baseUrl,
      servers: servers,
      operations: operations,
      rawSpec: spec,
    );
  }

  /// Parse Swagger 2.x specification
  OpenApiSpec _parseSwagger2(Map<String, dynamic> spec, {String? baseUrl}) {
    final info = spec['info'] as Map<String, dynamic>? ?? {};
    final host = spec['host'] as String?;
    final basePath = spec['basePath'] as String? ?? '';
    final schemes = (spec['schemes'] as List<dynamic>?) ?? ['https'];
    final pathsRaw = spec['paths'] as Map<String, dynamic>? ?? {};

    // Build server URL from Swagger 2 fields
    final servers = <OpenApiServer>[];
    if (host != null) {
      final scheme = schemes.first as String;
      servers.add(OpenApiServer(
        url: '$scheme://$host$basePath',
        description: 'Server',
      ));
    }

    // Parse operations from paths
    final operations = <OpenApiOperation>[];
    pathsRaw.forEach((path, pathItem) {
      if (pathItem is Map<String, dynamic>) {
        _parsePathItemSwagger2(path, pathItem, operations, spec);
      }
    });

    return OpenApiSpec(
      title: info['title'] as String? ?? 'Untitled API',
      description: info['description'] as String?,
      version: info['version'] as String? ?? '1.0.0',
      baseUrl: baseUrl,
      servers: servers,
      operations: operations,
      rawSpec: spec,
    );
  }

  void _parsePathItem(
    String path,
    Map<String, dynamic> pathItem,
    List<OpenApiOperation> operations,
    Map<String, dynamic> spec,
  ) {
    final methods = [
      'get',
      'post',
      'put',
      'patch',
      'delete',
      'head',
      'options'
    ];
    final pathParameters = _parseParameters(
      pathItem['parameters'] as List<dynamic>?,
      spec,
    );

    for (final method in methods) {
      if (pathItem.containsKey(method)) {
        final operation = pathItem[method] as Map<String, dynamic>;
        final operationId = operation['operationId'] as String? ??
            '${method}_${path.replaceAll('/', '_').replaceAll('{', '').replaceAll('}', '')}';

        // Merge path-level and operation-level parameters
        final operationParams = _parseParameters(
          operation['parameters'] as List<dynamic>?,
          spec,
        );
        final allParams = [...pathParameters, ...operationParams];

        operations.add(OpenApiOperation(
          operationId: operationId,
          path: path,
          method: method.toUpperCase(),
          summary: operation['summary'] as String?,
          description: operation['description'] as String?,
          tags: (operation['tags'] as List<dynamic>?)
                  ?.map((t) => t.toString())
                  .toList() ??
              [],
          parameters: allParams,
          requestBody: _parseRequestBody(operation['requestBody'], spec),
          responses: _parseResponses(operation['responses'], spec),
          deprecated: operation['deprecated'] as bool? ?? false,
        ));
      }
    }
  }

  void _parsePathItemSwagger2(
    String path,
    Map<String, dynamic> pathItem,
    List<OpenApiOperation> operations,
    Map<String, dynamic> spec,
  ) {
    final methods = [
      'get',
      'post',
      'put',
      'patch',
      'delete',
      'head',
      'options'
    ];
    final pathParameters = _parseParametersSwagger2(
      pathItem['parameters'] as List<dynamic>?,
      spec,
    );

    for (final method in methods) {
      if (pathItem.containsKey(method)) {
        final operation = pathItem[method] as Map<String, dynamic>;
        final operationId = operation['operationId'] as String? ??
            '${method}_${path.replaceAll('/', '_').replaceAll('{', '').replaceAll('}', '')}';

        // Merge path-level and operation-level parameters
        final operationParams = _parseParametersSwagger2(
          operation['parameters'] as List<dynamic>?,
          spec,
        );
        final allParams = [...pathParameters, ...operationParams];

        // In Swagger 2, request body is part of parameters with "in: body"
        final bodyParam = operationParams.isEmpty
            ? null
            : operation['parameters']?.firstWhere(
                (p) => p['in'] == 'body',
                orElse: () => null,
              );

        OpenApiRequestBody? requestBody;
        if (bodyParam != null) {
          final schema = _parseSchema(bodyParam['schema'], spec);
          requestBody = OpenApiRequestBody(
            description: bodyParam['description'] as String?,
            required: bodyParam['required'] as bool? ?? false,
            content: {
              'application/json': OpenApiMediaType(schema: schema),
            },
          );
        }

        operations.add(OpenApiOperation(
          operationId: operationId,
          path: path,
          method: method.toUpperCase(),
          summary: operation['summary'] as String?,
          description: operation['description'] as String?,
          tags: (operation['tags'] as List<dynamic>?)
                  ?.map((t) => t.toString())
                  .toList() ??
              [],
          parameters: allParams
              .where((p) => p.location != ParameterLocation.cookie)
              .toList(),
          requestBody: requestBody,
          responses: _parseResponsesSwagger2(operation['responses'], spec),
          deprecated: operation['deprecated'] as bool? ?? false,
        ));
      }
    }
  }

  List<OpenApiParameter> _parseParameters(
    List<dynamic>? parameters,
    Map<String, dynamic> spec,
  ) {
    if (parameters == null) return [];

    return parameters.map((p) {
      var param = p as Map<String, dynamic>;

      // Handle $ref
      if (param.containsKey('\$ref')) {
        param = _resolveRef(param['\$ref'] as String, spec);
      }

      return OpenApiParameter(
        name: param['name'] as String? ?? '',
        location: _parseLocation(param['in'] as String?),
        required: param['required'] as bool? ?? false,
        description: param['description'] as String?,
        schema: _parseSchema(param['schema'], spec),
        defaultValue: param['schema']?['default'],
        example: param['example'],
      );
    }).toList();
  }

  List<OpenApiParameter> _parseParametersSwagger2(
    List<dynamic>? parameters,
    Map<String, dynamic> spec,
  ) {
    if (parameters == null) return [];

    return parameters
        .where((p) => (p as Map<String, dynamic>)['in'] != 'body')
        .map((p) {
      var param = p as Map<String, dynamic>;

      // Handle $ref
      if (param.containsKey('\$ref')) {
        param = _resolveRef(param['\$ref'] as String, spec);
      }

      return OpenApiParameter(
        name: param['name'] as String? ?? '',
        location: _parseLocation(param['in'] as String?),
        required: param['required'] as bool? ?? false,
        description: param['description'] as String?,
        schema: OpenApiSchema(
          type: param['type'] as String?,
          format: param['format'] as String?,
          enumValues: (param['enum'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
          defaultValue: param['default'],
        ),
        defaultValue: param['default'],
        example: param['x-example'],
      );
    }).toList();
  }

  ParameterLocation _parseLocation(String? location) {
    switch (location) {
      case 'path':
        return ParameterLocation.path;
      case 'query':
        return ParameterLocation.query;
      case 'header':
        return ParameterLocation.header;
      case 'cookie':
        return ParameterLocation.cookie;
      default:
        return ParameterLocation.query;
    }
  }

  OpenApiRequestBody? _parseRequestBody(
    dynamic requestBody,
    Map<String, dynamic> spec,
  ) {
    if (requestBody == null) return null;

    var body = requestBody as Map<String, dynamic>;

    // Handle $ref
    if (body.containsKey('\$ref')) {
      body = _resolveRef(body['\$ref'] as String, spec);
    }

    final content = body['content'] as Map<String, dynamic>? ?? {};
    final parsedContent = <String, OpenApiMediaType>{};

    content.forEach((mediaType, mediaValue) {
      final media = mediaValue as Map<String, dynamic>;
      parsedContent[mediaType] = OpenApiMediaType(
        schema: _parseSchema(media['schema'], spec),
        example: media['example'],
      );
    });

    return OpenApiRequestBody(
      description: body['description'] as String?,
      required: body['required'] as bool? ?? false,
      content: parsedContent,
    );
  }

  Map<String, OpenApiResponse> _parseResponses(
    dynamic responses,
    Map<String, dynamic> spec,
  ) {
    if (responses == null) return {};

    final result = <String, OpenApiResponse>{};
    final responsesMap = responses as Map<String, dynamic>;

    responsesMap.forEach((statusCode, response) {
      var resp = response as Map<String, dynamic>;

      // Handle $ref
      if (resp.containsKey('\$ref')) {
        resp = _resolveRef(resp['\$ref'] as String, spec);
      }

      final content = resp['content'] as Map<String, dynamic>?;
      Map<String, OpenApiMediaType>? parsedContent;

      if (content != null) {
        parsedContent = {};
        content.forEach((mediaType, mediaValue) {
          final media = mediaValue as Map<String, dynamic>;
          parsedContent![mediaType] = OpenApiMediaType(
            schema: _parseSchema(media['schema'], spec),
            example: media['example'],
          );
        });
      }

      result[statusCode] = OpenApiResponse(
        statusCode: statusCode,
        description: resp['description'] as String?,
        content: parsedContent,
      );
    });

    return result;
  }

  Map<String, OpenApiResponse> _parseResponsesSwagger2(
    dynamic responses,
    Map<String, dynamic> spec,
  ) {
    if (responses == null) return {};

    final result = <String, OpenApiResponse>{};
    final responsesMap = responses as Map<String, dynamic>;

    responsesMap.forEach((statusCode, response) {
      var resp = response as Map<String, dynamic>;

      // Handle $ref
      if (resp.containsKey('\$ref')) {
        resp = _resolveRef(resp['\$ref'] as String, spec);
      }

      final schema = resp['schema'];
      Map<String, OpenApiMediaType>? parsedContent;

      if (schema != null) {
        parsedContent = {
          'application/json': OpenApiMediaType(
            schema: _parseSchema(schema, spec),
          ),
        };
      }

      result[statusCode] = OpenApiResponse(
        statusCode: statusCode,
        description: resp['description'] as String?,
        content: parsedContent,
      );
    });

    return result;
  }

  OpenApiSchema? _parseSchema(dynamic schema, Map<String, dynamic> spec) {
    if (schema == null) return null;

    var schemaMap = schema as Map<String, dynamic>;

    // Handle $ref
    if (schemaMap.containsKey('\$ref')) {
      schemaMap = _resolveRef(schemaMap['\$ref'] as String, spec);
    }

    // Parse items for arrays
    OpenApiSchema? items;
    if (schemaMap['type'] == 'array' && schemaMap['items'] != null) {
      items = _parseSchema(schemaMap['items'], spec);
    }

    // Parse properties for objects
    Map<String, OpenApiSchema>? properties;
    if (schemaMap['properties'] != null) {
      properties = {};
      final propsMap = schemaMap['properties'] as Map<String, dynamic>;
      propsMap.forEach((propName, propSchema) {
        properties![propName] = _parseSchema(propSchema, spec) ??
            const OpenApiSchema(type: 'string');
      });
    }

    return OpenApiSchema(
      type: schemaMap['type'] as String?,
      format: schemaMap['format'] as String?,
      description: schemaMap['description'] as String?,
      enumValues: (schemaMap['enum'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      items: items,
      properties: properties,
      requiredProperties: (schemaMap['required'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      defaultValue: schemaMap['default'],
      example: schemaMap['example'],
    );
  }

  Map<String, dynamic> _resolveRef(String ref, Map<String, dynamic> spec) {
    // Parse reference path (e.g., "#/components/schemas/Pet")
    final parts = ref.split('/');
    if (parts.isEmpty || parts.first != '#') {
      return {};
    }

    dynamic current = spec;
    for (var i = 1; i < parts.length; i++) {
      if (current is Map<String, dynamic>) {
        current = current[parts[i]];
      } else {
        return {};
      }
    }

    return current is Map<String, dynamic> ? current : {};
  }

  String _extractBaseUrl(String url) {
    final uri = Uri.parse(url);
    // Get the base URL without the path to the spec file
    final pathSegments = uri.pathSegments.toList();
    if (pathSegments.isNotEmpty) {
      pathSegments.removeLast(); // Remove spec file
    }
    return '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}/${pathSegments.join('/')}';
  }
}

/// Exception thrown when OpenAPI parsing fails
class OpenApiParseException implements Exception {
  final String message;
  OpenApiParseException(this.message);

  @override
  String toString() => 'OpenApiParseException: $message';
}
