import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages in-flight API requests to prevent duplicate calls.
///
/// When multiple parts of the app request the same data simultaneously,
/// this service ensures only one actual API call is made and all callers
/// receive the same result.
class RequestDeduplicator {
  final Map<String, Completer<dynamic>> _inflightRequests = {};

  /// Execute a request with deduplication.
  ///
  /// If a request with the same [key] is already in progress,
  /// returns the existing request's future. Otherwise, executes
  /// [fetcher] and caches the result until completion.
  Future<T> execute<T>({
    required String key,
    required Future<T> Function() fetcher,
  }) async {
    // Check if request is already in flight
    if (_inflightRequests.containsKey(key)) {
      return await _inflightRequests[key]!.future as T;
    }

    // Create new completer for this request
    final completer = Completer<T>();
    _inflightRequests[key] = completer;

    try {
      // Execute the actual request
      final result = await fetcher();
      completer.complete(result);
      return result;
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      // Remove from in-flight map
      _inflightRequests.remove(key);
    }
  }

  /// Cancel all in-flight requests
  void cancelAll() {
    for (final completer in _inflightRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Request cancelled'),
        );
      }
    }
    _inflightRequests.clear();
  }

  /// Check if a request is currently in flight
  bool isInFlight(String key) {
    return _inflightRequests.containsKey(key);
  }

  /// Get the number of in-flight requests
  int get inflightCount => _inflightRequests.length;
}

/// Provider for the request deduplicator
final requestDeduplicatorProvider = Provider<RequestDeduplicator>((ref) {
  final deduplicator = RequestDeduplicator();

  // Clean up on dispose
  ref.onDispose(() {
    deduplicator.cancelAll();
  });

  return deduplicator;
});

/// Extension to add deduplication support to Ref
extension DeduplicationRefExtension on Ref {
  /// Execute a deduplicated request
  Future<T> deduplicate<T>({
    required String key,
    required Future<T> Function() fetcher,
  }) {
    final deduplicator = read(requestDeduplicatorProvider);
    return deduplicator.execute(key: key, fetcher: fetcher);
  }
}
