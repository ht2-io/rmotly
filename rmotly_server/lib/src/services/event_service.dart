import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'action_executor_service.dart';

/// Service for handling events from controls and external sources.
///
/// Responsibilities:
/// - Validate incoming events
/// - Route events to associated actions
/// - Log event results
class EventService {
  final ActionExecutorService _actionExecutor;

  EventService(this._actionExecutor);

  /// Validate an incoming event
  ///
  /// Throws [ArgumentError] if validation fails.
  void validateEvent({
    required int userId,
    required String sourceType,
    required String sourceId,
    required String eventType,
  }) {
    if (sourceType.isEmpty) {
      throw ArgumentError('sourceType cannot be empty');
    }
    if (sourceId.isEmpty) {
      throw ArgumentError('sourceId cannot be empty');
    }
    if (eventType.isEmpty) {
      throw ArgumentError('eventType cannot be empty');
    }

    // Validate sourceType is one of the allowed values
    const allowedSourceTypes = ['control', 'webhook', 'system'];
    if (!allowedSourceTypes.contains(sourceType)) {
      throw ArgumentError(
        'sourceType must be one of: ${allowedSourceTypes.join(', ')}',
      );
    }
  }

  /// Process an event by finding and executing the associated action
  ///
  /// Returns the action result as a JSON string, or null if no action is associated.
  Future<String?> processEvent(
    Session session, {
    required int userId,
    required String sourceType,
    required String sourceId,
    required String eventType,
    String? payload,
  }) async {
    // For control events, look up the associated action
    if (sourceType == 'control') {
      return await _processControlEvent(
        session,
        userId: userId,
        controlId: sourceId,
        eventType: eventType,
        payload: payload,
      );
    }

    // For webhook events, the payload is the notification data
    if (sourceType == 'webhook') {
      // Webhook events don't trigger actions, they create notifications
      // This is handled by NotificationService
      return null;
    }

    // System events are for internal logging only
    return null;
  }

  /// Process an event from a control
  Future<String?> _processControlEvent(
    Session session, {
    required int userId,
    required String controlId,
    required String eventType,
    String? payload,
  }) async {
    // Parse control ID
    final controlIdInt = int.tryParse(controlId);
    if (controlIdInt == null) {
      session.log('Invalid control ID: $controlId', level: LogLevel.warning);
      return null;
    }

    // Look up the control
    final control = await Control.db.findById(session, controlIdInt);
    if (control == null) {
      session.log('Control not found: $controlId', level: LogLevel.warning);
      return null;
    }

    // Verify ownership
    if (control.userId != userId) {
      throw UnauthorizedAccessException('Control does not belong to user');
    }

    // Check if control has an associated action
    if (control.actionId == null) {
      session.log('Control has no associated action', level: LogLevel.debug);
      return null;
    }

    // Look up the action
    final action = await Action.db.findById(session, control.actionId!);
    if (action == null) {
      session.log(
        'Action not found: ${control.actionId}',
        level: LogLevel.warning,
      );
      return null;
    }

    // Parse payload parameters
    Map<String, dynamic>? parameters;
    if (payload != null && payload.isNotEmpty) {
      try {
        parameters = jsonDecode(payload) as Map<String, dynamic>;
      } catch (e) {
        session.log(
          'Failed to parse event payload: $e',
          level: LogLevel.warning,
        );
      }
    }

    // Execute the action
    final result = await _actionExecutor.executeAction(
      action,
      parameters,
      session: session,
    );

    session.log(
      'Event processed: $eventType from control $controlId -> ${result.success ? 'success' : 'failed'}',
      level: LogLevel.info,
    );

    return jsonEncode(result.toJson());
  }

  /// Create and save a new event
  ///
  /// Returns the created event.
  Future<Event> createEvent(
    Session session, {
    required int userId,
    required String sourceType,
    required String sourceId,
    required String eventType,
    String? payload,
    String? actionResult,
  }) async {
    // Validate the event
    validateEvent(
      userId: userId,
      sourceType: sourceType,
      sourceId: sourceId,
      eventType: eventType,
    );

    // Create the event
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
      'Event created: $eventType from $sourceType:$sourceId',
      level: LogLevel.info,
    );

    return savedEvent;
  }

  /// Get events for a user with pagination
  Future<List<Event>> getEventsForUser(
    Session session, {
    required int userId,
    int limit = 50,
    int offset = 0,
    String? sourceType,
    String? eventType,
    DateTime? since,
  }) async {
    return await Event.db.find(
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
      limit: limit,
      offset: offset,
    );
  }
}

/// Exception for unauthorized access attempts
class UnauthorizedAccessException implements Exception {
  final String message;
  UnauthorizedAccessException(this.message);

  @override
  String toString() => 'UnauthorizedAccessException: $message';
}
