import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:rmotly_server/src/generated/protocol.dart';
import '../services/action_executor_service.dart';

/// Serverpod endpoint for managing actions (HTTP request templates).
///
/// Provides methods to create, read, update, delete, and test actions
/// that can be triggered by controls or other events.
class ActionEndpoint extends Endpoint {
  late final ActionExecutorService _actionExecutor;

  @override
  Future<void> initialize(
    Server server,
    String name,
    String? defaultRoutePrefix,
  ) async {
    await super.initialize(server, name, defaultRoutePrefix);
    _actionExecutor = ActionExecutorService();
  }

  /// Create a new action
  ///
  /// Creates an HTTP action template that can be triggered by controls.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [userId]: ID of the user creating the action
  /// - [name]: Display name for the action
  /// - [httpMethod]: HTTP method (GET, POST, PUT, DELETE, PATCH)
  /// - [urlTemplate]: URL template with {{variable}} placeholders
  /// - [description]: Optional description of what the action does
  /// - [headersTemplate]: Optional headers template as JSON string
  /// - [bodyTemplate]: Optional body template with {{variable}} placeholders
  /// - [parameters]: Optional parameters definition as JSON string
  ///
  /// Returns: The created [Action] with generated ID
  ///
  /// Throws: [ArgumentError] if validation fails
  Future<Action> createAction(
    Session session, {
    required int userId,
    required String name,
    required String httpMethod,
    required String urlTemplate,
    String? description,
    String? headersTemplate,
    String? bodyTemplate,
    String? parameters,
  }) async {
    // Validate input
    if (name.trim().isEmpty) {
      throw ArgumentError('name cannot be empty');
    }

    if (urlTemplate.trim().isEmpty) {
      throw ArgumentError('urlTemplate cannot be empty');
    }

    // Validate HTTP method
    const allowedMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD'];
    final upperMethod = httpMethod.toUpperCase();
    if (!allowedMethods.contains(upperMethod)) {
      throw ArgumentError(
        'httpMethod must be one of: ${allowedMethods.join(', ')}',
      );
    }

    // Validate URL template can be parsed
    try {
      // Test with empty variables to validate template structure
      final testUrl = urlTemplate.replaceAll(RegExp(r'\{\{[^}]+\}\}'), 'test');
      Uri.parse(testUrl);
    } catch (e) {
      throw ArgumentError('Invalid URL template: $e');
    }

    // Validate headers template if provided
    if (headersTemplate != null && headersTemplate.isNotEmpty) {
      try {
        jsonDecode(headersTemplate);
      } catch (e) {
        throw ArgumentError('headersTemplate must be valid JSON: $e');
      }
    }

    // Validate parameters if provided
    if (parameters != null && parameters.isNotEmpty) {
      try {
        jsonDecode(parameters);
      } catch (e) {
        throw ArgumentError('parameters must be valid JSON: $e');
      }
    }

    // Create the action
    final now = DateTime.now();
    final action = Action(
      userId: userId,
      name: name,
      description: description,
      httpMethod: upperMethod,
      urlTemplate: urlTemplate,
      headersTemplate: headersTemplate,
      bodyTemplate: bodyTemplate,
      parameters: parameters,
      createdAt: now,
      updatedAt: now,
    );

    final savedAction = await Action.db.insertRow(session, action);

    session.log(
      'Action created: ${savedAction.id} - $name ($upperMethod)',
      level: LogLevel.info,
    );

    return savedAction;
  }

  /// List all actions for a user
  ///
  /// Returns actions ordered by creation date (newest first).
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [userId]: ID of the user whose actions to list
  ///
  /// Returns: List of [Action] ordered by creation date
  Future<List<Action>> listActions(
    Session session, {
    required int userId,
  }) async {
    final actions = await Action.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );

    session.log(
      'Listed ${actions.length} actions for user $userId',
      level: LogLevel.debug,
    );

