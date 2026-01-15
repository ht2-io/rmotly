import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/action_executor_service.dart';
import '../services/openapi_parser_service.dart';

/// Serverpod endpoint for action management.
///
/// Provides CRUD operations for actions and functionality to test
/// actions and import them from OpenAPI specifications.
class ActionEndpoint extends Endpoint {
  /// Create a new action
  ///
  /// Creates an action owned by the current user.
  /// The action can be triggered by controls or events.
  ///
  /// Returns the created [Action] with generated ID.
  Future<Action> createAction(
    Session session, {
    required String name,
    required String httpMethod,
    required String urlTemplate,
    String? description,
    String? headersTemplate,
    String? bodyTemplate,
    String? parameters,
  }) async {
    // Validate input
    if (name.isEmpty) {
      throw ArgumentError('name cannot be empty');
    }
    if (httpMethod.isEmpty) {
      throw ArgumentError('httpMethod cannot be empty');
    }
    if (urlTemplate.isEmpty) {
      throw ArgumentError('urlTemplate cannot be empty');
    }

    // Validate HTTP method
    final validMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD'];
    if (!validMethods.contains(httpMethod.toUpperCase())) {
      throw ArgumentError(
        'Invalid HTTP method: $httpMethod. Must be one of: ${validMethods.join(', ')}',
      );
    }

    // Get authenticated user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw StateError('User not authenticated');
    }
    final userId = authInfo.userId;

    // Create action
    final now = DateTime.now();
    final action = Action(
      userId: userId,
      name: name,
      httpMethod: httpMethod.toUpperCase(),
      urlTemplate: urlTemplate,
      description: description,
      headersTemplate: headersTemplate,
      bodyTemplate: bodyTemplate,
      parameters: parameters,
      createdAt: now,
      updatedAt: now,
    );

    // Save to database
    final savedAction = await Action.db.insertRow(session, action);

    session.log(
      'Action created: id=${savedAction.id}, name=$name, method=$httpMethod',
      level: LogLevel.info,
    );

