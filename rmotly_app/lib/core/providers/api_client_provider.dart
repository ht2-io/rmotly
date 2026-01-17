import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:rmotly_client/rmotly_client.dart';

/// Provider for the Serverpod client
///
/// This client is used to communicate with the Rmotly API server.
/// The base URL should be updated based on the environment (development, staging, production).
final apiClientProvider = Provider<Client>((ref) {
  // TODO: Update this URL based on environment
  const baseUrl = 'http://localhost:8080/';
  final client = Client(baseUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor();
  return client;
});

/// Provider for the Serverpod session manager
///
/// The SessionManager handles user authentication state and session persistence.
/// It must be initialized before use.
final sessionManagerProvider = Provider<SessionManager>((ref) {
  final client = ref.watch(apiClientProvider);
  return SessionManager(caller: client.modules.auth);
});
