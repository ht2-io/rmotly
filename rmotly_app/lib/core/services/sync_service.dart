import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/event_repository.dart';
import '../providers/repository_providers.dart';
import 'connectivity_service.dart';
import 'error_handler_service.dart';
import 'offline_queue_service.dart';

/// Service for synchronizing offline queued events with the server.
///
/// This service monitors connectivity and automatically processes
/// the offline queue when the device comes back online.
class SyncService {
  final OfflineQueueService _queueService;
  final EventRepository _eventRepository;
  final ConnectivityService _connectivityService;
  final ErrorHandlerService _errorHandler;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService({
    required OfflineQueueService queueService,
    required EventRepository eventRepository,
    required ConnectivityService connectivityService,
    required ErrorHandlerService errorHandler,
  })  : _queueService = queueService,
        _eventRepository = eventRepository,
        _connectivityService = connectivityService,
        _errorHandler = errorHandler {
    _init();
  }

  /// Initialize the sync service
  void _init() {
    // Listen for connectivity changes
    _connectivitySubscription = _connectivityService.statusStream.listen(
      (status) {
        if (status == ConnectivityStatus.online) {
          // Device came back online, trigger sync
          processQueue();
        }
      },
    );
  }

  /// Process all queued events
  ///
  /// Returns the number of successfully processed events.
  ///
  /// Note: This guard assumes Flutter's single-threaded model where
  /// all async operations run sequentially on the event loop.
  Future<int> processQueue() async {
    // Prevent concurrent syncing
    if (_isSyncing) {
      return 0;
    }

    // Check if online
    if (!_connectivityService.isOnline) {
      return 0;
    }

    _isSyncing = true;
    int successCount = 0;

    try {
      final queuedEvents = await _queueService.getQueuedEvents();

      for (final queuedEvent in queuedEvents) {
        try {
          // Attempt to send the event
          await _eventRepository.sendEvent(
            controlId: queuedEvent.controlId,
            eventType: queuedEvent.eventType,
            payload: queuedEvent.payload,
          );

          // Success - remove from queue
          await _queueService.removeEvent(queuedEvent.id);
          successCount++;
        } catch (error) {
          // Failed - check if retryable
          if (_errorHandler.isRetryable(error)) {
            // Mark as failed and increment attempt count
            final errorMessage = _errorHandler.getErrorMessage(error);
            await _queueService.markEventFailed(queuedEvent.id, errorMessage);
          } else {
            // Non-retryable error - remove from queue
            await _queueService.removeEvent(queuedEvent.id);
          }
        }
      }
    } finally {
      _isSyncing = false;
    }

    return successCount;
  }

  /// Get the number of pending events in the queue
  Future<int> getPendingCount() async {
    return await _queueService.getQueuedCount();
  }

  /// Check if sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

/// Provider for the sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final queueService = ref.watch(offlineQueueServiceProvider);
  final eventRepository = ref.watch(eventRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final errorHandler = ref.watch(errorHandlerServiceProvider);

  final service = SyncService(
    queueService: queueService,
    eventRepository: eventRepository,
    connectivityService: connectivityService,
    errorHandler: errorHandler,
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
