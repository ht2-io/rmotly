import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/core/repositories/topic_repository.dart';
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
  late TopicRepository repository;

  setUp(() {
    mockClient = MockClient();
    mockErrorHandler = MockErrorHandlerService();
    mockLocalStorage = MockLocalStorageService();
    mockConnectivityService = MockConnectivityService();

    // Default behavior
    when(() => mockConnectivityService.isOnline).thenReturn(true);

    repository = TopicRepository(
      mockClient,
      mockErrorHandler,
      mockLocalStorage,
      mockConnectivityService,
    );
  });

  group('TopicRepository', () {
    group('listTopics', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Act & Assert
        expect(
          () => repository.listTopics(),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('getTopic', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Act & Assert
        expect(
          () => repository.getTopic(1),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('createTopic', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Arrange
        final topic = NotificationTopic(
          id: null,
          userId: 1,
          name: 'Test Topic',
          description: 'A test notification topic',
          apiKey: 'test-api-key',
          enabled: true,
          config: '{}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => repository.createTopic(topic),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('updateTopic', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Arrange
        final topic = NotificationTopic(
          id: 1,
          userId: 1,
          name: 'Test Topic',
          description: 'An updated test notification topic',
          apiKey: 'test-api-key',
          enabled: true,
          config: '{}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => repository.updateTopic(topic),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('deleteTopic', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Act & Assert
        expect(
          () => repository.deleteTopic(1),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('regenerateApiKey', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Act & Assert
        expect(
          () => repository.regenerateApiKey(1),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
  });
}
