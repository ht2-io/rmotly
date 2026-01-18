/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:rmotly_client/src/protocol/action.dart' as _i3;
import 'package:rmotly_client/src/protocol/control.dart' as _i4;
import 'package:rmotly_client/src/protocol/event.dart' as _i5;
import 'package:rmotly_client/src/protocol/notification_topic.dart' as _i6;
import 'package:rmotly_client/src/protocol/stream_notification.dart' as _i7;
import 'package:rmotly_client/src/protocol/openapi_spec.dart' as _i8;
import 'package:rmotly_client/src/protocol/openapi_operation.dart' as _i9;
import 'package:rmotly_client/src/protocol/push_subscription.dart' as _i10;
import 'package:rmotly_client/src/protocol/greeting.dart' as _i11;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i12;
import 'protocol.dart' as _i13;

/// Serverpod endpoint for managing actions (HTTP request templates).
///
/// Provides methods to create, read, update, delete, and test actions
/// that can be triggered by controls or other events.
/// {@category Endpoint}
class EndpointAction extends _i1.EndpointRef {
  EndpointAction(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'action';

  /// Create a new action
  ///
  /// Creates an HTTP action template that can be triggered by controls.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [userId]: ID of the user creating the action
  /// - [name]: Display name for the action
  /// - [httpMethod]: HTTP method (GET, POST, PUT, DELETE, PATCH)
  /// - [urlTemplate]: URL template with {{variable}} placeholders
  /// - [description]: Optional description of what the action does
  /// - [headersTemplate]: Optional headers template as JSON string
  /// - [bodyTemplate]: Optional body template with {{variable}} placeholders
  /// - [parameters]: Optional parameters definition as JSON string
  ///
  /// Returns: The created [Action] with generated ID
  ///
  /// Throws: [ArgumentError] if validation fails
  _i2.Future<_i3.Action> createAction({
    required int userId,
    required String name,
    required String httpMethod,
    required String urlTemplate,
    String? description,
    String? headersTemplate,
    String? bodyTemplate,
    String? parameters,
  }) =>
      caller.callServerEndpoint<_i3.Action>(
        'action',
        'createAction',
        {
          'userId': userId,
          'name': name,
          'httpMethod': httpMethod,
          'urlTemplate': urlTemplate,
          'description': description,
          'headersTemplate': headersTemplate,
          'bodyTemplate': bodyTemplate,
          'parameters': parameters,
        },
      );

  /// List all actions for a user
  ///
  /// Returns actions ordered by creation date (newest first).
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [userId]: ID of the user whose actions to list
  ///
  /// Returns: List of [Action] ordered by creation date
  _i2.Future<List<_i3.Action>> listActions({required int userId}) =>
      caller.callServerEndpoint<List<_i3.Action>>(
        'action',
        'listActions',
        {'userId': userId},
      );

  /// Get a single action by ID
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [actionId]: ID of the action to retrieve
  ///
  /// Returns: The [Action] or null if not found
  _i2.Future<_i3.Action?> getAction({required int actionId}) =>
      caller.callServerEndpoint<_i3.Action?>(
        'action',
        'getAction',
        {'actionId': actionId},
      );

  /// Update an action
  ///
  /// Updates the specified fields of an action. All fields are optional
  /// except actionId. Only provided fields will be updated.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [actionId]: ID of the action to update
  /// - [name]: New display name (optional)
  /// - [description]: New description (optional)
  /// - [httpMethod]: New HTTP method (optional)
  /// - [urlTemplate]: New URL template (optional)
  /// - [headersTemplate]: New headers template (optional)
  /// - [bodyTemplate]: New body template (optional)
  /// - [parameters]: New parameters definition (optional)
  ///
  /// Returns: The updated [Action]
  ///
  /// Throws: [ArgumentError] if action not found or validation fails
  _i2.Future<_i3.Action> updateAction({
    required int actionId,
    String? name,
    String? description,
    String? httpMethod,
    String? urlTemplate,
    String? headersTemplate,
    String? bodyTemplate,
    String? parameters,
    required bool clearDescription,
    required bool clearHeadersTemplate,
    required bool clearBodyTemplate,
    required bool clearParameters,
  }) =>
      caller.callServerEndpoint<_i3.Action>(
        'action',
        'updateAction',
        {
          'actionId': actionId,
          'name': name,
          'description': description,
          'httpMethod': httpMethod,
          'urlTemplate': urlTemplate,
          'headersTemplate': headersTemplate,
          'bodyTemplate': bodyTemplate,
          'parameters': parameters,
          'clearDescription': clearDescription,
          'clearHeadersTemplate': clearHeadersTemplate,
          'clearBodyTemplate': clearBodyTemplate,
          'clearParameters': clearParameters,
        },
      );

  /// Delete an action
  ///
  /// Permanently deletes an action from the database.
  /// Note: This will leave any associated controls without an action.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [actionId]: ID of the action to delete
  ///
  /// Returns: true if deleted, false if not found
  _i2.Future<bool> deleteAction({required int actionId}) =>
      caller.callServerEndpoint<bool>(
        'action',
        'deleteAction',
        {'actionId': actionId},
      );

  /// Test an action with provided parameters
  ///
  /// Executes the action with test parameters to verify it works correctly.
  /// This performs the actual HTTP request.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [actionId]: ID of the action to test
  /// - [testParameters]: Parameters to use for template substitution
  ///
  /// Returns: Map containing execution result with keys:
  ///   - success: bool
  ///   - statusCode: int?
  ///   - responseBody: String?
  ///   - responseHeaders: Map<String, String>?
  ///   - executionTimeMs: int
  ///   - error: String? (if failed)
  ///
  /// Throws: [ArgumentError] if action not found
  _i2.Future<Map<String, dynamic>> testAction({
    required int actionId,
    required Map<String, dynamic> testParameters,
  }) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'action',
        'testAction',
        {
          'actionId': actionId,
          'testParameters': testParameters,
        },
      );
}

