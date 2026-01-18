import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/core/repositories/action_repository.dart';
import 'package:rmotly_app/core/services/error_handler_service.dart';
import 'package:rmotly_app/core/services/local_storage_service.dart';
import 'package:rmotly_app/core/services/connectivity_service.dart';
import 'package:rmotly_client/rmotly_client.dart';

// Mock classes
class MockClient extends Mock implements Client {}

class MockErrorHandlerService extends Mock implements ErrorHandlerService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockClient mockClient;
  late MockErrorHandlerService mockErrorHandler;
  late MockLocalStorageService mockLocalStorage;
  late MockConnectivityService mockConnectivityService;
  late ActionRepository repository;

  setUp(() {
    mockClient = MockClient();
    mockErrorHandler = MockErrorHandlerService();
    mockLocalStorage = MockLocalStorageService();
    mockConnectivityService = MockConnectivityService();

    // Default behavior
    when(() => mockConnectivityService.isOnline).thenReturn(true);
    when(() => mockLocalStorage.getCachedActions())
        .thenAnswer((_) async => <Action>[]);
    when(() => mockErrorHandler.isRetryable(any())).thenReturn(false);
    when(() => mockErrorHandler.mapToAppException(any())).thenThrow(
        UnimplementedError('ActionEndpoint not yet implemented in Serverpod'));

    repository = ActionRepository(
      mockClient,
      mockErrorHandler,
      mockLocalStorage,
      mockConnectivityService,
    );
  });

  group('ActionRepository', () {
    group('listActions', () {
      test('should throw UnimplementedError when endpoint is not available',
          () {
        // Act & Assert
        expect(
          () => repository.listActions(),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('getAction', () {
      test('should throw UnimplementedError when endpoint is not available',
          () {
        // Act & Assert
        expect(
          () => repository.getAction(1),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('createAction', () {
      test('should throw UnimplementedError when endpoint is not available',
          () {
        // Arrange
        final action = Action(
          id: null,
          userId: 1,
          name: 'Test Action',
          httpMethod: 'GET',
          urlTemplate: 'https://api.example.com/test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => repository.createAction(action),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('updateAction', () {
      test('should throw UnimplementedError when endpoint is not available',
          () {
        // Arrange
        final action = Action(
          id: 1,
          userId: 1,
          name: 'Test Action',
          httpMethod: 'GET',
          urlTemplate: 'https://api.example.com/test',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => repository.updateAction(action),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('deleteAction', () {
      test('should throw UnimplementedError when endpoint is not available',
          () {
        // Act & Assert
        expect(
          () => repository.deleteAction(1),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('testAction', () {
      test('should throw UnimplementedError when endpoint is not available',
          () {
        // Act & Assert
        expect(
          () => repository.testAction(1, {'param': 'value'}),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('createFromOpenApi', () {
      test('should throw UnimplementedError when endpoint is not available',
          () {
        // Act & Assert
        expect(
          () => repository.createFromOpenApi(
            'https://api.example.com/openapi.json',
            'operationId',
          ),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
  });
}
