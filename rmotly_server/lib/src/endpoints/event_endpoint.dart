import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/event_service.dart';
import '../services/action_executor_service.dart' show ActionExecutorService;

/// Endpoint for managing events (triggered by controls or webhooks).
///
/// Provides methods to send, list, and retrieve events.
class EventEndpoint extends Endpoint {
  late final EventService _eventService;

  @override
  void initialize(
    Server server,
    String name,
    String? moduleName,
  ) {
    super.initialize(server, name, moduleName);
    _eventService = EventService(ActionExecutorService());
  }

  /// Send a new event.
  ///
  /// Creates an event from a control interaction or external source,
  /// processes any associated action, and logs the result.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [sourceType]: Event source type (control, webhook, system)
  /// - [sourceId]: Identifier of the source (control ID, topic ID, etc.)
  /// - [eventType]: Type of event (button_press, toggle_change, etc.)
  /// - [payload]: Optional event payload as JSON string
  ///
  /// Returns: The created [Event] with action result if applicable.
  Future<Event> sendEvent(
    Session session, {
    required String sourceType,
    required String sourceId,
    required String eventType,
    String? payload,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    // Validate the event
    _eventService.validateEvent(
      userId: userId,
      sourceType: sourceType,
      sourceId: sourceId,
      eventType: eventType,
    );

    // Process the event (execute associated action if any)
    final actionResult = await _eventService.processEvent(
      session,
      userId: userId,
      sourceType: sourceType,
      sourceId: sourceId,
      eventType: eventType,
      payload: payload,
    );

    // Create and save the event
    final event = Event(
      userId: userId,
      sourceType: sourceType,
      sourceId: sourceId,
      eventType: eventType,
      payload: payload,
      actionResult: actionResult,
      timestamp: DateTime.now(),
    );

    final savedEvent = await Event.db.insertRow(session, event);

    session.log(
      'Event created: ${savedEvent.id} - $eventType from $sourceType:$sourceId',
      level: LogLevel.info,
    );

    return savedEvent;
  }

  /// List events for the authenticated user.
  ///
  /// Supports pagination and filtering by source type, event type, and date.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [limit]: Maximum number of events to return (default: 50, max: 100)
  /// - [offset]: Number of events to skip for pagination
  /// - [sourceType]: Optional filter by source type
  /// - [eventType]: Optional filter by event type
  /// - [since]: Optional filter for events after this timestamp
  ///
  /// Returns: List of [Event] objects matching the criteria.
  Future<List<Event>> listEvents(
    Session session, {
    int limit = 50,
    int offset = 0,
    String? sourceType,
    String? eventType,
    DateTime? since,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    // Clamp limit to prevent excessive queries
    final clampedLimit = limit.clamp(1, 100);

    // Build the query
    final events = await Event.db.find(
      session,
      where: (t) {
        var condition = t.userId.equals(userId);
        if (sourceType != null) {
          condition = condition & t.sourceType.equals(sourceType);
        }
        if (eventType != null) {
          condition = condition & t.eventType.equals(eventType);
        }
        if (since != null) {
          condition = condition & (t.timestamp > since);
        }
        return condition;
      },
      orderBy: (t) => t.timestamp,
      orderDescending: true,
      limit: clampedLimit,
      offset: offset,
    );

    return events;
  }

  /// Get a specific event by ID.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [eventId]: The ID of the event to retrieve
  ///
  /// Returns: The [Event] if found and owned by the user.
  ///
  /// Throws: [ArgumentError] if event not found or not owned by user.
  Future<Event> getEvent(
    Session session, {
    required int eventId,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    // Fetch the event
    final event = await Event.db.findById(session, eventId);
    if (event == null) {
      throw ArgumentError('Event not found: $eventId');
    }

    // Verify ownership
    if (event.userId != userId) {
      throw ArgumentError('Event not found: $eventId');
    }

    return event;
  }

  /// Delete an event by ID.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [eventId]: The ID of the event to delete
  ///
  /// Returns: True if the event was deleted.
  Future<bool> deleteEvent(
    Session session, {
    required int eventId,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    // Fetch the event to verify ownership
    final event = await Event.db.findById(session, eventId);
    if (event == null) {
      return false;
    }

    // Verify ownership
    if (event.userId != userId) {
      return false;
    }

    // Delete the event
    await Event.db.deleteRow(session, event);

    session.log(
      'Event deleted: $eventId',
      level: LogLevel.info,
    );

    return true;
  }

  /// Get event counts by source type for the authenticated user.
  ///
  /// Useful for dashboard statistics.
  Future<Map<String, int>> getEventCounts(
    Session session, {
    DateTime? since,
  }) async {
    // Get authenticated user
    final authInfo = await session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw AuthenticationException('User not authenticated');
    }

    final counts = <String, int>{};
    final sourceTypes = ['control', 'webhook', 'system'];

    for (final sourceType in sourceTypes) {
      final count = await Event.db.count(
        session,
        where: (t) {
          var condition = t.userId.equals(userId) & t.sourceType.equals(sourceType);
          if (since != null) {
            condition = condition & (t.timestamp > since);
          }
          return condition;
        },
      );
      counts[sourceType] = count;
    }

    return counts;
  }
}

/// Exception thrown when authentication fails
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}
