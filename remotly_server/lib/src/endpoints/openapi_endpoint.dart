import 'package:serverpod/serverpod.dart';

import '../services/openapi_parser_service.dart';
import 'package:remotly_server/src/generated/protocol.dart' as protocol;

/// Serverpod endpoint for OpenAPI specification parsing.
///
/// Provides methods to parse OpenAPI specifications from URLs
/// and extract operation information.
class OpenApiEndpoint extends Endpoint {
  /// Parse OpenAPI spec from URL
  ///
  /// Fetches and parses an OpenAPI specification from the provided URL.
  /// Supports OpenAPI 3.0, 3.1, and Swagger 2.0 in JSON format.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [url]: The URL of the OpenAPI specification (JSON format)
  ///
  /// Returns: [protocol.OpenApiSpec] containing the parsed specification
  ///
  /// Throws: [OpenApiParseException] if parsing fails
  Future<protocol.OpenApiSpec> parseSpec(Session session, String url) async {
    final parserService = OpenApiParserService();
    try {
      final serviceSpec = await parserService.parseFromUrl(url);
      return _convertSpec(serviceSpec);
    } catch (e) {
      session.log('Failed to parse OpenAPI spec from $url: $e', level: LogLevel.warning);
      rethrow;
    } finally {
      parserService.close();
    }
  }

  /// List operations from spec
  ///
  /// Fetches an OpenAPI specification from the URL and returns
  /// all operations (endpoints) defined in the specification.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [specUrl]: The URL of the OpenAPI specification
  ///
  /// Returns: List of [protocol.OpenApiOperation] containing all operations
  ///
  /// Throws: [OpenApiParseException] if parsing fails
  Future<List<protocol.OpenApiOperation>> listOperations(
    Session session,
    String specUrl,
  ) async {
    final parserService = OpenApiParserService();
    try {
      final serviceSpec = await parserService.parseFromUrl(specUrl);
      return serviceSpec.operations.map(_convertOperation).toList();
    } catch (e) {
      session.log('Failed to list operations from $specUrl: $e', level: LogLevel.warning);
      rethrow;
    } finally {
      parserService.close();
    }
  }

  /// Convert service OpenApiSpec to protocol OpenApiSpec
  protocol.OpenApiSpec _convertSpec(OpenApiSpec serviceSpec) {
    return protocol.OpenApiSpec(
      title: serviceSpec.title,
      version: serviceSpec.version,
      description: serviceSpec.description,
      baseUrl: serviceSpec.baseUrl,
      specVersion: serviceSpec.specVersion,
      operations: serviceSpec.operations.map(_convertOperation).toList(),
    );
  }

  /// Convert service OpenApiOperation to protocol OpenApiOperation
  protocol.OpenApiOperation _convertOperation(OpenApiOperation serviceOp) {
    return protocol.OpenApiOperation(
      operationId: serviceOp.operationId,
      method: serviceOp.method,
      path: serviceOp.path,
      summary: serviceOp.summary,
      description: serviceOp.description,
      parameters: serviceOp.parameters.map(_convertParameter).toList(),
      tags: serviceOp.tags,
    );
  }

  /// Convert service OpenApiParameter to protocol OpenApiParameter
  protocol.OpenApiParameter _convertParameter(OpenApiParameter serviceParam) {
    return protocol.OpenApiParameter(
      name: serviceParam.name,
      location: serviceParam.location,
      description: serviceParam.description,
      required: serviceParam.required,
      type: serviceParam.type,
      format: serviceParam.format,
    );
  }
}