    return savedAction;
  }

  /// List all actions for the current user
  ///
  /// Returns a list of actions owned by the authenticated user,
  /// ordered by creation date (newest first).
  Future<List<Action>> listActions(Session session) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw StateError('User not authenticated');
    }
    final userId = authInfo.userId;

    // Query actions for this user
    final actions = await Action.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );

    return actions;
  }

  /// Get a specific action by ID
  ///
  /// Returns the action if it exists and belongs to the current user,
  /// or null if not found.
  Future<Action?> getAction(Session session, int actionId) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw StateError('User not authenticated');
    }
    final userId = authInfo.userId;

    // Find the action
    final action = await Action.db.findById(session, actionId);

    // Verify ownership
    if (action != null && action.userId != userId) {
      session.log(
        'Unauthorized action access attempt: actionId=$actionId, userId=$userId',
        level: LogLevel.warning,
      );
      return null;
    }

    return action;
  }

  /// Update an existing action
  ///
  /// Updates the specified action with the provided fields.
  /// Only fields that are non-null will be updated.
  ///
  /// Returns the updated action, or throws if not found or not authorized.
  Future<Action> updateAction(
    Session session,
    int actionId, {
    String? name,
    String? httpMethod,
    String? urlTemplate,
    String? description,
    String? headersTemplate,
    String? bodyTemplate,
    String? parameters,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw StateError('User not authenticated');
    }
    final userId = authInfo.userId;

    // Find the action
    final action = await Action.db.findById(session, actionId);
    if (action == null) {
      throw ArgumentError('Action not found: $actionId');
    }

    // Verify ownership
    if (action.userId != userId) {
      throw StateError('Not authorized to update this action');
    }

    // Validate HTTP method if provided
    if (httpMethod != null) {
      final validMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD'];
      if (!validMethods.contains(httpMethod.toUpperCase())) {
        throw ArgumentError(
          'Invalid HTTP method: $httpMethod. Must be one of: ${validMethods.join(', ')}',
        );
      }
    }

    // Update fields
    if (name != null && name.isNotEmpty) {
      action.name = name;
    }
    if (httpMethod != null) {
      action.httpMethod = httpMethod.toUpperCase();
    }
    if (urlTemplate != null && urlTemplate.isNotEmpty) {
      action.urlTemplate = urlTemplate;
    }
    if (description != null) {
      action.description = description;
    }
    if (headersTemplate != null) {
      action.headersTemplate = headersTemplate;
    }
    if (bodyTemplate != null) {
      action.bodyTemplate = bodyTemplate;
    }
    if (parameters != null) {
      action.parameters = parameters;
    }

    // Update timestamp
    action.updatedAt = DateTime.now();

    // Save to database
    final updatedAction = await Action.db.updateRow(session, action);

    session.log(
      'Action updated: id=$actionId, userId=$userId',
      level: LogLevel.info,
    );

    return updatedAction;
  }

  /// Delete an action
  ///
  /// Deletes the specified action if it belongs to the current user.
  ///
  /// Returns true if deleted successfully, false if not found or not authorized.
  Future<bool> deleteAction(Session session, int actionId) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw StateError('User not authenticated');
    }
    final userId = authInfo.userId;

    // Find the action
    final action = await Action.db.findById(session, actionId);
    if (action == null) {
      return false;
    }

    // Verify ownership
    if (action.userId != userId) {
      session.log(
        'Unauthorized action deletion attempt: actionId=$actionId, userId=$userId',
        level: LogLevel.warning,
      );
      return false;
    }

    // Delete the action
    await Action.db.deleteRow(session, action);

    session.log(
      'Action deleted: id=$actionId, userId=$userId',
      level: LogLevel.info,
    );

    return true;
  }

  /// Test action execution
  ///
  /// Executes the action with the provided parameters and returns
  /// detailed test results including the resolved URL, headers, body,
  /// and the actual HTTP response.
  ///
  /// This does not save the execution result, it's purely for testing.
  Future<ActionTestResult> testAction(
    Session session,
    int actionId, {
    String? parameters,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw StateError('User not authenticated');
    }
    final userId = authInfo.userId;

    // Find the action
    final action = await Action.db.findById(session, actionId);
    if (action == null) {
      throw ArgumentError('Action not found: $actionId');
    }

    // Verify ownership
    if (action.userId != userId) {
      throw StateError('Not authorized to test this action');
    }

    // Parse parameters
    Map<String, dynamic> parsedParams = {};
    if (parameters != null && parameters.isNotEmpty) {
      try {
        parsedParams = jsonDecode(parameters) as Map<String, dynamic>;
      } catch (e) {
        throw ArgumentError('Invalid JSON parameters: $e');
      }
    }

    // Create action config
    final config = ActionConfig(
      httpMethod: action.httpMethod,
      urlTemplate: action.urlTemplate,
      headersTemplate: action.headersTemplate,
      bodyTemplate: action.bodyTemplate,
    );

    // Get the executor service
    final executor = ActionExecutorService();

    try {
      // First, get the resolved templates without executing
      final substitution = executor.testSubstitution(config, parsedParams);

      // Then execute the action
      final result = await executor.execute(
        config,
        parsedParams,
        session: session,
      );

      session.log(
        'Action tested: id=$actionId, success=${result.success}',
        level: LogLevel.info,
      );

      // Build test result
      return ActionTestResult(
        success: result.success,
        error: result.error,
        statusCode: result.statusCode,
        responseBody: result.responseBody,
        responseHeaders: result.responseHeaders != null
            ? jsonEncode(result.responseHeaders)
            : null,
        executionTimeMs: result.executionTimeMs,
        resolvedUrl: substitution['url'] as String?,
        resolvedHeaders: substitution['headers'] != null
            ? jsonEncode(substitution['headers'])
            : null,
        resolvedBody: substitution['body'] as String?,
      );
    } finally {
      executor.close();
    }
  }

  /// Create action from OpenAPI operation
  ///
  /// Fetches an OpenAPI specification from the given URL,
  /// finds the specified operation, and creates an action from it.
  ///
  /// The action will be pre-configured with the correct HTTP method,
  /// URL template with parameter placeholders, headers, and body template.
  ///
  /// Returns the created [Action].
  Future<Action> createFromOpenApi(
    Session session, {
    required String specUrl,
    required String operationId,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw StateError('User not authenticated');
    }
    final userId = authInfo.userId;

    // Validate input
    if (specUrl.isEmpty) {
      throw ArgumentError('specUrl cannot be empty');
    }
    if (operationId.isEmpty) {
      throw ArgumentError('operationId cannot be empty');
    }

    // Parse the OpenAPI spec
    final parser = OpenApiParserService();
    try {
      final spec = await parser.parseFromUrl(specUrl);

      // Find the operation
      final operation = parser.findOperation(spec, operationId);
      if (operation == null) {
        throw ArgumentError(
          'Operation not found: $operationId in spec: $specUrl',
        );
      }

      // Generate action template
      final template = parser.generateActionTemplate(operation, spec.baseUrl);

      // Create the action
      final now = DateTime.now();
      final action = Action(
        userId: userId,
        name: template['name'] as String,
        description: template['description'] as String?,
        httpMethod: template['httpMethod'] as String,
        urlTemplate: template['urlTemplate'] as String,
        headersTemplate: template['headersTemplate'] as String?,
        bodyTemplate: template['bodyTemplate'] as String?,
        parameters: template['parameters'] as String?,
        openApiSpecUrl: specUrl,
        openApiOperationId: operationId,
        createdAt: now,
        updatedAt: now,
      );

      // Save to database
      final savedAction = await Action.db.insertRow(session, action);

      session.log(
        'Action created from OpenAPI: id=${savedAction.id}, '
        'operationId=$operationId, specUrl=$specUrl',
        level: LogLevel.info,
      );

      return savedAction;
    } finally {
      parser.close();
    }
  }
}
