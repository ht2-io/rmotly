import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmotly_app/core/services/cache_service.dart';

/// Provider for the cache service
///
/// The cache service must be initialized before use.
/// Call `ref.read(cacheServiceProvider).initialize()` in main.dart.
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});
