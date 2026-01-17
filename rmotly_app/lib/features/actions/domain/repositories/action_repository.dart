import 'package:rmotly_client/rmotly_client.dart';

/// Repository interface for managing Action entities.
abstract class ActionRepository {
  /// Lists all actions for the current user.
  Future<List<Action>> getActions();

  /// Gets a specific action by ID.
  Future<Action?> getAction(int actionId);

  /// Creates a new action.
  Future<Action> createAction(Action action);

  /// Updates an existing action.
  Future<Action> updateAction(Action action);

  /// Deletes an action by ID.
  Future<bool> deleteAction(int actionId);

  /// Tests an action execution with parameters.
  Future<ActionTestResult> testAction(
      int actionId, Map<String, dynamic> parameters);
}

/// Result of testing an action
class ActionTestResult {
  final bool success;
  final int? statusCode;
  final String? responseBody;
  final Map<String, String>? responseHeaders;
  final int executionTimeMs;
  final String? error;

  const ActionTestResult({
    required this.success,
    this.statusCode,
    this.responseBody,
    this.responseHeaders,
    required this.executionTimeMs,
    this.error,
  });

  factory ActionTestResult.fromJson(Map<String, dynamic> json) {
    return ActionTestResult(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int?,
      responseBody: json['responseBody'] as String?,
      responseHeaders: json['responseHeaders'] != null
          ? Map<String, String>.from(json['responseHeaders'] as Map)
          : null,
      executionTimeMs: json['executionTimeMs'] as int? ?? 0,
      error: json['error'] as String?,
    );
  }
}
