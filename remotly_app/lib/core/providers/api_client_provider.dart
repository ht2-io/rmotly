import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:remotly_client/remotly_client.dart';

/// Provider for the Serverpod client
///
/// This client is used to communicate with the Remotly API server.
/// The base URL should be updated based on the environment (development, staging, production).
final apiClientProvider = Provider<Client>((ref) {
  // TODO: Update this URL based on environment
  final baseUrl = 'http://$localhost:8080/';

  return Client(baseUrl)..connectivityMonitor = FlutterConnectivityMonitor();
});
