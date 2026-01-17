import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Represents a queued event waiting to be sent to the server
class QueuedEvent {
  /// Unique identifier for this queued event
  final String id;

  /// ID of the control that triggered this event
  final int controlId;

  /// Type of event (e.g., 'button_press', 'value_change')
  final String eventType;

  /// Optional payload as JSON string
  final String? payload;

  /// Timestamp when the event was queued
  final DateTime queuedAt;

  /// Number of times this event has been attempted
  final int attemptCount;

  /// Last error message, if any
  final String? lastError;

  QueuedEvent({
    required this.id,
    required this.controlId,
    required this.eventType,
    this.payload,
    required this.queuedAt,
    this.attemptCount = 0,
    this.lastError,
  });

  /// Create a copy with updated fields
  QueuedEvent copyWith({
    String? id,
    int? controlId,
    String? eventType,
    String? payload,
    DateTime? queuedAt,
    int? attemptCount,
    String? lastError,
  }) {
    return QueuedEvent(
      id: id ?? this.id,
      controlId: controlId ?? this.controlId,
      eventType: eventType ?? this.eventType,
      payload: payload ?? this.payload,
      queuedAt: queuedAt ?? this.queuedAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'controlId': controlId,
      'eventType': eventType,
      'payload': payload,
      'queuedAt': queuedAt.toIso8601String(),
      'attemptCount': attemptCount,
      'lastError': lastError,
    };
  }

  /// Create from JSON
  factory QueuedEvent.fromJson(Map<String, dynamic> json) {
    return QueuedEvent(
      id: json['id'] as String,
      controlId: json['controlId'] as int,
      eventType: json['eventType'] as String,
      payload: json['payload'] as String?,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      attemptCount: json['attemptCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
    );
  }
}

/// Service for managing offline event queue.
///
/// This service queues events when the app is offline and processes them
/// when connectivity is restored.
class OfflineQueueService {
  static const String _queueBoxName = 'offline_event_queue';
  static const int _maxAttempts = 3;

  Box<String>? _queueBox;
  final _uuid = const Uuid();

  // Singleton pattern
  static OfflineQueueService? _instance;

  /// Get the singleton instance
  ///
  /// Note: This implementation assumes Flutter's single-threaded model.
  /// In Flutter, all Dart code runs in a single isolate by default.
  factory OfflineQueueService() {
    _instance ??= OfflineQueueService._internal();
    return _instance!;
  }

  OfflineQueueService._internal();

  /// Initialize the offline queue service
  Future<void> init() async {
    _queueBox = await Hive.openBox<String>(_queueBoxName);
  }

  /// Queue an event for later processing
  Future<String> queueEvent({
    required int controlId,
    required String eventType,
    String? payload,
  }) async {
    final box = _queueBox;
    if (box == null) throw StateError('OfflineQueueService not initialized');

    final event = QueuedEvent(
      id: _uuid.v4(),
      controlId: controlId,
      eventType: eventType,
      payload: payload,
      queuedAt: DateTime.now(),
    );

    await box.put(event.id, jsonEncode(event.toJson()));
    return event.id;
  }

  /// Get all queued events
  Future<List<QueuedEvent>> getQueuedEvents() async {
    final box = _queueBox;
    if (box == null) throw StateError('OfflineQueueService not initialized');

    final events = <QueuedEvent>[];
    for (final key in box.keys) {
      final jsonStr = box.get(key);
      if (jsonStr != null) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          events.add(QueuedEvent.fromJson(json));
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }
    }

    // Sort by queued time (oldest first)
    events.sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
    return events;
  }

  /// Get the count of queued events
  Future<int> getQueuedCount() async {
    final box = _queueBox;
    if (box == null) throw StateError('OfflineQueueService not initialized');
    return box.length;
  }

  /// Remove an event from the queue
  Future<void> removeEvent(String eventId) async {
    final box = _queueBox;
    if (box == null) throw StateError('OfflineQueueService not initialized');
    await box.delete(eventId);
  }

  /// Update an event in the queue (e.g., to increment attempt count)
  Future<void> updateEvent(QueuedEvent event) async {
    final box = _queueBox;
    if (box == null) throw StateError('OfflineQueueService not initialized');
    await box.put(event.id, jsonEncode(event.toJson()));
  }

  /// Mark an event as failed and increment attempt count
  Future<void> markEventFailed(String eventId, String error) async {
    final box = _queueBox;
    if (box == null) throw StateError('OfflineQueueService not initialized');

    final jsonStr = box.get(eventId);
    if (jsonStr != null) {
      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final event = QueuedEvent.fromJson(json);
        
        final updatedEvent = event.copyWith(
          attemptCount: event.attemptCount + 1,
          lastError: error,
        );

        // Remove if max attempts reached
        if (updatedEvent.attemptCount >= _maxAttempts) {
          await removeEvent(eventId);
        } else {
          await updateEvent(updatedEvent);
        }
      } catch (e) {
        // Remove invalid entry
        await removeEvent(eventId);
      }
    }
  }

  /// Clear all queued events
  Future<void> clearQueue() async {
    final box = _queueBox;
    if (box == null) throw StateError('OfflineQueueService not initialized');
    await box.clear();
  }

  /// Close the queue box
  Future<void> close() async {
    await _queueBox?.close();
  }
}
