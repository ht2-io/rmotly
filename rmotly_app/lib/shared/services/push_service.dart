import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';

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
    bool clearUnifiedPushEndpoint = false,
    bool clearError = false,
  }) {
    return PushServiceState(
      isInitialized: isInitialized ?? this.isInitialized,
      unifiedPushEndpoint: clearUnifiedPushEndpoint ? null : (unifiedPushEndpoint ?? this.unifiedPushEndpoint),
      isWebSocketConnected: isWebSocketConnected ?? this.isWebSocketConnected,
      isSseConnected: isSseConnected ?? this.isSseConnected,
      pendingNotifications: pendingNotifications ?? this.pendingNotifications,
      error: clearError ? null : (error ?? this.error),
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
  final _localNotifications = FlutterLocalNotificationsPlugin();
  StreamSubscription<SSEModel>? _sseSubscription;

  /// Stream of received notifications
  Stream<PushNotification> get notifications => _notificationController.stream;

  /// Initialize the push service
  Future<void> initialize() async {
    if (state.isInitialized) return;

    try {
      // Initialize local notifications first
      await _initializeLocalNotifications();

      // Initialize UnifiedPush handlers
      await _initializeUnifiedPush();

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize push service: $e');
      rethrow;
    }
  }

  /// Initialize UnifiedPush connector
  Future<void> _initializeUnifiedPush() async {
    debugPrint('PushService: Initializing UnifiedPush');

    // Register UnifiedPush callbacks (synchronous callbacks)
    await UnifiedPush.initialize(
      onNewEndpoint: (String endpoint, String instance) {
        debugPrint('PushService: New UnifiedPush endpoint: $endpoint (instance: $instance)');
        // Call async handler in a separate execution context
        onUnifiedPushEndpoint(endpoint);
      },
      onMessage: (Uint8List message, String instance) {
        debugPrint('PushService: Received UnifiedPush message (instance: $instance)');
        // Decode and handle message
        final messageStr = utf8.decode(message);
        onUnifiedPushMessage(messageStr);
      },
      onUnregistered: (String instance) {
        debugPrint('PushService: UnifiedPush unregistered (instance: $instance)');
        onUnifiedPushUnregistered();
      },
      onRegistrationFailed: (String instance) {
        debugPrint('PushService: UnifiedPush registration failed (instance: $instance)');
        state = state.copyWith(error: 'UnifiedPush registration failed');
      },
    );
  }

  /// Initialize local notification display
  Future<void> _initializeLocalNotifications() async {
    debugPrint('PushService: Initializing local notifications');

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    await _createNotificationChannel();
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'rmotly_notifications', // channel ID
      'Rmotly Notifications', // channel name
      description: 'Notifications from Rmotly controls and actions',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('PushService: Created notification channel');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('PushService: Notification tapped: ${response.payload}');
    // TODO: Handle notification tap navigation
    // Could parse the payload and navigate to specific screens
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
    state = state.copyWith(clearUnifiedPushEndpoint: true);

    // TODO: Notify API server of unregistration
    // await _apiClient.unregisterPushEndpoint();
  }

  /// Show a local notification
  Future<void> _showLocalNotification(PushNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'rmotly_notifications',
      'Rmotly Notifications',
      channelDescription: 'Notifications from Rmotly controls and actions',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(notification.data ?? {}),
    );

    debugPrint('PushService: Displayed notification: ${notification.title}');
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
    try {
      debugPrint('PushService: Connecting to SSE endpoint: $baseUrl/notifications/sse');

      // Close existing connection if any
      await disconnectSse();

      // Subscribe to SSE stream
      _sseSubscription = SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: '$baseUrl/notifications/sse',
        header: {
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
          // TODO: Add authorization header when auth is implemented
          // 'Authorization': 'Bearer $token',
        },
      ).listen(
        (event) {
          debugPrint('PushService: SSE event received: ${event.data}');
          try {
            final json = jsonDecode(event.data!) as Map<String, dynamic>;
            onSseNotification(json);
          } catch (e) {
            debugPrint('PushService: Failed to parse SSE message: $e');
          }
        },
        onError: (error) {
          debugPrint('PushService: SSE error: $error');
          state = state.copyWith(
            isSseConnected: false,
            error: 'SSE connection error: $error',
          );
        },
        onDone: () {
          debugPrint('PushService: SSE connection closed');
          state = state.copyWith(isSseConnected: false);
        },
      );

      state = state.copyWith(isSseConnected: true, clearError: true);
    } catch (e) {
      debugPrint('PushService: Failed to connect to SSE: $e');
      state = state.copyWith(
        isSseConnected: false,
        error: 'Failed to connect to SSE: $e',
      );
      rethrow;
    }
  }

  /// Disconnect from SSE
  Future<void> disconnectSse() async {
    await _sseSubscription?.cancel();
    _sseSubscription = null;
    state = state.copyWith(isSseConnected: false);
    debugPrint('PushService: Disconnected from SSE');
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
    // Don't await - fire and forget for local notification display
    _showLocalNotification(notification).catchError((error) {
      debugPrint('Failed to show local notification: $error');
    });
  }

  /// Request registration with UnifiedPush distributor
  Future<void> registerWithDistributor([String? distributor]) async {
    debugPrint('PushService: Registering with UnifiedPush distributor${distributor != null ? ': $distributor' : ''}');
    
    try {
      // Register with UnifiedPush (user will choose distributor)
      await UnifiedPush.registerApp();
      
      debugPrint('PushService: UnifiedPush registration requested');
    } catch (e) {
      debugPrint('PushService: Failed to register with UnifiedPush: $e');
      state = state.copyWith(error: 'Failed to register with UnifiedPush: $e');
      rethrow;
    }
  }

  /// Unregister from UnifiedPush
  Future<void> unregisterUnifiedPush() async {
    debugPrint('PushService: Unregistering from UnifiedPush');
    
    try {
      await UnifiedPush.unregister();
      state = state.copyWith(clearUnifiedPushEndpoint: true);
      debugPrint('PushService: UnifiedPush unregistered successfully');
    } catch (e) {
      debugPrint('PushService: Failed to unregister from UnifiedPush: $e');
      rethrow;
    }
  }

  /// Get list of available UnifiedPush distributors
  Future<List<String>> getAvailableDistributors() async {
    try {
      final distributors = await UnifiedPush.getDistributors();
      debugPrint('PushService: Available distributors: $distributors');
      return distributors;
    } catch (e) {
      debugPrint('PushService: Failed to get distributors: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _notificationController.close();
    _sseSubscription?.cancel();
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
