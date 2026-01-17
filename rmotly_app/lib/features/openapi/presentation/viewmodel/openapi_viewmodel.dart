import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/openapi_models.dart';
import '../../domain/services/openapi_parser_service.dart';
import '../state/openapi_state.dart';

/// ViewModel for OpenAPI import functionality
class OpenApiViewModel extends StateNotifier<OpenApiState> {
  final OpenApiParserService _parserService;

  OpenApiViewModel(this._parserService) : super(const OpenApiState());

  /// Load and parse an OpenAPI spec from URL
  Future<void> loadSpec(String url) async {
    if (url.isEmpty) {
      state = state.copyWith(error: 'Please enter a URL');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSpec: true,
      clearSelectedOperation: true,
      specUrl: url,
    );

    try {
      final spec = await _parserService.parseFromUrl(url);
      state = state.copyWith(
        isLoading: false,
        spec: spec,
      );
    } on OpenApiParseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load OpenAPI spec: $e',
      );
    }
  }

  /// Load and parse an OpenAPI spec from JSON content
  Future<void> loadSpecFromJson(String jsonContent) async {
    if (jsonContent.isEmpty) {
      state = state.copyWith(error: 'Please provide spec content');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSpec: true,
      clearSelectedOperation: true,
    );

    try {
      final spec = await _parserService.parseFromJson(jsonContent);
      state = state.copyWith(
        isLoading: false,
        spec: spec,
      );
    } on OpenApiParseException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to parse OpenAPI spec: $e',
      );
    }
  }

  /// Select an operation for import
  void selectOperation(OpenApiOperation operation) {
    // Generate default action name
    final actionName = _generateActionName(operation);

    // Initialize parameter values with defaults
    final parameterValues = <String, String>{};
    for (final param in operation.parameters) {
      if (param.defaultValue != null) {
        parameterValues[param.name] = param.defaultValue.toString();
      } else if (param.example != null) {
        parameterValues[param.name] = param.example.toString();
      }
    }

    state = state.copyWith(
      selectedOperation: operation,
      generatedActionName: actionName,
      parameterValues: parameterValues,
    );
  }

  /// Deselect the current operation
  void deselectOperation() {
    state = state.copyWith(
      clearSelectedOperation: true,
      parameterValues: {},
      generatedActionName: null,
    );
  }

  /// Update action name
  void setActionName(String name) {
    state = state.copyWith(generatedActionName: name);
  }

  /// Update a parameter value
  void setParameterValue(String paramName, String value) {
    final values = Map<String, String>.from(state.parameterValues);
    values[paramName] = value;
    state = state.copyWith(parameterValues: values);
  }

  /// Clear the loaded spec
  void clearSpec() {
    state = const OpenApiState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Generate action configuration from selected operation
  ActionConfig? generateActionConfig() {
    final operation = state.selectedOperation;
    final spec = state.spec;

    if (operation == null || spec == null) return null;

    // Build URL template
    final baseUrl = spec.effectiveBaseUrl ?? '';
    var urlTemplate = '$baseUrl${operation.path}';

    // Replace path parameters with template variables
    for (final param in operation.pathParameters) {
      urlTemplate = urlTemplate.replaceAll(
        '{${param.name}}',
        '{{${param.name}}}',
      );
    }

    // Build query parameters
    final queryParams = operation.queryParameters;
    if (queryParams.isNotEmpty) {
      final queryParts = queryParams.map((p) => '${p.name}={{${p.name}}}');
      urlTemplate = '$urlTemplate?${queryParts.join('&')}';
    }

    // Build headers template
    final headers = <String, String>{};
    for (final param in operation.headerParameters) {
      headers[param.name] = '{{${param.name}}}';
    }
    if (operation.requestBody?.expectsJson == true) {
      headers['Content-Type'] = 'application/json';
    }

    // Build parameters list
    final parameters = operation.parameters.map((p) {
      return ActionParameter(
        name: p.name,
        type: p.typeString,
        required: p.required,
        description: p.description,
        defaultValue: p.defaultValue?.toString() ?? state.parameterValues[p.name],
      );
    }).toList();

    return ActionConfig(
      name: state.generatedActionName ?? operation.displayName,
      description: operation.description ?? operation.summary,
      httpMethod: operation.method,
      urlTemplate: urlTemplate,
      headersTemplate: headers.isNotEmpty ? headers : null,
      bodyTemplate: operation.requestBody != null ? '{{body}}' : null,
      parameters: parameters,
      openApiSpecUrl: state.specUrl,
      openApiOperationId: operation.operationId,
    );
  }

  String _generateActionName(OpenApiOperation operation) {
    // Use summary if available, otherwise format operationId
    if (operation.summary != null && operation.summary!.isNotEmpty) {
      return operation.summary!;
    }

    // Format operationId: convert camelCase/snake_case to readable text
    final name = operation.operationId
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    // Capitalize first letter
    return name.isNotEmpty
        ? '${name[0].toUpperCase()}${name.substring(1)}'
        : operation.operationId;
  }
}

/// Configuration for creating an action from OpenAPI
class ActionConfig {
  final String name;
  final String? description;
  final String httpMethod;
  final String urlTemplate;
  final Map<String, String>? headersTemplate;
  final String? bodyTemplate;
  final List<ActionParameter> parameters;
  final String? openApiSpecUrl;
  final String? openApiOperationId;

  const ActionConfig({
    required this.name,
    this.description,
    required this.httpMethod,
    required this.urlTemplate,
    this.headersTemplate,
    this.bodyTemplate,
    required this.parameters,
    this.openApiSpecUrl,
    this.openApiOperationId,
  });
}

/// Parameter configuration for an action
class ActionParameter {
  final String name;
  final String type;
  final bool required;
  final String? description;
  final String? defaultValue;

  const ActionParameter({
    required this.name,
    required this.type,
    required this.required,
    this.description,
    this.defaultValue,
  });
}
