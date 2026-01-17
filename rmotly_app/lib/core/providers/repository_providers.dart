import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmotly_app/core/providers/api_client_provider.dart';
import 'package:rmotly_app/core/providers/local_storage_provider.dart';
import 'package:rmotly_app/core/repositories/repositories.dart';
import 'package:rmotly_app/core/services/error_handler_service.dart';
import 'package:rmotly_app/core/services/connectivity_service.dart';
import 'package:rmotly_app/core/services/offline_queue_service.dart';

/// Provider for the ErrorHandlerService.
final errorHandlerServiceProvider = Provider<ErrorHandlerService>((ref) {
  return ErrorHandlerService();
});

/// Provider for the OfflineQueueService.
///
/// The service uses a singleton pattern and is initialized in main.dart.
/// Subsequent calls return the same initialized instance.
final offlineQueueServiceProvider = Provider<OfflineQueueService>((ref) {
  return OfflineQueueService();
});

/// Provider for the ControlRepository.
///
/// Provides access to control-related operations.
/// Includes offline caching and error handling.
final controlRepositoryProvider = Provider<ControlRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final errorHandler = ref.watch(errorHandlerServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  
  return ControlRepository(
    client,
    errorHandler,
    localStorage,
    connectivity,
  );
});

/// Provider for the ActionRepository.
///
/// Provides access to action-related operations.
/// Includes offline caching and error handling.
final actionRepositoryProvider = Provider<ActionRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final errorHandler = ref.watch(errorHandlerServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  
  return ActionRepository(
    client,
    errorHandler,
    localStorage,
    connectivity,
  );
});

/// Provider for the TopicRepository.
///
/// Provides access to notification topic-related operations.
/// Includes offline caching and error handling.
final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final errorHandler = ref.watch(errorHandlerServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  
  return TopicRepository(
    client,
    errorHandler,
    localStorage,
    connectivity,
  );
});

/// Provider for the EventRepository.
///
/// Provides access to event-related operations.
/// Includes offline queueing and error handling.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final errorHandler = ref.watch(errorHandlerServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final offlineQueue = ref.watch(offlineQueueServiceProvider);
  
  return EventRepository(
    client,
    errorHandler,
    connectivity,
    offlineQueue,
  );
});
