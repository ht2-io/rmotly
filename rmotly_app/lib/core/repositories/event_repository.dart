import 'package:rmotly_client/rmotly_client.dart';
import '../services/error_handler_service.dart';
import '../services/connectivity_service.dart';
import '../services/offline_queue_service.dart';
import '../exceptions.dart';

/// Repository for managing Event entities.
///
/// Provides methods for sending and retrieving events.
/// Includes offline support and error handling.
class EventRepository {
  final Client _client;
  final ErrorHandlerService _errorHandler;
  final ConnectivityService _connectivityService;
  final OfflineQueueService _offlineQueue;

  EventRepository(
    this._client,
    this._errorHandler,
    this._connectivityService,
    this._offlineQueue,
  );

  /// Lists events for the current user.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of events to return
  /// - [offset]: Number of events to skip
  ///
  /// Returns a list of [Event] objects.
  /// Throws an exception if the operation fails.
  Future<List<Event>> listEvents({int limit = 50, int offset = 0}) async {
    // TODO: Implement once EventEndpoint is available
    // return await _client.event.listEvents(limit: limit, offset: offset);
    throw UnimplementedError('EventEndpoint not yet implemented in Serverpod');
  }

  /// Gets a specific event by ID.
  ///
  /// Parameters:
  /// - [eventId]: The ID of the event to retrieve
  ///
  /// Returns the [Event] object.
  /// Throws an exception if the event is not found or operation fails.
  Future<Event> getEvent(int eventId) async {
    // TODO: Implement once EventEndpoint is available
    // return await _client.event.getEvent(eventId);
    throw UnimplementedError('EventEndpoint not yet implemented in Serverpod');
  }

  /// Sends an event.
  ///
  /// Parameters:
  /// - [controlId]: The ID of the control triggering the event
  /// - [eventType]: The type of event
  /// - [payload]: Optional event payload as JSON string
  ///
  /// Returns the created [Event].
  /// If offline, the event is queued and an [OfflineException] is thrown.
  /// Throws an exception if the operation fails.
  Future<Event> sendEvent({
    required int controlId,
    required String eventType,
    String? payload,
  }) async {
    // Check connectivity
    if (!_connectivityService.isOnline) {
      // Queue the event for later
      await _offlineQueue.queueEvent(
        controlId: controlId,
        eventType: eventType,
        payload: payload,
      );

      throw const OfflineException(
        'Device is offline. Event queued for later.',
        code: 'OFFLINE',
      );
    }

    try {
      // TODO: Implement once EventEndpoint is available
      // return await _client.event.sendEvent(
      //   controlId: controlId,
      //   eventType: eventType,
      //   payload: payload,
      // );
      throw UnimplementedError(
          'EventEndpoint not yet implemented in Serverpod');
    } catch (error) {
      // Map error to AppException
      throw _errorHandler.mapToAppException(error);
    }
  }
}
