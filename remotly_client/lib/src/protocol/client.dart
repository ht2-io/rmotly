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
import 'package:remotly_client/src/protocol/event_response.dart' as _i3;
import 'package:remotly_client/src/protocol/event.dart' as _i4;
import 'package:remotly_client/src/protocol/greeting.dart' as _i5;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i6;
import 'protocol.dart' as _i7;

/// Endpoint for event management.
///
/// This endpoint handles:
/// - Sending events from controls
/// - Listing events for the authenticated user
/// - Retrieving individual events by ID
/// {@category Endpoint}
class EndpointEvent extends _i1.EndpointRef {
  EndpointEvent(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'event';

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
  _i2.Future<_i3.EventResponse> sendEvent({
    required String controlId,
    required String eventType,
    String? payload,
  }) =>
      caller.callServerEndpoint<_i3.EventResponse>(
        'event',
        'sendEvent',
        {
          'controlId': controlId,
          'eventType': eventType,
          'payload': payload,
        },
      );

  /// List events for current user
  ///
  /// [limit] - Maximum number of events to return (default: 50, max: 100)
  /// [offset] - Number of events to skip for pagination (default: 0)
  ///
  /// Returns a list of events for the authenticated user.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if limit is invalid.
  _i2.Future<List<_i4.Event>> listEvents({
    required int limit,
    required int offset,
  }) =>
      caller.callServerEndpoint<List<_i4.Event>>(
        'event',
        'listEvents',
        {
          'limit': limit,
          'offset': offset,
        },
      );

  /// Get event by ID
  ///
  /// [eventId] - The ID of the event to retrieve
  ///
  /// Returns the event if found and belongs to the authenticated user,
  /// null otherwise.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if eventId is invalid.
  _i2.Future<_i4.Event?> getEvent(int eventId) =>
      caller.callServerEndpoint<_i4.Event?>(
        'event',
        'getEvent',
        {'eventId': eventId},
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
  _i2.Future<_i5.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i5.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i6.Caller(client);
  }

  late final _i6.Caller auth;
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
          _i7.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    event = EndpointEvent(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEvent event;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'event': event,
        'greeting': greeting,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
