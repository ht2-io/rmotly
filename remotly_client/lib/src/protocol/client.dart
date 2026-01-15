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
import 'package:remotly_client/src/protocol/control.dart' as _i3;
import 'package:remotly_client/src/services/notification_stream_service.dart'
    as _i4;
import 'package:remotly_client/src/services/subscription_manager_service.dart'
    as _i5;
import 'package:remotly_client/src/protocol/greeting.dart' as _i6;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i7;
import 'protocol.dart' as _i8;

/// Endpoint for managing user controls.
///
/// This endpoint allows clients to create, read, update, delete, and reorder
/// controls on their dashboard. Controls are UI elements (buttons, toggles,
/// sliders, etc.) that can trigger actions.
///
/// Usage:
/// ```dart
/// // Create a new control
/// final control = await client.control.createControl(
///   name: 'Living Room Light',
///   controlType: 'toggle',
///   actionId: 42,
///   config: '{"color": "blue"}',
/// );
///
/// // List all controls
/// final controls = await client.control.listControls();
///
/// // Update a control
/// final updated = await client.control.updateControl(
///   controlId: 1,
///   name: 'Bedroom Light',
/// );
///
/// // Delete a control
/// await client.control.deleteControl(controlId: 1);
///
/// // Reorder controls
/// await client.control.reorderControls(controlIds: [3, 1, 2]);
/// ```
/// {@category Endpoint}
class EndpointControl extends _i1.EndpointRef {
  EndpointControl(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'control';

  /// Create a new control for the authenticated user.
  ///
  /// [name] - Display name for the control
  /// [controlType] - Type of control (button, toggle, slider, input, dropdown)
  /// [actionId] - Optional ID of the action triggered by this control
  /// [config] - Control configuration as JSON string
  /// [position] - Optional position/order in the dashboard. If not provided,
  ///              the control will be placed at the end (max position + 1)
  ///
  /// Returns the created [Control] with ID assigned.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if name or controlType is empty, or config is invalid.
  _i2.Future<_i3.Control> createControl({
    required String name,
    required String controlType,
    int? actionId,
    required String config,
    int? position,
  }) =>
      caller.callServerEndpoint<_i3.Control>(
        'control',
        'createControl',
        {
          'name': name,
          'controlType': controlType,
          'actionId': actionId,
          'config': config,
          'position': position,
        },
      );

  /// List all controls for the authenticated user.
  ///
  /// Returns a list of [Control]s ordered by position (ascending).
  /// Returns an empty list if the user has no controls.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Future<List<_i3.Control>> listControls() =>
      caller.callServerEndpoint<List<_i3.Control>>(
        'control',
        'listControls',
        {},
      );

  /// Get a specific control by ID.
  ///
  /// [controlId] - The ID of the control to retrieve
  ///
  /// Returns the [Control] if found and belongs to the authenticated user,
  /// or null if not found or doesn't belong to the user.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Future<_i3.Control?> getControl(int controlId) =>
      caller.callServerEndpoint<_i3.Control?>(
        'control',
        'getControl',
        {'controlId': controlId},
      );

  /// Update a control.
  ///
  /// [controlId] - The ID of the control to update
  /// [name] - Optional new display name
  /// [controlType] - Optional new control type
  /// [actionId] - Optional new action ID (use explicit null to remove action)
  /// [config] - Optional new configuration JSON string
  ///
  /// Returns the updated [Control], or null if the control was not found
  /// or doesn't belong to the authenticated user.
  ///
  /// Note: At least one parameter must be provided to update.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if no parameters are provided or validation fails.
  _i2.Future<_i3.Control?> updateControl(
    int controlId, {
    String? name,
    String? controlType,
    int? actionId,
    String? config,
  }) =>
      caller.callServerEndpoint<_i3.Control?>(
        'control',
        'updateControl',
        {
          'controlId': controlId,
          'name': name,
          'controlType': controlType,
          'actionId': actionId,
          'config': config,
        },
      );

  /// Delete a control.
  ///
  /// [controlId] - The ID of the control to delete
  ///
  /// Returns true if the control was deleted, false if not found
  /// or doesn't belong to the authenticated user.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Future<bool> deleteControl(int controlId) =>
      caller.callServerEndpoint<bool>(
        'control',
        'deleteControl',
        {'controlId': controlId},
      );

  /// Reorder controls by updating their position field.
  ///
  /// [controlIds] - List of control IDs in the desired order.
  ///                The first ID will have position 0, second will have position 1, etc.
  ///
  /// Returns true if all controls were reordered successfully.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if controlIds is empty or contains duplicates.
  /// Throws [StateError] if any control doesn't exist or doesn't belong to the user.
  _i2.Future<bool> reorderControls(List<int> controlIds) =>
      caller.callServerEndpoint<bool>(
        'control',
        'reorderControls',
        {'controlIds': controlIds},
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
  _i2.Stream<_i4.StreamNotification> streamNotifications() =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i4.StreamNotification>,
          _i4.StreamNotification>(
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
  /// [deliveryMethod] - The delivery method: 'webpush', 'sse', or 'websocket'
  ///
  /// Returns the registered subscription information.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if deliveryMethod is invalid.
  _i2.Future<_i5.PushSubscriptionInfo> registerEndpoint({
    required String endpoint,
    String? p256dh,
    String? authSecret,
    required String deliveryMethod,
  }) =>
      caller.callServerEndpoint<_i5.PushSubscriptionInfo>(
        'pushSubscription',
        'registerEndpoint',
        {
          'endpoint': endpoint,
          'p256dh': p256dh,
          'authSecret': authSecret,
          'deliveryMethod': deliveryMethod,
        },
      );

  /// Unregister a push endpoint.
  ///
  /// Removes the specified endpoint from the user's subscriptions.
  /// This should be called when:
  /// - User explicitly disables push notifications
  /// - UnifiedPush distributor is uninstalled
  /// - Endpoint becomes invalid
  ///
  /// [endpoint] - The endpoint URL to unregister
  ///
  /// Returns true if the endpoint was found and removed, false otherwise.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Future<bool> unregisterEndpoint(String endpoint) =>
      caller.callServerEndpoint<bool>(
        'pushSubscription',
        'unregisterEndpoint',
        {'endpoint': endpoint},
      );

  /// List subscriptions for the current user.
  ///
  /// Returns all push subscriptions (both active and disabled)
  /// for the authenticated user.
  ///
  /// Returns an empty list if the user has no subscriptions.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Future<List<_i5.PushSubscriptionInfo>> listSubscriptions() =>
      caller.callServerEndpoint<List<_i5.PushSubscriptionInfo>>(
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
  /// [enabled] - Whether the subscription should be enabled
  ///
  /// Returns the updated subscription information.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [StateError] if the subscription doesn't exist or belongs to another user.
  _i2.Future<_i5.PushSubscriptionInfo> updateSubscription(
    int subscriptionId, {
    bool? enabled,
  }) =>
      caller.callServerEndpoint<_i5.PushSubscriptionInfo>(
        'pushSubscription',
        'updateSubscription',
        {
          'subscriptionId': subscriptionId,
          'enabled': enabled,
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

  /// Test webhook endpoint
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
  _i2.Future<_i6.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i6.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i7.Caller(client);
  }

  late final _i7.Caller auth;
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
          _i8.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    control = EndpointControl(this);
    notificationStream = EndpointNotificationStream(this);
    pushSubscription = EndpointPushSubscription(this);
    sse = EndpointSse(this);
    webhook = EndpointWebhook(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointControl control;

  late final EndpointNotificationStream notificationStream;

  late final EndpointPushSubscription pushSubscription;

  late final EndpointSse sse;

  late final EndpointWebhook webhook;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'control': control,
        'notificationStream': notificationStream,
        'pushSubscription': pushSubscription,
        'sse': sse,
        'webhook': webhook,
        'greeting': greeting,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
