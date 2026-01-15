import 'package:serverpod/serverpod.dart';

import '../generated/event.dart';
import '../generated/event_response.dart';
import '../services/event_service.dart';
import 'notification_stream_endpoint.dart' show AuthenticationException;

/// Endpoint for event management.
///
/// This endpoint handles:
/// - Sending events from controls
/// - Listing events for the authenticated user
/// - Retrieving individual events by ID
class EventEndpoint extends Endpoint {
  final EventService _eventService = EventService(ActionExecutorService());

  /// Send an event from a control
  ///
  /// [controlId] - The ID of the control triggering the event
  /// [eventType] - Type of event (button_press, toggle_change, etc.)
  /// [payload] - Optional JSON payload
  ///
  /// Returns [EventResponse] with success status and event ID.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if controlId or eventType is empty.
  Future<EventResponse> sendEvent(
    Session session, {
    required String controlId,
    required String eventType,
    String? payload,
  }) async {
    // Validate input
    if (controlId.isEmpty) {
      throw ArgumentError('controlId cannot be empty');
    }
    if (eventType.isEmpty) {
      throw ArgumentError('eventType cannot be empty');
    }

    // Get authenticated user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      session.log(
        'Unauthenticated event creation rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }
    final userId = authInfo.userId;

    try {
      // Validate the event
      _eventService.validateEvent(
        userId: userId,
        sourceType: 'control',
        sourceId: controlId,
        eventType: eventType,
      );

      // Process the event (execute associated action if any)
      final actionResult = await _eventService.processEvent(
        session,
        userId: userId,
        sourceType: 'control',
        sourceId: controlId,
        eventType: eventType,
        payload: payload,
      );

      // Create and save the event
      final event = await _eventService.createEvent(
        session,
        userId: userId,
        sourceType: 'control',
        sourceId: controlId,
        eventType: eventType,
        payload: payload,
        actionResult: actionResult,
      );

      session.log(
        'Event created successfully: $eventType from control $controlId',
        level: LogLevel.info,
      );

      // Return success response
      // TODO: Replace with actual event.id once models are generated
      return EventResponse(
        success: true,
        eventId: event['id'] as int?,
      );
    } catch (e) {
      session.log(
        'Failed to create event: $e',
        level: LogLevel.error,
      );
      return EventResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// List events for current user
  ///
  /// [limit] - Maximum number of events to return (default: 50, max: 100)
  /// [offset] - Number of events to skip for pagination (default: 0)
  ///
  /// Returns a list of events for the authenticated user.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if limit is invalid.
  Future<List<Event>> listEvents(
    Session session, {
    int limit = 50,
    int offset = 0,
  }) async {
    // Validate input
    if (limit < 1 || limit > 100) {
      throw ArgumentError('limit must be between 1 and 100');
    }
    if (offset < 0) {
      throw ArgumentError('offset must be non-negative');
    }

    // Get authenticated user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      session.log(
        'Unauthenticated event list request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }
    final userId = authInfo.userId;

    session.log(
      'Listing events for user $userId (limit: $limit, offset: $offset)',
      level: LogLevel.debug,
    );

    // Get events from service
    final eventMaps = await _eventService.getEventsForUser(
      session,
      userId: userId,
      limit: limit,
      offset: offset,
    );

    // Convert to Event objects
    // TODO: Replace with actual Event model conversion once generated
    return eventMaps.map((map) {
      return Event(
        userId: map['userId'] as int,
        sourceType: map['sourceType'] as String,
        sourceId: map['sourceId'] as String,
        eventType: map['eventType'] as String,
        payload: map['payload'] as String?,
        actionResult: map['actionResult'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
    }).toList();
  }

  /// Get event by ID
  ///
  /// [eventId] - The ID of the event to retrieve
  ///
  /// Returns the event if found and belongs to the authenticated user,
  /// null otherwise.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if eventId is invalid.
  Future<Event?> getEvent(Session session, int eventId) async {
    // Validate input
    if (eventId < 1) {
      throw ArgumentError('eventId must be positive');
    }

    // Get authenticated user
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      session.log(
        'Unauthenticated event retrieval rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }
    final userId = authInfo.userId;

    session.log(
      'Retrieving event $eventId for user $userId',
      level: LogLevel.debug,
    );

    // TODO: Replace with actual database query once models are generated
    // final event = await Event.db.findById(session, eventId);
    // if (event == null || event.userId != userId) {
    //   return null;
    // }
    // return event;

    // Placeholder: return null until models are generated
    return null;
  }
}
