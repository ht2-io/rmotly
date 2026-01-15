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
import 'package:remotly_client/src/protocol/openapi_spec.dart' as _i3;
import 'package:remotly_client/src/protocol/openapi_operation.dart' as _i4;
import 'package:remotly_client/src/protocol/greeting.dart' as _i5;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i6;
import 'protocol.dart' as _i7;

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
  _i2.Future<_i3.OpenApiSpec> parseSpec(String url) =>
      caller.callServerEndpoint<_i3.OpenApiSpec>(
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
  _i2.Future<List<_i4.OpenApiOperation>> listOperations(String specUrl) =>
      caller.callServerEndpoint<List<_i4.OpenApiOperation>>(
        'openApi',
        'listOperations',
        {'specUrl': specUrl},
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
    openApi = EndpointOpenApi(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointOpenApi openApi;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'openApi': openApi,
        'greeting': greeting,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
