import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rmotly_app/core/exceptions.dart';
import 'package:rmotly_app/core/services/error_handler_service.dart';

void main() {
  late ErrorHandlerService errorHandler;

  setUp(() {
    errorHandler = ErrorHandlerService();
  });

  group('ErrorHandlerService - getErrorMessage', () {
    test('returns user-friendly message for NetworkException', () {
      const exception = NetworkException('Connection failed');
      final message = errorHandler.getErrorMessage(exception);
      expect(message, 'Connection failed');
    });

    test('returns user-friendly message for ValidationException', () {
      const exception = ValidationException('Invalid input');
      final message = errorHandler.getErrorMessage(exception);
      expect(message, 'Invalid input');
    });

    test('returns first field error for ValidationException with field errors', () {
      const exception = ValidationException(
        'Validation failed',
        fieldErrors: {'email': 'Invalid email format'},
      );
      final message = errorHandler.getErrorMessage(exception);
      expect(message, 'Invalid email format');
    });

    test('returns user-friendly message for SocketException', () {
      final exception = SocketException('Connection refused');
      final message = errorHandler.getErrorMessage(exception);
      expect(message, 'No internet connection. Please check your network.');
    });

    test('returns generic message for unknown exception', () {
      final exception = Exception('Unknown error');
      final message = errorHandler.getErrorMessage(exception);
      expect(message, 'An unexpected error occurred. Please try again.');
    });
  });

  group('ErrorHandlerService - isRetryable', () {
    test('returns true for NetworkException', () {
      const exception = NetworkException('Connection failed');
      expect(errorHandler.isRetryable(exception), isTrue);
    });

    test('returns true for OfflineException', () {
      const exception = OfflineException('Device is offline');
      expect(errorHandler.isRetryable(exception), isTrue);
    });

    test('returns true for SocketException', () {
      final exception = SocketException('Connection refused');
      expect(errorHandler.isRetryable(exception), isTrue);
    });

    test('returns false for ValidationException', () {
      const exception = ValidationException('Invalid input');
      expect(errorHandler.isRetryable(exception), isFalse);
    });

    test('returns false for AuthException', () {
      const exception = AuthException('Unauthorized');
      expect(errorHandler.isRetryable(exception), isFalse);
    });
  });

  group('ErrorHandlerService - mapToAppException', () {
    test('returns same exception if already AppException', () {
      const exception = NetworkException('Connection failed');
      final mapped = errorHandler.mapToAppException(exception);
      expect(mapped, same(exception));
    });

    test('maps SocketException to NetworkException', () {
      final exception = SocketException('Connection refused');
      final mapped = errorHandler.mapToAppException(exception);
      expect(mapped, isA<NetworkException>());
      expect(mapped.message, 'No internet connection');
    });

    test('maps unknown exception to ServerException', () {
      final exception = Exception('Unknown error');
      final mapped = errorHandler.mapToAppException(exception);
      expect(mapped, isA<ServerException>());
      expect(mapped.message, 'An unexpected error occurred');
    });
  });
}
