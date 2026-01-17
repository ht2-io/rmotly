import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum representing connectivity status
enum ConnectivityStatus {
  /// Connected to the internet
  online,

  /// Not connected to the internet
  offline,

  /// Connectivity status is unknown
  unknown,
}

/// Service for monitoring network connectivity.
///
/// This service provides a simple connectivity monitoring implementation.
/// In a production app, this would integrate with a package like connectivity_plus.
class ConnectivityService {
  final _statusController = StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.online;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Whether the device is currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  /// Whether the device is currently offline
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  ConnectivityService() {
    // Start with online status as default
    // In a real implementation, this would check actual connectivity
    _currentStatus = ConnectivityStatus.online;
  }

  /// Manually update connectivity status (for testing or manual control)
  void updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(_currentStatus);
    }
  }

  /// Dispose of resources
  void dispose() {
    _statusController.close();
  }
}

/// Provider for the connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider for the current connectivity status
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

/// Provider for checking if the device is online
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityStatus = ref.watch(connectivityStatusProvider);
  return connectivityStatus.maybeWhen(
    data: (status) => status == ConnectivityStatus.online,
    orElse: () => true, // Default to online
  );
});
