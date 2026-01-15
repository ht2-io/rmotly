import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Push notification delivery method
enum DeliveryMethod {
  /// Real-time WebSocket streaming (foreground)
  websocket,

  /// WebPush via UnifiedPush distributor (background)
  webpush,

  /// Server-Sent Events fallback (restricted networks)
  sse,
}

/// Push notification received from any delivery method
class PushNotification {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime receivedAt;
  final DeliveryMethod deliveryMethod;

  PushNotification({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    this.imageUrl,
    this.actionUrl,
    required this.receivedAt,
    required this.deliveryMethod,
  });

  factory PushNotification.fromJson(
    Map<String, dynamic> json,
    DeliveryMethod method,
  ) {
    return PushNotification(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      receivedAt: DateTime.now(),
      deliveryMethod: method,
    );
  }
}

/// State of the push service
class PushServiceState {
  final bool isInitialized;
  final String? unifiedPushEndpoint;
  final bool isWebSocketConnected;
  final bool isSseConnected;
  final List<PushNotification> pendingNotifications;
  final String? error;

  const PushServiceState({
    this.isInitialized = false,
    this.unifiedPushEndpoint,
    this.isWebSocketConnected = false,
    this.isSseConnected = false,
    this.pendingNotifications = const [],
    this.error,
  });

  PushServiceState copyWith({
    bool? isInitialized,
    String? unifiedPushEndpoint,
    bool? isWebSocketConnected,
    bool? isSseConnected,
    List<PushNotification>? pendingNotifications,
    String? error,
  }) {
    return PushServiceState(
      isInitialized: isInitialized ?? this.isInitialized,
      unifiedPushEndpoint: unifiedPushEndpoint ?? this.unifiedPushEndpoint,
      isWebSocketConnected: isWebSocketConnected ?? this.isWebSocketConnected,
      isSseConnected: isSseConnected ?? this.isSseConnected,
      pendingNotifications: pendingNotifications ?? this.pendingNotifications,
      error: error,
    );
  }
}

/// Push service for handling notifications from multiple delivery methods.
///
/// Implements three-tier delivery:
/// 1. WebSocket (foreground) - real-time via Serverpod streaming
/// 2. WebPush (background) - via UnifiedPush distributor (ntfy)
/// 3. SSE (fallback) - for restricted networks
class PushService extends StateNotifier<PushServiceState> {
  PushService() : super(const PushServiceState());

  final _notificationController = StreamController<PushNotification>.broadcast();

  /// Stream of received notifications
  Stream<PushNotification> get notifications => _notificationController.stream;

  /// Initialize the push service
  Future<void> initialize() async {
    if (state.isInitialized) return;

    try {
      // Initialize UnifiedPush
      await _initializeUnifiedPush();

      // Initialize local notifications (for displaying)
      await _initializeLocalNotifications();

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize push service: $e');
      rethrow;
    }
  }

  /// Initialize UnifiedPush connector
  Future<void> _initializeUnifiedPush() async {
    // UnifiedPush initialization will be implemented when the package is added
    // For now, this is a placeholder that sets up the handlers
    debugPrint('PushService: UnifiedPush initialization placeholder');

    // The actual implementation will:
    // 1. Register UnifiedPush handlers (onNewEndpoint, onMessage, onUnregistered)
    // 2. Request registration with a distributor
    // 3. Send the endpoint URL to our API server
  }

  /// Initialize local notification display
  Future<void> _initializeLocalNotifications() async {
    // Local notifications initialization will be implemented when the package is added
    // For now, this is a placeholder
    debugPrint('PushService: Local notifications initialization placeholder');

    // The actual implementation will:
    // 1. Create Android notification channel
    // 2. Request notification permissions
    // 3. Set up notification tap handlers
  }

  /// Handle UnifiedPush endpoint registration
  Future<void> onUnifiedPushEndpoint(String endpoint) async {
    debugPrint('PushService: New UnifiedPush endpoint: $endpoint');
    state = state.copyWith(unifiedPushEndpoint: endpoint);

    // TODO: Send endpoint to API server for registration
    // await _apiClient.registerPushEndpoint(endpoint);
  }

  /// Handle incoming UnifiedPush message
  Future<void> onUnifiedPushMessage(String message) async {
    debugPrint('PushService: Received UnifiedPush message');

    try {
      final json = jsonDecode(message) as Map<String, dynamic>;
      final notification = PushNotification.fromJson(json, DeliveryMethod.webpush);

      _notificationController.add(notification);
      await _showLocalNotification(notification);
    } catch (e) {
      debugPrint('PushService: Failed to parse message: $e');
    }
  }

  /// Handle UnifiedPush unregistration
  Future<void> onUnifiedPushUnregistered() async {
    debugPrint('PushService: UnifiedPush unregistered');
    state = state.copyWith(unifiedPushEndpoint: null);

    // TODO: Notify API server of unregistration
    // await _apiClient.unregisterPushEndpoint();
  }

  /// Show a local notification
  Future<void> _showLocalNotification(PushNotification notification) async {
    // TODO: Implement with flutter_local_notifications
    debugPrint('PushService: Would show notification: ${notification.title}');
  }

  /// Connect to WebSocket stream for real-time notifications (foreground)
  Future<void> connectWebSocket() async {
    // TODO: Implement Serverpod streaming connection
    debugPrint('PushService: WebSocket connection placeholder');
    state = state.copyWith(isWebSocketConnected: true);
  }

  /// Disconnect from WebSocket stream
  Future<void> disconnectWebSocket() async {
    // TODO: Implement disconnect
    state = state.copyWith(isWebSocketConnected: false);
  }

  /// Connect to SSE endpoint (fallback)
  Future<void> connectSse(String baseUrl) async {
    // TODO: Implement SSE connection with flutter_client_sse
    debugPrint('PushService: SSE connection placeholder to $baseUrl');
    state = state.copyWith(isSseConnected: true);
  }

  /// Disconnect from SSE
  Future<void> disconnectSse() async {
    // TODO: Implement disconnect
    state = state.copyWith(isSseConnected: false);
  }

  /// Handle notification received via WebSocket
  void onWebSocketNotification(Map<String, dynamic> data) {
    final notification = PushNotification.fromJson(data, DeliveryMethod.websocket);
    _notificationController.add(notification);

    // In foreground, we might want to show an in-app notification
    // instead of a system notification
  }

  /// Handle notification received via SSE
  void onSseNotification(Map<String, dynamic> data) {
    final notification = PushNotification.fromJson(data, DeliveryMethod.sse);
    _notificationController.add(notification);
    _showLocalNotification(notification);
  }

  /// Request registration with UnifiedPush distributor
  Future<void> registerUnifiedPush() async {
    // TODO: Implement with unifiedpush package
    // UnifiedPush.registerApp(
    //   'remotly',
    //   features: ['message-encryption'],
    // );
  }

  /// Unregister from UnifiedPush
  Future<void> unregisterUnifiedPush() async {
    // TODO: Implement with unifiedpush package
    // UnifiedPush.unregister();
  }

  @override
  void dispose() {
    _notificationController.close();
    super.dispose();
  }
}

/// Provider for the push service
final pushServiceProvider =
    StateNotifierProvider<PushService, PushServiceState>((ref) {
  return PushService();
});

/// Stream provider for notifications
final notificationStreamProvider = StreamProvider<PushNotification>((ref) {
  final pushService = ref.watch(pushServiceProvider.notifier);
  return pushService.notifications;
});
