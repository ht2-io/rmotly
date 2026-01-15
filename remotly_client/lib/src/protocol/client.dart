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
import 'package:remotly_client/src/protocol/notification_topic.dart' as _i3;
import 'package:remotly_client/src/protocol/greeting.dart' as _i4;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i5;
import 'protocol.dart' as _i6;

/// Endpoint for managing notification topics.
///
/// This endpoint provides CRUD operations for notification topics,
/// which are used to receive external webhook notifications.
///
/// All methods require authentication and will throw [AuthenticationException]
/// if the user is not authenticated.
/// {@category Endpoint}
class EndpointNotification extends _i1.EndpointRef {
  EndpointNotification(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'notification';

  /// Create a notification topic.
  ///
  /// Creates a new topic for receiving webhook notifications.
  /// Automatically generates a secure API key for the topic.
  ///
  /// [name] - Display name for the topic (required)
  /// [description] - Optional description of what notifications this topic receives
  /// [config] - Optional JSON configuration string (defaults to '{}')
  ///
  /// Returns the created [NotificationTopic] with generated API key.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if name is empty.
  _i2.Future<_i3.NotificationTopic> createTopic({
    required String name,
    String? description,
    String? config,
  }) =>
      caller.callServerEndpoint<_i3.NotificationTopic>(
        'notification',
        'createTopic',
        {
          'name': name,
          'description': description,
          'config': config,
        },
      );

  /// List topics for current user.
  ///
  /// Returns all notification topics owned by the authenticated user,
  /// ordered by creation date (newest first).
  ///
  /// Returns an empty list if the user has no topics.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Future<List<_i3.NotificationTopic>> listTopics() =>
      caller.callServerEndpoint<List<_i3.NotificationTopic>>(
        'notification',
        'listTopics',
        {},
      );

  /// Get topic by ID.
  ///
  /// Returns the topic if it exists and belongs to the authenticated user.
  ///
  /// [topicId] - The ID of the topic to retrieve
  ///
  /// Returns the [NotificationTopic] if found, null otherwise.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Future<_i3.NotificationTopic?> getTopic(int topicId) =>
      caller.callServerEndpoint<_i3.NotificationTopic?>(
        'notification',
        'getTopic',
        {'topicId': topicId},
      );

  /// Update topic.
  ///
  /// Updates an existing topic. Only the provided fields will be updated.
  ///
  /// [topicId] - The ID of the topic to update
  /// [name] - Optional new name for the topic
  /// [description] - Optional new description (pass empty string to clear)
  /// [config] - Optional new JSON configuration string
  /// [enabled] - Optional enabled status
  ///
  /// Returns the updated [NotificationTopic].
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [StateError] if the topic doesn't exist or belongs to another user.
  /// Throws [ArgumentError] if name is provided but empty.
  _i2.Future<_i3.NotificationTopic> updateTopic(
    int topicId, {
    String? name,
    String? description,
    String? config,
    bool? enabled,
  }) =>
      caller.callServerEndpoint<_i3.NotificationTopic>(
        'notification',
        'updateTopic',
        {
          'topicId': topicId,
          'name': name,
          'description': description,
          'config': config,
          'enabled': enabled,
        },
      );

  /// Delete topic.
  ///
  /// Deletes a notification topic permanently.
  ///
  /// [topicId] - The ID of the topic to delete
  ///
  /// Returns true if the topic was deleted, false if it didn't exist.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  _i2.Future<bool> deleteTopic(int topicId) => caller.callServerEndpoint<bool>(
        'notification',
        'deleteTopic',
        {'topicId': topicId},
      );

  /// Regenerate API key for topic.
  ///
  /// Generates a new API key for the topic, invalidating the old one.
  /// This is useful if the key has been compromised.
  ///
  /// [topicId] - The ID of the topic to regenerate the key for
  ///
  /// Returns the new API key.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [StateError] if the topic doesn't exist or belongs to another user.
  _i2.Future<String> regenerateApiKey(int topicId) =>
      caller.callServerEndpoint<String>(
        'notification',
        'regenerateApiKey',
        {'topicId': topicId},
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
  _i2.Future<_i4.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i4.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i5.Caller(client);
  }

  late final _i5.Caller auth;
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
          _i6.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    notification = EndpointNotification(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointNotification notification;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'notification': notification,
        'greeting': greeting,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
