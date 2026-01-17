import 'dart:convert';
import 'package:rmotly_client/rmotly_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import '../../domain/repositories/control_repository.dart';
import '../../../../core/services/local_storage_service.dart';

/// Implementation of ControlRepository using Serverpod API client with caching
class ControlRepositoryImpl implements ControlRepository {
  final Client _client;
  final LocalStorageService _storage;
  final SessionManager _sessionManager;

  // Track pending requests to prevent duplicate API calls
  Future<List<Control>>? _pendingGetControls;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  ControlRepositoryImpl(this._client, this._storage, this._sessionManager);

  @override
  Future<List<Control>> getControls({bool forceRefresh = false}) async {
    // Return cached data if available and not forcing refresh
    if (!forceRefresh &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      try {
        final cached = await _storage.getCachedControls();
        if (cached.isNotEmpty) {
          // Start background refresh if cache is getting old
          if (DateTime.now().difference(_lastFetch!) >
              const Duration(minutes: 2)) {
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
    final userId = _sessionManager.signedInUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Fetch from API
    final controls = await _client.control.listControls(userId: userId);

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
    // ignore: unawaited_futures
    _fetchAndCache();
  }

  @override
  Future<Control> createControl(Control control) async {
    final userId = _sessionManager.signedInUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final createdControl = await _client.control.createControl(
      userId: userId,
      name: control.name,
      controlType: control.controlType,
      config: control.config,
      position: control.position,
      actionId: control.actionId,
    );

    // Invalidate cache on create
    _lastFetch = null;

    return createdControl;
  }

  @override
  Future<Control> updateControl(Control control) async {
    if (control.id == null) {
      throw ArgumentError('Control ID cannot be null for update');
    }

    final updatedControl = await _client.control.updateControl(
      controlId: control.id!,
      name: control.name,
      controlType: control.controlType,
      config: control.config,
      position: control.position,
      actionId: control.actionId,
      clearActionId: control.actionId == null,
    );

    // Invalidate cache on update
    _lastFetch = null;

    return updatedControl;
  }

  @override
  Future<void> deleteControl(int controlId) async {
    await _client.control.deleteControl(controlId: controlId);

    // Invalidate cache on delete
    _lastFetch = null;
  }

  @override
  Future<void> reorderControls(List<Control> controls) async {
    final userId = _sessionManager.signedInUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Build map of control ID to position
    final controlPositions = <int, int>{};
    for (var control in controls) {
      if (control.id != null) {
        controlPositions[control.id!] = control.position;
      }
    }

    // Optimistically update cache
    try {
      await _storage.cacheControls(controls);
      _lastFetch = DateTime.now(); // Update timestamp for optimistic cache
    } catch (_) {
      // Continue even if caching fails
    }

    // Call API to persist reorder
    await _client.control.reorderControls(
      userId: userId,
      controlPositions: controlPositions,
    );
  }

  @override
  Future<void> sendControlEvent(
    int controlId,
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    await _client.event.sendEvent(
      sourceType: 'control',
      sourceId: controlId.toString(),
      eventType: eventType,
      payload: jsonEncode(payload),
    );
  }
}
