import 'package:rmotly_app/core/services/cache_service.dart';

/// Base repository with caching support.
///
/// Implements a cache-aside pattern where data is:
/// 1. Checked in cache first
/// 2. Fetched from API if not cached or expired
/// 3. Cached for subsequent requests
///
/// Subclasses should implement [fetchFromApi] to define API calls.
abstract class CachedRepository<T> {
  final CacheService _cacheService;

  CachedRepository(this._cacheService);

  /// Default cache TTL (5 minutes)
  Duration get defaultTtl => const Duration(minutes: 5);

  /// Fetch data with caching
  ///
  /// First checks cache, then falls back to API if needed.
  /// [key] - Cache key
  /// [ttl] - Time-to-live for cached data (defaults to [defaultTtl])
  /// [forceRefresh] - Skip cache and fetch from API
  Future<T?> fetchWithCache({
    required String key,
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    // Skip cache if force refresh
    if (!forceRefresh) {
      // Try cache first
      final cached = await _cacheService.get<T>(key);
      if (cached != null) {
        return cached;
      }
    }

    // Fetch from API
    final data = await fetchFromApi();
    if (data != null) {
      // Cache the result
      await _cacheService.set(
        key,
        data,
        ttl: ttl ?? defaultTtl,
      );
    }

    return data;
  }

  /// Fetch data from API
  ///
  /// Subclasses must implement this to define API calls.
  Future<T?> fetchFromApi();

  /// Invalidate cache for this repository
  Future<void> invalidateCache(String key) async {
    await _cacheService.delete(key);
  }

  /// Batch fetch with deduplication
  ///
  /// Fetches multiple items efficiently by checking cache first
  /// and only fetching missing items from API.
  Future<List<T>> fetchBatch({
    required List<String> keys,
    required Future<T?> Function(String key) fetcher,
    Duration? ttl,
  }) async {
    final results = <T>[];
    final missingKeys = <String>[];

    // Check cache for each key
    for (final key in keys) {
      final cached = await _cacheService.get<T>(key);
      if (cached != null) {
        results.add(cached);
      } else {
        missingKeys.add(key);
      }
    }

    // Fetch missing items from API
    for (final key in missingKeys) {
      final data = await fetcher(key);
      if (data != null) {
        results.add(data);
        // Cache the result
        await _cacheService.set(
          key,
          data,
          ttl: ttl ?? defaultTtl,
        );
      }
    }

    return results;
  }
}
