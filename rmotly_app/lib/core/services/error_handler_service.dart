import 'dart:async';
import 'dart:io';
import '../exceptions.dart';

/// Service for centralizing error handling and mapping exceptions
/// to user-friendly messages.
class ErrorHandlerService {
  /// Maps an exception to a user-friendly error message.
  ///
  /// This method handles different types of exceptions and returns
  /// appropriate messages for display to users.
  String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return _handleAppException(error);
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    if (error is FormatException) {
      return 'Invalid data format received from server.';
    }

    // Generic error message for unknown exceptions
    return 'An unexpected error occurred. Please try again.';
  }

  /// Maps app-specific exceptions to user-friendly messages.
  String _handleAppException(AppException exception) {
    if (exception is NetworkException) {
      return exception.message.isNotEmpty
          ? exception.message
          : 'Network error. Please check your connection.';
    }

    if (exception is ValidationException) {
      // If there are field-specific errors, return the first one
      if (exception.fieldErrors?.isNotEmpty ?? false) {
        final firstError = exception.fieldErrors!.values.first;
        return firstError;
      }
      return exception.message.isNotEmpty
          ? exception.message
          : 'Validation failed. Please check your input.';
    }

    if (exception is AuthException) {
      return exception.message.isNotEmpty
          ? exception.message
          : 'Authentication failed. Please try again.';
    }

    if (exception is ServerException) {
      if (exception.statusCode != null) {
        return 'Server error (${exception.statusCode}). ${exception.message}';
      }
      return exception.message.isNotEmpty
          ? exception.message
          : 'Server error. Please try again later.';
    }

    if (exception is ActionExecutionException) {
      return exception.message.isNotEmpty
          ? exception.message
          : 'Failed to execute action. Please try again.';
    }

    if (exception is OfflineException) {
      return exception.message.isNotEmpty
          ? exception.message
          : 'You are offline. This action will be queued and processed when you\'re back online.';
    }

    // Fallback for other AppExceptions
    return exception.message.isNotEmpty
        ? exception.message
        : 'An error occurred. Please try again.';
  }

  /// Determines if an error is retryable.
  ///
  /// Returns `true` if the operation should be retried, `false` otherwise.
  bool isRetryable(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return true;
    }

    if (error is NetworkException || error is OfflineException) {
      return true;
    }

    if (error is ServerException) {
      final statusCode = error.statusCode;
      return statusCode != null &&
          (statusCode == 408 ||
              statusCode == 429 ||
              statusCode == 500 ||
              statusCode == 502 ||
              statusCode == 503 ||
              statusCode == 504);
    }

    return false;
  }

  /// Maps raw exceptions to typed [AppException]s.
  ///
  /// This helps maintain consistent exception types throughout the app.
  AppException mapToAppException(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException) {
      return NetworkException(
        'No internet connection',
        code: 'SOCKET_ERROR',
        originalError: error,
      );
    }

    if (error is TimeoutException) {
      return NetworkException(
        'Connection timed out',
        code: 'TIMEOUT',
        originalError: error,
      );
    }

    if (error is FormatException) {
      return ServerException(
        'Invalid response from server',
        code: 'FORMAT_ERROR',
        originalError: error,
      );
    }

    // Unknown error
    return ServerException(
      'An unexpected error occurred',
      code: 'UNKNOWN_ERROR',
      originalError: error,
    );
  }
}
