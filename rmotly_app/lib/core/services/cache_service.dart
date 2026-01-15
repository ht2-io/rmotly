import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing local cache storage using Hive.
///
/// Provides caching with TTL (time-to-live) support for API responses.
/// Each cached entry includes a timestamp for expiration checking.
class CacheService {
  static const String _cacheBoxName = 'rmotly_cache';
  static const String _metadataBoxName = 'rmotly_cache_metadata';

  late Box<String> _cacheBox;
  late Box<int> _metadataBox;

  bool _initialized = false;

  /// Initialize the cache service
  ///
  /// Must be called before using any other methods.
  Future<void> initialize() async {
    if (_initialized) return;

    // Note: Hive.init() should be called before this in main.dart or tests
    _cacheBox = await Hive.openBox<String>(_cacheBoxName);
    _metadataBox = await Hive.openBox<int>(_metadataBoxName);
    _initialized = true;
  }

  /// Store data in cache with optional TTL
  ///
  /// [key] - Cache key
  /// [data] - Data to cache (will be JSON encoded)
  /// [ttl] - Time-to-live duration (null = no expiration)
  Future<void> set<T>(
    String key,
    T data, {
    Duration? ttl,
  }) async {
    _ensureInitialized();

    // Encode data as JSON
    final jsonData = jsonEncode(data);
    await _cacheBox.put(key, jsonData);

    // Store expiration timestamp if TTL is provided
    if (ttl != null) {
      final expiresAt = DateTime.now().add(ttl).millisecondsSinceEpoch;
      await _metadataBox.put(key, expiresAt);
    } else {
      await _metadataBox.delete(key);
    }
  }

  /// Get data from cache
  ///
  /// Returns null if:
  /// - Key doesn't exist
  /// - Data has expired
  /// - Decoding fails
  Future<T?> get<T>(String key) async {
    _ensureInitialized();

    // Check if data exists
    final jsonData = _cacheBox.get(key);
    if (jsonData == null) return null;

    // Check expiration
    final expiresAt = _metadataBox.get(key);
    if (expiresAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiresAt) {
        // Data expired, remove it
        await delete(key);
        return null;
      }
    }

    // Decode and return data
    try {
      return jsonDecode(jsonData) as T;
    } catch (e) {
      // If decoding fails, remove corrupt data
      await delete(key);
      return null;
    }
  }

  /// Check if cache contains a valid (non-expired) entry for the key
  Future<bool> has(String key) async {
    _ensureInitialized();

    if (!_cacheBox.containsKey(key)) return false;

    // Check expiration
    final expiresAt = _metadataBox.get(key);
    if (expiresAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiresAt) {
        await delete(key);
        return false;
      }
    }

    return true;
  }

  /// Delete a cache entry
  Future<void> delete(String key) async {
    _ensureInitialized();

    await _cacheBox.delete(key);
    await _metadataBox.delete(key);
  }

  /// Clear all cache entries
  Future<void> clear() async {
    _ensureInitialized();

    await _cacheBox.clear();
    await _metadataBox.clear();
  }

  /// Remove expired entries
  Future<void> cleanup() async {
    _ensureInitialized();

    final now = DateTime.now().millisecondsSinceEpoch;
    final keysToDelete = <String>[];

    // Find expired entries
    for (final key in _metadataBox.keys) {
      final expiresAt = _metadataBox.get(key);
      if (expiresAt != null && now > expiresAt) {
        keysToDelete.add(key as String);
      }
    }

    // Delete expired entries
    for (final key in keysToDelete) {
      await delete(key);
    }
  }

  /// Get the size of the cache in bytes (approximate)
  Future<int> getCacheSize() async {
    _ensureInitialized();

    var size = 0;
    for (final value in _cacheBox.values) {
      size += value.length;
    }
    return size;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'CacheService not initialized. Call initialize() first.',
      );
    }
  }

  /// Close the cache service
  Future<void> close() async {
    if (!_initialized) return;

    await _cacheBox.close();
    await _metadataBox.close();
    _initialized = false;
  }
}
