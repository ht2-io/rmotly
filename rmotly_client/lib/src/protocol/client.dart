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
import 'package:rmotly_client/src/services/notification_stream_service.dart'
    as _i3;
import 'package:rmotly_client/src/protocol/openapi_spec.dart' as _i4;
import 'package:rmotly_client/src/protocol/openapi_operation.dart' as _i5;
import 'package:rmotly_client/src/services/subscription_manager_service.dart'
    as _i6;
import 'package:rmotly_client/src/protocol/greeting.dart' as _i7;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i8;
import 'protocol.dart' as _i9;

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
  _i2.Stream<_i3.StreamNotification> streamNotifications() =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i3.StreamNotification>,
          _i3.StreamNotification>(
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
  _i2.Future<_i4.OpenApiSpec> parseSpec(String url) =>
      caller.callServerEndpoint<_i4.OpenApiSpec>(
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
  _i2.Future<List<_i5.OpenApiOperation>> listOperations(String specUrl) =>
      caller.callServerEndpoint<List<_i5.OpenApiOperation>>(
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
  /// [deliveryMethod] - The delivery method: 'webpush', 'sse', or 'websocket'
  ///
  /// Returns the registered subscription information.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if deliveryMethod is invalid.
  _i2.Future<_i6.PushSubscriptionInfo> registerEndpoint({
    required String endpoint,
    String? p256dh,
    String? authSecret,
    required String deliveryMethod,
  }) =>
      caller.callServerEndpoint<_i6.PushSubscriptionInfo>(
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
  _i2.Future<List<_i6.PushSubscriptionInfo>> listSubscriptions() =>
      caller.callServerEndpoint<List<_i6.PushSubscriptionInfo>>(
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
  _i2.Future<_i6.PushSubscriptionInfo> updateSubscription(
    int subscriptionId, {
    bool? enabled,
  }) =>
      caller.callServerEndpoint<_i6.PushSubscriptionInfo>(
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
  _i2.Future<_i7.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i7.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i8.Caller(client);
  }

  late final _i8.Caller auth;
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
          _i9.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    notificationStream = EndpointNotificationStream(this);
    openApi = EndpointOpenApi(this);
    pushSubscription = EndpointPushSubscription(this);
    sse = EndpointSse(this);
    webhook = EndpointWebhook(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointNotificationStream notificationStream;

  late final EndpointOpenApi openApi;

  late final EndpointPushSubscription pushSubscription;

  late final EndpointSse sse;

  late final EndpointWebhook webhook;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
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
