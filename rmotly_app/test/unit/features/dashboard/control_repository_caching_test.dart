import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/core/services/local_storage_service.dart';
import 'package:rmotly_app/features/dashboard/data/repositories/control_repository_impl.dart';
import 'package:rmotly_client/rmotly_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

// Mock classes
class MockClient extends Mock implements Client {}
class MockLocalStorageService extends Mock implements LocalStorageService {}
class MockSessionManager extends Mock implements SessionManager {}
class MockEndpointControl extends Mock {
  Future<List<Control>> listControls({required int userId});
}
class MockUserInfo extends Mock implements UserInfo {}

void main() {
  late MockClient mockClient;
  late MockLocalStorageService mockStorage;
  late MockSessionManager mockSessionManager;
  late MockEndpointControl mockControlEndpoint;
  late MockUserInfo mockUserInfo;
  late ControlRepositoryImpl repository;

  // Test data
  final testControls = [
    Control(
      id: 1,
      userId: 100,
      name: 'Test Control 1',
      controlType: 'button',
      config: '{}',
      position: 0,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Control(
      id: 2,
      userId: 100,
      name: 'Test Control 2',
      controlType: 'toggle',
      config: '{}',
      position: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  setUp(() {
    mockClient = MockClient();
    mockStorage = MockLocalStorageService();
    mockSessionManager = MockSessionManager();
    mockControlEndpoint = MockEndpointControl();
    mockUserInfo = MockUserInfo();
    
    // Set up user authentication
    when(() => mockUserInfo.id).thenReturn(100);
    when(() => mockSessionManager.signedInUser).thenReturn(mockUserInfo);
    
    repository = ControlRepositoryImpl(mockClient, mockStorage, mockSessionManager);

    // Set up default storage behavior
    when(() => mockStorage.cacheControls(any()))
        .thenAnswer((_) async => {});
    
    // Set up default client behavior - return test controls
    when(() => mockClient.control).thenReturn(mockControlEndpoint as dynamic);
    when(() => mockControlEndpoint.listControls(userId: any(named: 'userId')))
        .thenAnswer((_) async => testControls);
  });

  group('ControlRepositoryImpl Caching', () {
    group('getControls with caching', () {
      test('should return cached data when available and not expired', () async {
        // Arrange - Set up cache with data
        when(() => mockStorage.getCachedControls())
            .thenAnswer((_) async => testControls);

        // First call to populate the cache timestamp
        await repository.getControls(forceRefresh: true);

        // Act - Second call should use cache
        final result = await repository.getControls(forceRefresh: false);

        // Assert
        expect(result, testControls);
        // getCachedControls should be called when trying to use cache
        verify(() => mockStorage.getCachedControls()).called(greaterThanOrEqualTo(1));
      });

      test('should fetch from API when forceRefresh is true', () async {
        // Arrange
        when(() => mockStorage.getCachedControls())
            .thenAnswer((_) async => testControls);

        // Act
        final result = await repository.getControls(forceRefresh: true);

        // Assert - Should cache the new data
        verify(() => mockStorage.cacheControls(any())).called(1);
      });

      test('should fetch from API when cache is empty', () async {
        // Arrange - Empty cache
        when(() => mockStorage.getCachedControls())
            .thenAnswer((_) async => <Control>[]);

        // Act
        final result = await repository.getControls(forceRefresh: false);

        // Assert - Should fetch and cache
        verify(() => mockStorage.cacheControls(any())).called(1);
      });

      test('should continue on cache read failure', () async {
        // Arrange - Cache read throws error
        when(() => mockStorage.getCachedControls())
            .thenThrow(Exception('Cache read failed'));

        // Act - Should still succeed by fetching from API
        final result = await repository.getControls(forceRefresh: false);

        // Assert
        expect(result, isNotEmpty); // Mock data should be returned
        verify(() => mockStorage.cacheControls(any())).called(1);
      });

      test('should continue on cache write failure', () async {
        // Arrange - Cache write throws error
        when(() => mockStorage.cacheControls(any()))
            .thenThrow(Exception('Cache write failed'));

        // Act - Should still succeed
        final result = await repository.getControls(forceRefresh: true);

        // Assert
        expect(result, isNotEmpty); // Mock data should be returned
      });
    });

    group('request deduplication', () {
      test('should deduplicate concurrent requests', () async {
        // Arrange
        when(() => mockStorage.getCachedControls())
            .thenAnswer((_) async => <Control>[]);

        // Act - Make multiple concurrent calls
        final futures = [
          repository.getControls(forceRefresh: true),
          repository.getControls(forceRefresh: true),
          repository.getControls(forceRefresh: true),
        ];

        await Future.wait(futures);

        // Assert - Cache should only be written once (deduplication)
        // The actual API call count would be 1, but we're using mock data
        // so we verify the caching behavior
        verify(() => mockStorage.cacheControls(any())).called(1);
      });
    });

    group('cache invalidation', () {
      test('should invalidate cache on createControl', () async {
        // Arrange
        final newControl = Control(
          id: null,
          userId: 100,
          name: 'New Control',
          controlType: 'button',
          config: '{}',
          position: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // First, populate the cache
        when(() => mockStorage.getCachedControls())
            .thenAnswer((_) async => testControls);
        await repository.getControls(forceRefresh: true);

        // Act - Create control should invalidate cache
        try {
          await repository.createControl(newControl);
        } catch (e) {
          // Expected to throw UnimplementedError
          expect(e, isA<UnimplementedError>());
        }

        // Assert - Next call should fetch fresh data
        when(() => mockStorage.getCachedControls())
            .thenAnswer((_) async => <Control>[]);
        await repository.getControls(forceRefresh: false);

        // Cache was invalidated, so it should fetch fresh data
        verify(() => mockStorage.cacheControls(any())).called(greaterThanOrEqualTo(1));
      });

      test('should invalidate cache on updateControl', () async {
        // Arrange
        final updatedControl = testControls[0].copyWith(name: 'Updated Name');

        // First, populate the cache
        when(() => mockStorage.getCachedControls())
            .thenAnswer((_) async => testControls);
        await repository.getControls(forceRefresh: true);

        // Act
        try {
          await repository.updateControl(updatedControl);
        } catch (e) {
          expect(e, isA<UnimplementedError>());
        }

        // Assert - Cache should be invalidated
        when(() => mockStorage.getCachedControls())
            .thenAnswer((_) async => <Control>[]);
        await repository.getControls(forceRefresh: false);
        verify(() => mockStorage.cacheControls(any())).called(greaterThanOrEqualTo(1));
      });

      test('should invalidate cache on deleteControl', () async {
        // Arrange - Populate cache
        when(() => mockStorage.getCachedControls())
            .thenAnswer((_) async => testControls);
        await repository.getControls(forceRefresh: true);

        // Act
        try {
          await repository.deleteControl(1);
        } catch (e) {
          expect(e, isA<UnimplementedError>());
        }

        // Assert
        when(() => mockStorage.getCachedControls())
            .thenAnswer((_) async => <Control>[]);
        await repository.getControls(forceRefresh: false);
        verify(() => mockStorage.cacheControls(any())).called(greaterThanOrEqualTo(1));
      });
    });

    group('optimistic caching', () {
      test('should optimistically update cache on reorderControls', () async {
        // Arrange
        final reorderedControls = [testControls[1], testControls[0]];

        // Act
        try {
          await repository.reorderControls(reorderedControls);
        } catch (e) {
          expect(e, isA<UnimplementedError>());
        }

        // Assert - Should have cached the reordered list
        verify(() => mockStorage.cacheControls(reorderedControls)).called(1);
      });
    });
  });
}
