import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:rmotly_client/rmotly_client.dart';

import 'server_config_provider.dart';

/// Provider for the Serverpod client
///
/// This client is used to communicate with the Rmotly API server.
/// The URL is loaded from server configuration (user-configurable).
/// Returns null if server is not configured yet.
final apiClientProvider = Provider<Client?>((ref) {
  final serverConfig = ref.watch(serverConfigProvider);

  // Don't create client if server URL is not configured
  if (!serverConfig.isConfigured || serverConfig.serverUrl == null) {
    return null;
  }

  final client = Client(serverConfig.serverUrl!)
    ..connectivityMonitor = FlutterConnectivityMonitor();
  return client;
});

/// Provider for the Serverpod session manager
///
/// The SessionManager handles user authentication state and session persistence.
/// It must be initialized before use.
/// Returns null if API client is not available.
final sessionManagerProvider = Provider<SessionManager?>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client == null) return null;
  return SessionManager(caller: client.modules.auth);
});
