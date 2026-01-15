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
import 'package:remotly_client/src/protocol/action.dart' as _i3;
import 'package:remotly_client/src/protocol/action_test_result.dart' as _i4;
import 'package:remotly_client/src/protocol/greeting.dart' as _i5;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i6;
import 'protocol.dart' as _i7;

/// Serverpod endpoint for action management.
///
/// Provides CRUD operations for actions and functionality to test
/// actions and import them from OpenAPI specifications.
/// {@category Endpoint}
class EndpointAction extends _i1.EndpointRef {
  EndpointAction(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'action';

  /// Create a new action
  ///
  /// Creates an action owned by the current user.
  /// The action can be triggered by controls or events.
  ///
  /// Returns the created [Action] with generated ID.
  _i2.Future<_i3.Action> createAction({
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
          'name': name,
          'httpMethod': httpMethod,
          'urlTemplate': urlTemplate,
          'description': description,
          'headersTemplate': headersTemplate,
          'bodyTemplate': bodyTemplate,
          'parameters': parameters,
        },
      );

  /// List all actions for the current user
  ///
  /// Returns a list of actions owned by the authenticated user,
  /// ordered by creation date (newest first).
  _i2.Future<List<_i3.Action>> listActions() =>
      caller.callServerEndpoint<List<_i3.Action>>(
        'action',
        'listActions',
        {},
      );

  /// Get a specific action by ID
  ///
  /// Returns the action if it exists and belongs to the current user,
  /// or null if not found.
  _i2.Future<_i3.Action?> getAction(int actionId) =>
      caller.callServerEndpoint<_i3.Action?>(
        'action',
        'getAction',
        {'actionId': actionId},
      );

  /// Update an existing action
  ///
  /// Updates the specified action with the provided fields.
  /// Only fields that are non-null will be updated.
  ///
  /// Returns the updated action, or throws if not found or not authorized.
  _i2.Future<_i3.Action> updateAction(
    int actionId, {
    String? name,
    String? httpMethod,
    String? urlTemplate,
    String? description,
    String? headersTemplate,
    String? bodyTemplate,
    String? parameters,
  }) =>
      caller.callServerEndpoint<_i3.Action>(
        'action',
        'updateAction',
        {
          'actionId': actionId,
          'name': name,
          'httpMethod': httpMethod,
          'urlTemplate': urlTemplate,
          'description': description,
          'headersTemplate': headersTemplate,
          'bodyTemplate': bodyTemplate,
          'parameters': parameters,
        },
      );

  /// Delete an action
  ///
  /// Deletes the specified action if it belongs to the current user.
  ///
  /// Returns true if deleted successfully, false if not found or not authorized.
  _i2.Future<bool> deleteAction(int actionId) =>
      caller.callServerEndpoint<bool>(
        'action',
        'deleteAction',
        {'actionId': actionId},
      );

  /// Test action execution
  ///
  /// Executes the action with the provided parameters and returns
  /// detailed test results including the resolved URL, headers, body,
  /// and the actual HTTP response.
  ///
  /// This does not save the execution result, it's purely for testing.
  _i2.Future<_i4.ActionTestResult> testAction(
    int actionId, {
    String? parameters,
  }) =>
      caller.callServerEndpoint<_i4.ActionTestResult>(
        'action',
        'testAction',
        {
          'actionId': actionId,
          'parameters': parameters,
        },
      );

  /// Create action from OpenAPI operation
  ///
  /// Fetches an OpenAPI specification from the given URL,
  /// finds the specified operation, and creates an action from it.
  ///
  /// The action will be pre-configured with the correct HTTP method,
  /// URL template with parameter placeholders, headers, and body template.
  ///
  /// Returns the created [Action].
  _i2.Future<_i3.Action> createFromOpenApi({
    required String specUrl,
    required String operationId,
  }) =>
      caller.callServerEndpoint<_i3.Action>(
        'action',
        'createFromOpenApi',
        {
          'specUrl': specUrl,
          'operationId': operationId,
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
    action = EndpointAction(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointAction action;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'action': action,
        'greeting': greeting,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