/// Serverpod endpoint for managing controls (dashboard UI elements).
///
/// Provides methods to create, read, update, and delete controls,
/// as well as reorder them within a user's dashboard.
/// {@category Endpoint}
class EndpointControl extends _i1.EndpointRef {
  EndpointControl(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'control';

  /// Create a new control
  ///
  /// Creates a control that can trigger actions from the dashboard.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [userId]: ID of the user creating the control (temporary until auth is implemented)
  /// - [name]: Display name for the control
  /// - [controlType]: Type of control (button, toggle, slider, input, dropdown)
  /// - [config]: Control configuration as JSON string
  /// - [position]: Position/order in the dashboard
  /// - [actionId]: Optional ID of the action to trigger
  ///
  /// Returns: The created [Control] with generated ID
  ///
  /// Throws: [ArgumentError] if validation fails
  _i2.Future<_i4.Control> createControl({
    required int userId,
    required String name,
    required String controlType,
    required String config,
    required int position,
    int? actionId,
  }) =>
      caller.callServerEndpoint<_i4.Control>(
        'control',
        'createControl',
        {
          'userId': userId,
          'name': name,
          'controlType': controlType,
          'config': config,
          'position': position,
          'actionId': actionId,
        },
      );

  /// List all controls for a user
  ///
  /// Returns controls ordered by position.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [userId]: ID of the user whose controls to list
  ///
  /// Returns: List of [Control] ordered by position
  _i2.Future<List<_i4.Control>> listControls({required int userId}) =>
      caller.callServerEndpoint<List<_i4.Control>>(
        'control',
        'listControls',
        {'userId': userId},
      );

  /// Get a single control by ID
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [controlId]: ID of the control to retrieve
  ///
  /// Returns: The [Control] or null if not found
  _i2.Future<_i4.Control?> getControl({required int controlId}) =>
      caller.callServerEndpoint<_i4.Control?>(
        'control',
        'getControl',
        {'controlId': controlId},
      );

  /// Update a control
  ///
  /// Updates the specified fields of a control. All fields are optional
  /// except controlId. Only provided fields will be updated.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [controlId]: ID of the control to update
  /// - [name]: New display name (optional)
  /// - [controlType]: New control type (optional)
  /// - [config]: New configuration JSON (optional)
  /// - [position]: New position (optional)
  /// - [actionId]: New action ID (optional, can be null to remove association)
  ///
  /// Returns: The updated [Control]
  ///
  /// Throws: [ArgumentError] if control not found or validation fails
  _i2.Future<_i4.Control> updateControl({
    required int controlId,
    String? name,
    String? controlType,
    String? config,
    int? position,
    int? actionId,
    required bool clearActionId,
  }) =>
      caller.callServerEndpoint<_i4.Control>(
        'control',
        'updateControl',
        {
          'controlId': controlId,
          'name': name,
          'controlType': controlType,
          'config': config,
          'position': position,
          'actionId': actionId,
          'clearActionId': clearActionId,
        },
      );

  /// Delete a control
  ///
  /// Permanently deletes a control from the database.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [controlId]: ID of the control to delete
  ///
  /// Returns: true if deleted, false if not found
  _i2.Future<bool> deleteControl({required int controlId}) =>
      caller.callServerEndpoint<bool>(
        'control',
        'deleteControl',
        {'controlId': controlId},
      );

  /// Reorder controls for a user
  ///
  /// Updates the position field for multiple controls at once.
  /// This is useful for drag-and-drop reordering in the UI.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [userId]: ID of the user whose controls to reorder
  /// - [controlPositions]: Map of control ID to new position
  ///
  /// Returns: List of updated controls ordered by position
  ///
  /// Throws: [ArgumentError] if any control is not found or doesn't belong to user
  _i2.Future<List<_i4.Control>> reorderControls({
    required int userId,
    required Map<int, int> controlPositions,
  }) =>
      caller.callServerEndpoint<List<_i4.Control>>(
        'control',
        'reorderControls',
        {
          'userId': userId,
          'controlPositions': controlPositions,
        },
      );
}

/// Endpoint for managing events (triggered by controls or webhooks).
///
/// Provides methods to send, list, and retrieve events.
/// {@category Endpoint}
class EndpointEvent extends _i1.EndpointRef {
  EndpointEvent(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'event';

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
  _i2.Future<_i5.Event> sendEvent({
    required String sourceType,
    required String sourceId,
    required String eventType,
    String? payload,
  }) =>
      caller.callServerEndpoint<_i5.Event>(
        'event',
        'sendEvent',
        {
          'sourceType': sourceType,
          'sourceId': sourceId,
          'eventType': eventType,
          'payload': payload,
        },
      );

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
  _i2.Future<List<_i5.Event>> listEvents({
    required int limit,
    required int offset,
    String? sourceType,
    String? eventType,
    DateTime? since,
  }) =>
      caller.callServerEndpoint<List<_i5.Event>>(
        'event',
        'listEvents',
        {
          'limit': limit,
          'offset': offset,
          'sourceType': sourceType,
          'eventType': eventType,
          'since': since,
        },
      );

  /// Get a specific event by ID.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [eventId]: The ID of the event to retrieve
  ///
  /// Returns: The [Event] if found and owned by the user.
  ///
  /// Throws: [ArgumentError] if event not found or not owned by user.
  _i2.Future<_i5.Event> getEvent({required int eventId}) =>
      caller.callServerEndpoint<_i5.Event>(
        'event',
        'getEvent',
        {'eventId': eventId},
      );

  /// Delete an event by ID.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [eventId]: The ID of the event to delete
  ///
  /// Returns: True if the event was deleted.
  _i2.Future<bool> deleteEvent({required int eventId}) =>
      caller.callServerEndpoint<bool>(
        'event',
        'deleteEvent',
        {'eventId': eventId},
      );

  /// Get event counts by source type for the authenticated user.
  ///
  /// Useful for dashboard statistics.
  _i2.Future<Map<String, int>> getEventCounts({DateTime? since}) =>
      caller.callServerEndpoint<Map<String, int>>(
        'event',
        'getEventCounts',
        {'since': since},
      );
}

/// Endpoint for managing notification topics and sending notifications.
///
/// Notification topics are used to receive external webhooks and route
/// notifications to users. Each topic has a unique API key for authentication.
/// {@category Endpoint}
class EndpointNotification extends _i1.EndpointRef {
  EndpointNotification(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'notification';

  /// Create a new notification topic.
  ///
  /// Generates a unique API key for webhook authentication.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [name]: Display name for the topic
  /// - [description]: Optional description
  /// - [config]: Optional configuration as JSON string
  ///
  /// Returns: The created [NotificationTopic] with generated API key.
  _i2.Future<_i6.NotificationTopic> createTopic({
    required String name,
    String? description,
    String? config,
  }) =>
      caller.callServerEndpoint<_i6.NotificationTopic>(
        'notification',
        'createTopic',
        {
          'name': name,
          'description': description,
          'config': config,
        },
      );

  /// List all notification topics for the authenticated user.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [includeDisabled]: Include disabled topics (default: false)
  ///
  /// Returns: List of [NotificationTopic] objects.
  _i2.Future<List<_i6.NotificationTopic>> listTopics(
          {required bool includeDisabled}) =>
      caller.callServerEndpoint<List<_i6.NotificationTopic>>(
        'notification',
        'listTopics',
        {'includeDisabled': includeDisabled},
      );

  /// Get a specific notification topic by ID.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [topicId]: The ID of the topic to retrieve
  ///
  /// Returns: The [NotificationTopic] if found and owned by user.
  _i2.Future<_i6.NotificationTopic> getTopic({required int topicId}) =>
      caller.callServerEndpoint<_i6.NotificationTopic>(
        'notification',
        'getTopic',
        {'topicId': topicId},
      );

  /// Update an existing notification topic.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [topicId]: The ID of the topic to update
  /// - [name]: New name (optional)
  /// - [description]: New description (optional)
  /// - [enabled]: New enabled state (optional)
  /// - [config]: New configuration (optional)
  ///
  /// Returns: The updated [NotificationTopic].
  _i2.Future<_i6.NotificationTopic> updateTopic({
    required int topicId,
    String? name,
    String? description,
    bool? enabled,
    String? config,
  }) =>
      caller.callServerEndpoint<_i6.NotificationTopic>(
        'notification',
        'updateTopic',
        {
          'topicId': topicId,
          'name': name,
          'description': description,
          'enabled': enabled,
          'config': config,
        },
      );

  /// Delete a notification topic.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [topicId]: The ID of the topic to delete
  ///
  /// Returns: True if the topic was deleted.
  _i2.Future<bool> deleteTopic({required int topicId}) =>
      caller.callServerEndpoint<bool>(
        'notification',
        'deleteTopic',
        {'topicId': topicId},
      );

  /// Regenerate the API key for a topic.
  ///
  /// The old API key will immediately stop working.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [topicId]: The ID of the topic
  ///
  /// Returns: The [NotificationTopic] with new API key.
  _i2.Future<_i6.NotificationTopic> regenerateApiKey({required int topicId}) =>
      caller.callServerEndpoint<_i6.NotificationTopic>(
        'notification',
        'regenerateApiKey',
        {'topicId': topicId},
      );

  /// Send a notification to a specific user.
  ///
  /// This is for internal use (e.g., system notifications).
  /// External notifications should come through the webhook endpoint.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [title]: Notification title
  /// - [body]: Notification body
  /// - [payload]: Optional additional data as JSON string
  /// - [priority]: Notification priority (low, normal, high, urgent)
  ///
  /// Returns: True if the notification was queued for delivery.
  _i2.Future<bool> sendNotification({
    required String title,
    required String body,
    String? payload,
    required String priority,
  }) =>
      caller.callServerEndpoint<bool>(
        'notification',
        'sendNotification',
        {
          'title': title,
          'body': body,
          'payload': payload,
          'priority': priority,
        },
      );
}

/// Endpoint for real-time notification streaming via WebSocket.
///
/// This endpoint uses Serverpod's built-in streaming support to deliver
/// notifications to connected clients in real-time (Tier 1 delivery).
///
/// Usage:
/// ```dart
/// // In Flutter client
/// final stream = client.notificationStream.streamNotifications();
/// await for (final notification in stream) {
///   print('Received: ${notification.title}');
/// }
/// ```
/// {@category Endpoint}
class EndpointNotificationStream extends _i1.EndpointRef {
  EndpointNotificationStream(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'notificationStream';

  /// Stream notifications to the connected client.
  ///
  /// This method establishes a WebSocket connection and streams
  /// notifications to the authenticated user in real-time.
  ///
  /// The stream remains open until the client disconnects or
  /// the server closes the connection.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Stream<_i7.StreamNotification> streamNotifications() =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i7.StreamNotification>,
          _i7.StreamNotification>(
        'notificationStream',
        'streamNotifications',
        {},
        {},
      );

  /// Get the current connection status for the authenticated user.
  ///
  /// Returns the number of active WebSocket connections for this user.
  _i2.Future<int> getConnectionCount() => caller.callServerEndpoint<int>(
        'notificationStream',
        'getConnectionCount',
        {},
      );

  /// Send a test notification to the authenticated user.
  ///
  /// This is useful for testing the notification stream.
  /// Returns the number of connections that received the notification.
  _i2.Future<int> sendTestNotification({
    required String title,
    required String body,
  }) =>
      caller.callServerEndpoint<int>(
        'notificationStream',
        'sendTestNotification',
        {
          'title': title,
          'body': body,
        },
      );
}

/// Serverpod endpoint for OpenAPI specification parsing.
///
/// Provides methods to parse OpenAPI specifications from URLs
/// and extract operation information.
/// {@category Endpoint}
class EndpointOpenApi extends _i1.EndpointRef {
  EndpointOpenApi(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'openApi';

  /// Parse OpenAPI spec from URL
  ///
  /// Fetches and parses an OpenAPI specification from the provided URL.
  /// Supports OpenAPI 3.0, 3.1, and Swagger 2.0 in JSON format.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [url]: The URL of the OpenAPI specification (JSON format)
  ///
  /// Returns: [protocol.OpenApiSpec] containing the parsed specification
  ///
  /// Throws: [OpenApiParseException] if parsing fails
  _i2.Future<_i8.OpenApiSpec> parseSpec(String url) =>
      caller.callServerEndpoint<_i8.OpenApiSpec>(
        'openApi',
        'parseSpec',
        {'url': url},
      );

  /// List operations from spec
  ///
  /// Fetches an OpenAPI specification from the URL and returns
  /// all operations (endpoints) defined in the specification.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [specUrl]: The URL of the OpenAPI specification
  ///
  /// Returns: List of [protocol.OpenApiOperation] containing all operations
  ///
  /// Throws: [OpenApiParseException] if parsing fails
  _i2.Future<List<_i9.OpenApiOperation>> listOperations(String specUrl) =>
      caller.callServerEndpoint<List<_i9.OpenApiOperation>>(
        'openApi',
        'listOperations',
        {'specUrl': specUrl},
      );
}

/// Endpoint for managing UnifiedPush/WebPush subscriptions.
///
/// This endpoint allows clients to register push endpoints (from UnifiedPush
/// distributors like ntfy, FCM, NextPush, etc.) and manage their subscriptions.
///
/// See docs/PUSH_NOTIFICATION_DESIGN.md for the complete architecture.
///
/// Usage:
/// ```dart
/// // Register a new push endpoint
/// final subscription = await client.pushSubscription.registerEndpoint(
///   endpoint: 'https://ntfy.sh/ABC123',
///   p256dh: 'base64-encoded-public-key',
///   authSecret: 'base64-encoded-auth-secret',
///   deliveryMethod: 'webpush',
/// );
///
/// // List all subscriptions
/// final subscriptions = await client.pushSubscription.listSubscriptions();
///
/// // Disable a subscription
/// await client.pushSubscription.updateSubscription(
///   subscriptionId: 1,
///   enabled: false,
/// );
/// ```
/// {@category Endpoint}
class EndpointPushSubscription extends _i1.EndpointRef {
  EndpointPushSubscription(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'pushSubscription';

  /// Register a push endpoint (from UnifiedPush).
  ///
  /// When a Flutter client registers with a UnifiedPush distributor,
  /// it receives an endpoint URL. This method stores that endpoint
  /// so the server can send push notifications to it.
  ///
  /// [endpoint] - The push endpoint URL from the UnifiedPush distributor
  /// [p256dh] - Optional P-256 public key for WebPush encryption (base64url)
  /// [authSecret] - Optional authentication secret for WebPush (base64url)
  /// [subscriptionType] - The subscription type: 'unifiedpush' or 'webpush'
  /// [deviceId] - Unique identifier for the device
  /// [userAgent] - Optional user agent string
  ///
  /// Returns the registered subscription.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if subscriptionType is invalid.
  _i2.Future<_i10.PushSubscription> registerEndpoint({
    required String endpoint,
    String? p256dh,
    String? authSecret,
    required String subscriptionType,
    required String deviceId,
    String? userAgent,
  }) =>
      caller.callServerEndpoint<_i10.PushSubscription>(
        'pushSubscription',
        'registerEndpoint',
        {
          'endpoint': endpoint,
          'p256dh': p256dh,
          'authSecret': authSecret,
          'subscriptionType': subscriptionType,
          'deviceId': deviceId,
          'userAgent': userAgent,
        },
      );

  /// Unregister a push endpoint.
  ///
  /// Removes the specified device's endpoint from the user's subscriptions.
  /// This should be called when:
  /// - User explicitly disables push notifications
  /// - UnifiedPush distributor is uninstalled
  /// - Endpoint becomes invalid
  ///
  /// [deviceId] - The device ID to unregister
  ///
  /// Returns true if the endpoint was found and removed, false otherwise.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Future<bool> unregisterEndpoint(String deviceId) =>
      caller.callServerEndpoint<bool>(
        'pushSubscription',
        'unregisterEndpoint',
        {'deviceId': deviceId},
      );

  /// List subscriptions for the current user.
  ///
  /// Returns all push subscriptions (both active and disabled)
  /// for the authenticated user.
  ///
  /// Returns an empty list if the user has no subscriptions.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Future<List<_i10.PushSubscription>> listSubscriptions() =>
      caller.callServerEndpoint<List<_i10.PushSubscription>>(
        'pushSubscription',
        'listSubscriptions',
        {},
      );

  /// Update a subscription (enable/disable).
  ///
  /// Allows toggling subscriptions on/off without removing them.
  /// Useful for temporary notification silencing.
  ///
  /// [subscriptionId] - The ID of the subscription to update
  /// [active] - Whether the subscription should be active
  ///
  /// Returns the updated subscription.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [StateError] if the subscription doesn't exist or belongs to another user.
  _i2.Future<_i10.PushSubscription> updateSubscription(
    int subscriptionId, {
    bool? active,
  }) =>
      caller.callServerEndpoint<_i10.PushSubscription>(
        'pushSubscription',
        'updateSubscription',
        {
          'subscriptionId': subscriptionId,
          'active': active,
        },
      );
}

/// SSE endpoint wrapper for Serverpod endpoint pattern
///
/// This provides a Serverpod endpoint interface for SSE functionality.
/// Note: Actual SSE streaming requires the custom SseHandler above.
/// {@category Endpoint}
class EndpointSse extends _i1.EndpointRef {
  EndpointSse(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'sse';

  /// Get SSE connection info for the authenticated user.
  ///
  /// Returns the SSE endpoint URL and authentication token.
  _i2.Future<Map<String, dynamic>> getConnectionInfo() =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'sse',
        'getConnectionInfo',
        {},
      );

