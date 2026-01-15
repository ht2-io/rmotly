import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rmotly_app/core/services/cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CacheService cacheService;
  late Directory tempDir;

  setUp(() async {
    // Create temp directory for Hive
    tempDir = await Directory.systemTemp.createTemp('hive_test_');

    // Initialize Hive with temp directory
    Hive.init(tempDir.path);

    cacheService = CacheService();
    await cacheService.initialize();
  });

  tearDown(() async {
    await cacheService.clear();
    await cacheService.close();

    // Clean up temp directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('CacheService', () {
    test('stores and retrieves data', () async {
      // Arrange
      const key = 'test_key';
      const data = {'name': 'Test', 'value': 42};

      // Act
      await cacheService.set(key, data);
      final result = await cacheService.get<Map<String, dynamic>>(key);

      // Assert
      expect(result, equals(data));
    });

    test('returns null for non-existent key', () async {
      // Arrange
      const key = 'non_existent';

      // Act
      final result = await cacheService.get<String>(key);

      // Assert
      expect(result, isNull);
    });

    test('respects TTL and expires data', () async {
      // Arrange
      const key = 'expiring_key';
      const data = 'test_data';
      const ttl = Duration(milliseconds: 100);

      // Act
      await cacheService.set(key, data, ttl: ttl);

      // Verify data exists immediately
      var result = await cacheService.get<String>(key);
      expect(result, equals(data));

      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 150));

      // Assert data has expired
      result = await cacheService.get<String>(key);
      expect(result, isNull);
    });

    test('stores data without TTL indefinitely', () async {
      // Arrange
      const key = 'permanent_key';
      const data = 'permanent_data';

      // Act
      await cacheService.set(key, data); // No TTL

      // Wait some time
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert data still exists
      final result = await cacheService.get<String>(key);
      expect(result, equals(data));
    });

    test('has() returns true for existing non-expired key', () async {
      // Arrange
      const key = 'existing_key';
      const data = 'data';

      // Act
      await cacheService.set(key, data);
      final exists = await cacheService.has(key);

      // Assert
      expect(exists, isTrue);
    });

    test('has() returns false for expired key', () async {
      // Arrange
      const key = 'expiring_key';
      const data = 'data';
      const ttl = Duration(milliseconds: 50);

      // Act
      await cacheService.set(key, data, ttl: ttl);
      await Future.delayed(const Duration(milliseconds: 100));
      final exists = await cacheService.has(key);

      // Assert
      expect(exists, isFalse);
    });

    test('has() returns false for non-existent key', () async {
      // Arrange
      const key = 'non_existent';

      // Act
      final exists = await cacheService.has(key);

      // Assert
      expect(exists, isFalse);
    });

    test('delete() removes cache entry', () async {
      // Arrange
      const key = 'to_delete';
      const data = 'data';

      // Act
      await cacheService.set(key, data);
      await cacheService.delete(key);
      final result = await cacheService.get<String>(key);

      // Assert
      expect(result, isNull);
    });

    test('clear() removes all cache entries', () async {
      // Arrange
      await cacheService.set('key1', 'data1');
      await cacheService.set('key2', 'data2');
      await cacheService.set('key3', 'data3');

      // Act
      await cacheService.clear();

      // Assert
      expect(await cacheService.get<String>('key1'), isNull);
      expect(await cacheService.get<String>('key2'), isNull);
      expect(await cacheService.get<String>('key3'), isNull);
    });

    test('cleanup() removes only expired entries', () async {
      // Arrange
      const ttl = Duration(milliseconds: 50);

      await cacheService.set('expired1', 'data1', ttl: ttl);
      await cacheService.set('expired2', 'data2', ttl: ttl);
      await cacheService.set('permanent', 'data3'); // No TTL

      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await cacheService.cleanup();

      // Assert
      expect(await cacheService.get<String>('expired1'), isNull);
      expect(await cacheService.get<String>('expired2'), isNull);
      expect(await cacheService.get<String>('permanent'), equals('data3'));
    });

    test('getCacheSize() returns approximate size', () async {
      // Arrange
      await cacheService.set('key1', 'short');
      await cacheService.set('key2', 'much longer string data');

      // Act
      final size = await cacheService.getCacheSize();

      // Assert
      expect(size, greaterThan(0));
    });

    test('handles complex data structures', () async {
      // Arrange
      const key = 'complex_key';
      final data = {
        'string': 'value',
        'number': 42,
        'boolean': true,
        'null': null,
        'list': [1, 2, 3],
        'nested': {'inner': 'value'},
      };

      // Act
      await cacheService.set(key, data);
      final result = await cacheService.get<Map<String, dynamic>>(key);

      // Assert
      expect(result, equals(data));
    });

    test('throws StateError when not initialized', () {
      // Arrange
      final uninitializedCache = CacheService();

      // Act & Assert
      expect(
        () => uninitializedCache.set('key', 'data'),
        throwsStateError,
      );
    });

    test('handles concurrent operations', () async {
      // Arrange
      const keyPrefix = 'concurrent_';
      const count = 10;

      // Act - write multiple entries concurrently
      await Future.wait([
        for (var i = 0; i < count; i++)
          cacheService.set('$keyPrefix$i', 'data$i'),
      ]);

      // Assert - all entries exist
      for (var i = 0; i < count; i++) {
        final result = await cacheService.get<String>('$keyPrefix$i');
        expect(result, equals('data$i'));
      }
    });
  });
}
