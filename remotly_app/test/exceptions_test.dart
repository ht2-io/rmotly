import 'package:flutter_test/flutter_test.dart';
import 'package:remotly_app/core/exceptions.dart';

void main() {
  group('AppException', () {
    test('toString includes message', () {
      // Arrange
      final exception = NetworkException('Connection failed');

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('Connection failed'));
      expect(result, contains('NetworkException'));
    });

    test('toString includes code when provided', () {
      // Arrange
      final exception = NetworkException(
        'Connection failed',
        code: 'NET_001',
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('code: NET_001'));
    });

    test('toString includes original error when provided', () {
      // Arrange
      final originalError = Exception('Socket error');
      final exception = NetworkException(
        'Connection failed',
        originalError: originalError,
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('Original error:'));
      expect(result, contains('Socket error'));
    });

    test('can be caught as Exception', () {
      // Arrange
      final exception = NetworkException('Test');

      // Act & Assert
      expect(exception, isA<Exception>());
    });

    test('can be caught as AppException', () {
      // Arrange
      final exception = NetworkException('Test');

      // Act & Assert
      expect(exception, isA<AppException>());
    });
  });

  group('NetworkException', () {
    test('creates exception with message', () {
      // Arrange & Act
      final exception = NetworkException('Network error');

      // Assert
      expect(exception.message, 'Network error');
      expect(exception.code, isNull);
      expect(exception.originalError, isNull);
    });

    test('creates exception with all parameters', () {
      // Arrange
      final originalError = Exception('Timeout');

      // Act
      final exception = NetworkException(
        'Request timeout',
        code: 'TIMEOUT',
        originalError: originalError,
      );

      // Assert
      expect(exception.message, 'Request timeout');
      expect(exception.code, 'TIMEOUT');
      expect(exception.originalError, originalError);
    });

    test('is a subtype of AppException', () {
      // Arrange & Act
      final exception = NetworkException('Test');

      // Assert
      expect(exception, isA<AppException>());
    });
  });

  group('ValidationException', () {
    test('creates exception with message only', () {
      // Arrange & Act
      final exception = ValidationException('Validation failed');

      // Assert
      expect(exception.message, 'Validation failed');
      expect(exception.fieldErrors, isNull);
      expect(exception.code, isNull);
    });

    test('creates exception with field errors', () {
      // Arrange
      final fieldErrors = {
        'email': 'Invalid email format',
        'password': 'Password too short',
      };

      // Act
      final exception = ValidationException(
        'Form validation failed',
        fieldErrors: fieldErrors,
      );

      // Assert
      expect(exception.message, 'Form validation failed');
      expect(exception.fieldErrors, fieldErrors);
      expect(exception.fieldErrors!['email'], 'Invalid email format');
      expect(exception.fieldErrors!['password'], 'Password too short');
    });

    test('toString includes field errors', () {
      // Arrange
      final exception = ValidationException(
        'Validation failed',
        fieldErrors: {
          'email': 'Required field',
          'name': 'Too long',
        },
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('Field errors:'));
      expect(result, contains('email: Required field'));
      expect(result, contains('name: Too long'));
    });

    test('toString handles empty field errors', () {
      // Arrange
      final exception = ValidationException(
        'Validation failed',
        fieldErrors: {},
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('Validation failed'));
      expect(result, isNot(contains('Field errors:')));
    });

    test('toString handles null field errors', () {
      // Arrange
      final exception = ValidationException('Validation failed');

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('Validation failed'));
      expect(result, isNot(contains('Field errors:')));
    });

    test('is a subtype of AppException', () {
      // Arrange & Act
      final exception = ValidationException('Test');

      // Assert
      expect(exception, isA<AppException>());
    });
  });

  group('AuthException', () {
    test('creates exception with message', () {
      // Arrange & Act
      final exception = AuthException('Authentication failed');

      // Assert
      expect(exception.message, 'Authentication failed');
      expect(exception.code, isNull);
      expect(exception.originalError, isNull);
    });

    test('creates exception with all parameters', () {
      // Arrange
      final originalError = Exception('Token expired');

      // Act
      final exception = AuthException(
        'Session expired',
        code: 'AUTH_EXPIRED',
        originalError: originalError,
      );

      // Assert
      expect(exception.message, 'Session expired');
      expect(exception.code, 'AUTH_EXPIRED');
      expect(exception.originalError, originalError);
    });

    test('is a subtype of AppException', () {
      // Arrange & Act
      final exception = AuthException('Test');

      // Assert
      expect(exception, isA<AppException>());
    });
  });

  group('ActionExecutionException', () {
    test('creates exception with message only', () {
      // Arrange & Act
      final exception = ActionExecutionException('Action failed');

      // Assert
      expect(exception.message, 'Action failed');
      expect(exception.actionId, isNull);
      expect(exception.statusCode, isNull);
      expect(exception.responseBody, isNull);
      expect(exception.code, isNull);
      expect(exception.originalError, isNull);
    });

    test('creates exception with all parameters', () {
      // Arrange
      final originalError = Exception('HTTP error');

      // Act
      final exception = ActionExecutionException(
        'HTTP request failed',
        actionId: 'action_123',
        statusCode: 500,
        responseBody: '{"error": "Internal Server Error"}',
        code: 'HTTP_500',
        originalError: originalError,
      );

      // Assert
      expect(exception.message, 'HTTP request failed');
      expect(exception.actionId, 'action_123');
      expect(exception.statusCode, 500);
      expect(exception.responseBody, '{"error": "Internal Server Error"}');
      expect(exception.code, 'HTTP_500');
      expect(exception.originalError, originalError);
    });

    test('toString includes action ID when provided', () {
      // Arrange
      final exception = ActionExecutionException(
        'Action failed',
        actionId: 'action_456',
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('Action ID: action_456'));
    });

    test('toString includes status code when provided', () {
      // Arrange
      final exception = ActionExecutionException(
        'Action failed',
        statusCode: 404,
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('Status Code: 404'));
    });

    test('toString includes response body when provided', () {
      // Arrange
      final exception = ActionExecutionException(
        'Action failed',
        responseBody: 'Not found',
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('Response: Not found'));
    });

    test('toString includes all action details when provided', () {
      // Arrange
      final exception = ActionExecutionException(
        'Action failed',
        actionId: 'action_789',
        statusCode: 403,
        responseBody: 'Forbidden',
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('Action ID: action_789'));
      expect(result, contains('Status Code: 403'));
      expect(result, contains('Response: Forbidden'));
    });

    test('is a subtype of AppException', () {
      // Arrange & Act
      final exception = ActionExecutionException('Test');

      // Assert
      expect(exception, isA<AppException>());
    });
  });

  group('Exception inheritance', () {
    test('all custom exceptions extend AppException', () {
      // Arrange & Act
      final network = NetworkException('Test');
      final validation = ValidationException('Test');
      final auth = AuthException('Test');
      final action = ActionExecutionException('Test');

      // Assert
      expect(network, isA<AppException>());
      expect(validation, isA<AppException>());
      expect(auth, isA<AppException>());
      expect(action, isA<AppException>());
    });

    test('all custom exceptions implement Exception', () {
      // Arrange & Act
      final network = NetworkException('Test');
      final validation = ValidationException('Test');
      final auth = AuthException('Test');
      final action = ActionExecutionException('Test');

      // Assert
      expect(network, isA<Exception>());
      expect(validation, isA<Exception>());
      expect(auth, isA<Exception>());
      expect(action, isA<Exception>());
    });

    test('exceptions can be differentiated by type', () {
      // Arrange
      final exceptions = <AppException>[
        NetworkException('Network'),
        ValidationException('Validation'),
        AuthException('Auth'),
        ActionExecutionException('Action'),
      ];

      // Act & Assert
      expect(exceptions[0], isA<NetworkException>());
      expect(exceptions[1], isA<ValidationException>());
      expect(exceptions[2], isA<AuthException>());
      expect(exceptions[3], isA<ActionExecutionException>());
    });
  });

  group('Exception usage patterns', () {
    test('can throw and catch NetworkException', () {
      // Arrange & Act & Assert
      expect(
        () => throw NetworkException('Test'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('can throw and catch ValidationException', () {
      // Arrange & Act & Assert
      expect(
        () => throw ValidationException('Test'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('can throw and catch AuthException', () {
      // Arrange & Act & Assert
      expect(
        () => throw AuthException('Test'),
        throwsA(isA<AuthException>()),
      );
    });

    test('can throw and catch ActionExecutionException', () {
      // Arrange & Act & Assert
      expect(
        () => throw ActionExecutionException('Test'),
        throwsA(isA<ActionExecutionException>()),
      );
    });

    test('can catch specific exception type', () {
      // Arrange
      void throwNetworkException() {
        throw NetworkException('Network error');
      }

      // Act & Assert
      expect(
        () {
          try {
            throwNetworkException();
          } on NetworkException catch (e) {
            expect(e.message, 'Network error');
            rethrow;
          }
        },
        throwsA(isA<NetworkException>()),
      );
    });

    test('can catch as AppException base type', () {
      // Arrange
      void throwCustomException() {
        throw ValidationException('Validation error');
      }

      // Act & Assert
      expect(
        () {
          try {
            throwCustomException();
          } on AppException catch (e) {
            expect(e.message, 'Validation error');
            rethrow;
          }
        },
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
