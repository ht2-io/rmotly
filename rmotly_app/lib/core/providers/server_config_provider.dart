import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Server configuration state
class ServerConfig {
  final String? serverUrl;
  final bool isConfigured;
  final bool isLoading;
  final String? error;

  const ServerConfig({
    this.serverUrl,
    this.isConfigured = false,
    this.isLoading = false,
    this.error,
  });

  ServerConfig copyWith({
    String? serverUrl,
    bool? isConfigured,
    bool? isLoading,
    String? error,
  }) {
    return ServerConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      isConfigured: isConfigured ?? this.isConfigured,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = ServerConfig(isLoading: true);
}

/// Server configuration service
class ServerConfigService extends StateNotifier<ServerConfig> {
  static const String _boxName = 'server_config';
  static const String _serverUrlKey = 'server_url';

  Box<dynamic>? _box;

  ServerConfigService() : super(ServerConfig.initial) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<dynamic>(_boxName);
      final savedUrl = _box?.get(_serverUrlKey) as String?;

      if (savedUrl != null && savedUrl.isNotEmpty) {
        state = ServerConfig(
          serverUrl: savedUrl,
          isConfigured: true,
          isLoading: false,
        );
      } else {
        state = const ServerConfig(
          isConfigured: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = ServerConfig(
        isLoading: false,
        error: 'Failed to load server config: $e',
      );
    }
  }

  /// Validate and normalize server URL
  String? _normalizeUrl(String url) {
    url = url.trim();
    if (url.isEmpty) return null;

    // Add https:// if no protocol specified
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    // Ensure trailing slash
    if (!url.endsWith('/')) {
      url = '$url/';
    }

    // Validate URL format
    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) return null;
      return url;
    } catch (e) {
      return null;
    }
  }

  /// Set the server URL
  Future<bool> setServerUrl(String url) async {
    state = state.copyWith(isLoading: true, error: null);

    final normalizedUrl = _normalizeUrl(url);
    if (normalizedUrl == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid server URL',
      );
      return false;
    }

    try {
      await _box?.put(_serverUrlKey, normalizedUrl);
      state = ServerConfig(
        serverUrl: normalizedUrl,
        isConfigured: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save server URL: $e',
      );
      return false;
    }
  }

  /// Clear server configuration
  Future<void> clearConfig() async {
    await _box?.delete(_serverUrlKey);
    state = const ServerConfig(
      isConfigured: false,
      isLoading: false,
    );
  }

  /// Get the current server URL
  String? get serverUrl => state.serverUrl;

  /// Check if server is configured
  bool get isConfigured => state.isConfigured;
}

/// Provider for server configuration service
final serverConfigProvider =
    StateNotifierProvider<ServerConfigService, ServerConfig>((ref) {
  return ServerConfigService();
});

/// Provider for current server URL
final serverUrlProvider = Provider<String?>((ref) {
  return ref.watch(serverConfigProvider).serverUrl;
});

/// Provider for checking if server is configured
final isServerConfiguredProvider = Provider<bool>((ref) {
  return ref.watch(serverConfigProvider).isConfigured;
});
