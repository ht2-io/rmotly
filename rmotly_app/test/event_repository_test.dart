import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/core/repositories/event_repository.dart';
import 'package:rmotly_app/core/services/error_handler_service.dart';
import 'package:rmotly_app/core/services/connectivity_service.dart';
import 'package:rmotly_app/core/services/offline_queue_service.dart';
import 'package:rmotly_client/rmotly_client.dart';

// Mock classes
class MockClient extends Mock implements Client {}

class MockErrorHandlerService extends Mock implements ErrorHandlerService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockOfflineQueueService extends Mock implements OfflineQueueService {}

void main() {
  late MockClient mockClient;
  late MockErrorHandlerService mockErrorHandler;
  late MockConnectivityService mockConnectivityService;
  late MockOfflineQueueService mockOfflineQueue;
  late EventRepository repository;

  setUp(() {
    mockClient = MockClient();
    mockErrorHandler = MockErrorHandlerService();
    mockConnectivityService = MockConnectivityService();
    mockOfflineQueue = MockOfflineQueueService();

    // Default behavior
    when(() => mockConnectivityService.isOnline).thenReturn(true);
    when(() => mockErrorHandler.isRetryable(any())).thenReturn(false);
    when(() => mockErrorHandler.mapToAppException(any()))
        .thenAnswer((invocation) => throw invocation.positionalArguments[0]);

    repository = EventRepository(
      mockClient,
      mockErrorHandler,
      mockConnectivityService,
      mockOfflineQueue,
    );
  });

  group('EventRepository', () {
    group('listEvents', () {
      test('should throw UnimplementedError when endpoint is not available',
          () {
        // Act & Assert
        expect(
          () => repository.listEvents(),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('should accept limit and offset parameters', () {
        // Act & Assert
        expect(
          () => repository.listEvents(limit: 10, offset: 5),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('getEvent', () {
      test('should throw UnimplementedError when endpoint is not available',
          () {
        // Act & Assert
        expect(
          () => repository.getEvent(1),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('sendEvent', () {
      test('should throw UnimplementedError when endpoint is not available',
          () {
        // Act & Assert
        expect(
          () => repository.sendEvent(
            controlId: 1,
            eventType: 'button_press',
            payload: '{"pressed": true}',
          ),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('should allow optional payload', () {
        // Act & Assert
        expect(
          () => repository.sendEvent(
            controlId: 1,
            eventType: 'button_press',
          ),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
  });
}
