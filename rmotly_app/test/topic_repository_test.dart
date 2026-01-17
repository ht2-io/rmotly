import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/core/repositories/topic_repository.dart';
import 'package:rmotly_client/rmotly_client.dart';

// Mock classes
class MockClient extends Mock implements Client {}

void main() {
  late MockClient mockClient;
  late TopicRepository repository;

  setUp(() {
    mockClient = MockClient();
    repository = TopicRepository(mockClient);
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
          apiKey: null,
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
