/// Custom exception classes for the Remotly app.
///
/// This library defines all custom exception types used throughout the application.
/// All exceptions extend [AppException] for consistent error handling.
library;

/// Base exception class for all application exceptions.
///
/// All custom exceptions in the app should extend this class.
/// It provides common properties like [message], [code], and [originalError]
/// for consistent error handling throughout the application.
abstract class AppException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Optional error code for categorizing errors.
  final String? code;

  /// The original error that caused this exception, if any.
  final dynamic originalError;

  /// Creates an [AppException] with the given [message].
  ///
  /// Optionally accepts an error [code] and [originalError] for debugging.
  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

/// Exception thrown when a network operation fails.
///
/// This includes HTTP errors, connection timeouts, and other
/// network-related failures.
class NetworkException extends AppException {
  /// Creates a [NetworkException] with the given [message].
  const NetworkException(super.message, {super.code, super.originalError});
}

/// Exception thrown when validation fails.
///
/// Can include field-specific errors in the [fieldErrors] map.
class ValidationException extends AppException {
  /// Map of field names to their validation error messages.
  final Map<String, String>? fieldErrors;

  /// Creates a [ValidationException] with the given [message].
  ///
  /// Optionally includes [fieldErrors] for form validation scenarios.
  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
  });

  @override
  String toString() {
    final buffer = StringBuffer(super.toString());
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      buffer.write('\nField errors:');
      fieldErrors!.forEach((field, error) {
        buffer.write('\n  $field: $error');
      });
    }
    return buffer.toString();
  }
}

/// Exception thrown when authentication or authorization fails.
///
/// This includes login failures, token expiration, insufficient permissions, etc.
class AuthException extends AppException {
  /// Creates an [AuthException] with the given [message].
  const AuthException(super.message, {super.code, super.originalError});
}

/// Exception thrown when an action execution fails.
///
/// This occurs when HTTP requests configured in actions fail,
/// or when action templates cannot be processed.
class ActionExecutionException extends AppException {
  /// The ID of the action that failed.
  final String? actionId;

  /// The HTTP status code of the failed request, if applicable.
  final int? statusCode;

  /// The response body of the failed request, if applicable.
  final String? responseBody;

  /// Creates an [ActionExecutionException] with the given [message].
  ///
  /// Optionally includes [actionId], [statusCode], and [responseBody]
  /// for detailed error reporting.
  const ActionExecutionException(
    super.message, {
    this.actionId,
    this.statusCode,
    this.responseBody,
    super.code,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer(super.toString());
    if (actionId != null) {
      buffer.write('\nAction ID: $actionId');
    }
    if (statusCode != null) {
      buffer.write('\nStatus Code: $statusCode');
    }
    if (responseBody != null) {
      buffer.write('\nResponse: $responseBody');
    }
    return buffer.toString();
  }
}