  /// Get queued notifications for SSE pickup.
  ///
  /// This is used when the client connects and wants to retrieve
  /// any notifications that were queued while disconnected.
  _i2.Future<List<Map<String, dynamic>>> getQueuedNotifications() =>
      caller.callServerEndpoint<List<Map<String, dynamic>>>(
        'sse',
        'getQueuedNotifications',
        {},
      );
}

/// Serverpod endpoint for webhook management
///
/// This provides authenticated methods for managing webhooks.
/// {@category Endpoint}
class EndpointWebhook extends _i1.EndpointRef {
  EndpointWebhook(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'webhook';

  /// Get webhook URL for a topic
  _i2.Future<String> getWebhookUrl(int topicId) =>
      caller.callServerEndpoint<String>(
        'webhook',
        'getWebhookUrl',
        {'topicId': topicId},
      );

  /// Test webhook endpoint for development/testing.
  ///
  /// This is a convenience endpoint to test webhook delivery without
  /// making actual HTTP requests. Returns a success response with the
  /// test notification details.
  ///
  /// **Note**: This is for testing only and may be removed in production.
  _i2.Future<Map<String, dynamic>> testWebhook(
    int topicId, {
    required String title,
    required String body,
  }) =>
      caller.callServerEndpoint<Map<String, dynamic>>(
        'webhook',
        'testWebhook',
        {
          'topicId': topicId,
          'title': title,
          'body': body,
        },
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i11.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i11.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i12.Caller(client);
  }

  late final _i12.Caller auth;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i13.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    action = EndpointAction(this);
    control = EndpointControl(this);
    event = EndpointEvent(this);
    notification = EndpointNotification(this);
    notificationStream = EndpointNotificationStream(this);
    openApi = EndpointOpenApi(this);
    pushSubscription = EndpointPushSubscription(this);
    sse = EndpointSse(this);
    webhook = EndpointWebhook(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointAction action;

  late final EndpointControl control;

  late final EndpointEvent event;

  late final EndpointNotification notification;

  late final EndpointNotificationStream notificationStream;

  late final EndpointOpenApi openApi;

  late final EndpointPushSubscription pushSubscription;

  late final EndpointSse sse;

  late final EndpointWebhook webhook;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'action': action,
        'control': control,
        'event': event,
        'notification': notification,
        'notificationStream': notificationStream,
        'openApi': openApi,
        'pushSubscription': pushSubscription,
        'sse': sse,
        'webhook': webhook,
        'greeting': greeting,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
