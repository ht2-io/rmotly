import 'package:rmotly_client/rmotly_client.dart';
import '../../domain/repositories/control_repository.dart';
import '../../../../core/services/local_storage_service.dart';

/// Implementation of ControlRepository using Serverpod API client with caching
class ControlRepositoryImpl implements ControlRepository {
  final Client _client;
  final LocalStorageService _storage;
  
  // Track pending requests to prevent duplicate API calls
  Future<List<Control>>? _pendingGetControls;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  ControlRepositoryImpl(this._client, this._storage);

  @override
  Future<List<Control>> getControls({bool forceRefresh = false}) async {
    // Return cached data if available and not forcing refresh
    if (!forceRefresh && _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      try {
        final cached = await _storage.getCachedControls();
        if (cached.isNotEmpty) {
          // Start background refresh if cache is getting old
          if (DateTime.now().difference(_lastFetch!) > const Duration(minutes: 2)) {
            _refreshInBackground();
          }
          return cached;
        }
      } catch (_) {
        // If cache fails, proceed to fetch from API
      }
    }

    // Deduplicate concurrent requests
    if (_pendingGetControls != null) {
      return _pendingGetControls!;
    }

    // Create new request
    _pendingGetControls = _fetchAndCache();
    
    try {
      return await _pendingGetControls!;
    } finally {
      _pendingGetControls = null;
    }
  }

  Future<List<Control>> _fetchAndCache() async {
    // TODO: Replace with actual endpoint call when ControlEndpoint is implemented
    // For now, return mock data for development
    final controls = [
      Control(
        id: 1,
        userId: 1,
        name: 'Living Room Light',
        controlType: 'button',
        config: '{"label": "Toggle"}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Control(
        id: 2,
        userId: 1,
        name: 'Thermostat',
        controlType: 'slider',
        config: '{"min": 60, "max": 80}',
        position: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // Cache the results
    try {
      await _storage.cacheControls(controls);
      _lastFetch = DateTime.now();
    } catch (_) {
      // Continue even if caching fails
    }

    return controls;
  }

  void _refreshInBackground() {
    // Refresh cache in background without blocking
    _fetchAndCache().catchError((_) {
      // Silently fail background refresh
      return <Control>[];
    });
  }

  @override
  Future<Control> createControl(Control control) async {
    // TODO: Replace with actual endpoint call
    // return await _client.control.createControl(control);
    
    // Invalidate cache on create
    _lastFetch = null;
    throw UnimplementedError('createControl endpoint not yet implemented');
  }

  @override
  Future<Control> updateControl(Control control) async {
    // TODO: Replace with actual endpoint call
    // return await _client.control.updateControl(control);
    
    // Invalidate cache on update
    _lastFetch = null;
    throw UnimplementedError('updateControl endpoint not yet implemented');
  }

  @override
  Future<void> deleteControl(int controlId) async {
    // TODO: Replace with actual endpoint call
    // await _client.control.deleteControl(controlId);
    
    // Invalidate cache on delete
    _lastFetch = null;
    throw UnimplementedError('deleteControl endpoint not yet implemented');
  }

  @override
  Future<void> reorderControls(List<Control> controls) async {
    // Optimistically update cache
    try {
      await _storage.cacheControls(controls);
    } catch (_) {
      // Continue even if caching fails
    }
    
    // TODO: Replace with actual endpoint call
    // await _client.control.reorderControls(controls);
    throw UnimplementedError('reorderControls endpoint not yet implemented');
  }

  @override
  Future<void> sendControlEvent(
    int controlId,
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    // TODO: Replace with actual endpoint call
    // await _client.event.sendEvent(controlId, eventType, payload);
    throw UnimplementedError('sendControlEvent endpoint not yet implemented');
  }
}