    return actions;
  }

  /// Get a single action by ID
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [actionId]: ID of the action to retrieve
  ///
  /// Returns: The [Action] or null if not found
  Future<Action?> getAction(
    Session session, {
    required int actionId,
  }) async {
    final action = await Action.db.findById(session, actionId);

    if (action != null) {
      session.log(
        'Retrieved action: ${action.id} - ${action.name}',
        level: LogLevel.debug,
      );
    } else {
      session.log(
        'Action not found: $actionId',
        level: LogLevel.warning,
      );
    }

    return action;
  }

  /// Update an action
  ///
  /// Updates the specified fields of an action. All fields are optional
  /// except actionId. Only provided fields will be updated.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [actionId]: ID of the action to update
  /// - [name]: New display name (optional)
  /// - [description]: New description (optional)
  /// - [httpMethod]: New HTTP method (optional)
  /// - [urlTemplate]: New URL template (optional)
  /// - [headersTemplate]: New headers template (optional)
  /// - [bodyTemplate]: New body template (optional)
  /// - [parameters]: New parameters definition (optional)
  ///
  /// Returns: The updated [Action]
  ///
  /// Throws: [ArgumentError] if action not found or validation fails
  Future<Action> updateAction(
    Session session, {
    required int actionId,
    String? name,
    String? description,
    String? httpMethod,
    String? urlTemplate,
    String? headersTemplate,
    String? bodyTemplate,
    String? parameters,
    bool clearDescription = false,
    bool clearHeadersTemplate = false,
    bool clearBodyTemplate = false,
    bool clearParameters = false,
  }) async {
    // Fetch existing action
    final action = await Action.db.findById(session, actionId);
    if (action == null) {
      throw ArgumentError('Action with ID $actionId not found');
    }

    // Update fields if provided
    if (name != null) {
      if (name.trim().isEmpty) {
        throw ArgumentError('name cannot be empty');
      }
      action.name = name;
    }

    if (description != null) {
      action.description = description;
    } else if (clearDescription) {
      action.description = null;
    }

    if (httpMethod != null) {
      const allowedMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD'];
      final upperMethod = httpMethod.toUpperCase();
      if (!allowedMethods.contains(upperMethod)) {
        throw ArgumentError(
          'httpMethod must be one of: ${allowedMethods.join(', ')}',
        );
      }
      action.httpMethod = upperMethod;
    }

    if (urlTemplate != null) {
      if (urlTemplate.trim().isEmpty) {
        throw ArgumentError('urlTemplate cannot be empty');
      }
      // Validate URL template
      try {
        final testUrl = urlTemplate.replaceAll(RegExp(r'\{\{[^}]+\}\}'), 'test');
        Uri.parse(testUrl);
      } catch (e) {
        throw ArgumentError('Invalid URL template: $e');
      }
      action.urlTemplate = urlTemplate;
    }

    if (headersTemplate != null) {
      try {
        jsonDecode(headersTemplate);
      } catch (e) {
        throw ArgumentError('headersTemplate must be valid JSON: $e');
      }
      action.headersTemplate = headersTemplate;
    } else if (clearHeadersTemplate) {
      action.headersTemplate = null;
    }

    if (bodyTemplate != null) {
      action.bodyTemplate = bodyTemplate;
    } else if (clearBodyTemplate) {
      action.bodyTemplate = null;
    }

    if (parameters != null) {
      try {
        jsonDecode(parameters);
      } catch (e) {
        throw ArgumentError('parameters must be valid JSON: $e');
      }
      action.parameters = parameters;
    } else if (clearParameters) {
      action.parameters = null;
    }

    // Update timestamp
    action.updatedAt = DateTime.now();

    final updatedAction = await Action.db.updateRow(session, action);

    session.log(
      'Action updated: ${updatedAction.id} - ${updatedAction.name}',
      level: LogLevel.info,
    );

    return updatedAction;
  }

  /// Delete an action
  ///
  /// Permanently deletes an action from the database.
  /// Note: This will leave any associated controls without an action.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [actionId]: ID of the action to delete
  ///
  /// Returns: true if deleted, false if not found
  Future<bool> deleteAction(
    Session session, {
    required int actionId,
  }) async {
    final action = await Action.db.findById(session, actionId);
    if (action == null) {
      session.log(
        'Cannot delete - action not found: $actionId',
        level: LogLevel.warning,
      );
      return false;
    }

    await Action.db.deleteRow(session, action);

    session.log(
      'Action deleted: $actionId - ${action.name}',
      level: LogLevel.info,
    );

    return true;
  }

  /// Test an action with provided parameters
  ///
  /// Executes the action with test parameters to verify it works correctly.
  /// This performs the actual HTTP request.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [actionId]: ID of the action to test
  /// - [testParameters]: Parameters to use for template substitution
  ///
  /// Returns: Map containing execution result with keys:
  ///   - success: bool
  ///   - statusCode: int?
  ///   - responseBody: String?
  ///   - responseHeaders: Map<String, String>?
  ///   - executionTimeMs: int
  ///   - error: String? (if failed)
  ///
  /// Throws: [ArgumentError] if action not found
  Future<Map<String, dynamic>> testAction(
    Session session, {
    required int actionId,
    required Map<String, dynamic> testParameters,
  }) async {
    final action = await Action.db.findById(session, actionId);
    if (action == null) {
      throw ArgumentError('Action with ID $actionId not found');
    }

    session.log(
      'Testing action: ${action.id} - ${action.name}',
      level: LogLevel.info,
    );

    // Create ActionConfig from action
    final config = ActionConfig(
      httpMethod: action.httpMethod,
      urlTemplate: action.urlTemplate,
      headersTemplate: action.headersTemplate,
      bodyTemplate: action.bodyTemplate,
    );

    // Execute the action
    final result = await _actionExecutor.execute(
      config,
      testParameters,
      session: session,
    );

    session.log(
      'Action test completed: ${action.id} - success: ${result.success}',
      level: result.success ? LogLevel.info : LogLevel.warning,
    );

    return result.toJson();
  }
}
