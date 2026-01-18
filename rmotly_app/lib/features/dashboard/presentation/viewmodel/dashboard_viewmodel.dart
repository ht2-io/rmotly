import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../../../../core/control_type.dart';
import '../../../../core/event_type.dart';
import '../../domain/repositories/control_repository.dart';
import '../state/dashboard_state.dart';

/// View model for the dashboard feature
class DashboardViewModel extends StateNotifier<DashboardState> {
  final ControlRepository? _repository;

  DashboardViewModel(ControlRepository repository)
      : _repository = repository,
        super(DashboardState.initial) {
    loadControls();
  }

  /// Create a view model with an initial error state (e.g., server not configured)
  DashboardViewModel.withError(String error)
      : _repository = null,
        super(DashboardState(error: error));

  /// Load controls from the repository
  Future<void> loadControls() async {
    if (_repository == null || state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Use cached data if available
      final controls = await _repository.getControls(forceRefresh: false);
      state = state.copyWith(
        controls: controls,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('DashboardViewModel: Failed to load controls: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load controls: $e',
      );
    }
  }

  /// Refresh controls (pull-to-refresh)
  Future<void> refreshControls() async {
    if (_repository == null || state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      // Force refresh from API
      final controls = await _repository.getControls(forceRefresh: true);
      state = state.copyWith(
        controls: controls,
        isRefreshing: false,
      );
    } catch (e) {
      debugPrint('DashboardViewModel: Failed to refresh controls: $e');
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh controls',
      );
    }
  }

  /// Execute a control interaction
  Future<void> executeControl(
      Control control, Map<String, dynamic> payload) async {
    if (_repository == null || control.id == null) return;

    state = state.copyWith(executingControlId: control.id);

    try {
      final eventType = _getEventTypeForControl(control.controlType);
      await _repository.sendControlEvent(control.id!, eventType.value, payload);

      debugPrint(
          'DashboardViewModel: Control ${control.name} executed successfully');

      state = state.copyWith(clearExecutingControl: true);
    } catch (e) {
      debugPrint('DashboardViewModel: Failed to execute control: $e');
      state = state.copyWith(
        clearExecutingControl: true,
        error: 'Failed to execute action',
      );
    }
  }

  /// Handle button press
  Future<void> onButtonPressed(Control control) async {
    await executeControl(control, {'pressed': true});
  }

  /// Handle toggle change
  Future<void> onToggleChanged(Control control, bool value) async {
    await executeControl(control, {'state': value});
  }

  /// Handle slider change
  Future<void> onSliderChanged(Control control, double value) async {
    await executeControl(control, {'value': value});
  }

  /// Handle input submit
  Future<void> onInputSubmitted(Control control, String text) async {
    await executeControl(control, {'text': text});
  }

  /// Handle dropdown selection
  Future<void> onDropdownSelected(Control control, String optionId) async {
    await executeControl(control, {'selected': optionId});
  }

  /// Reorder controls
  Future<void> reorderControls(int oldIndex, int newIndex) async {
    if (_repository == null || oldIndex == newIndex) return;

    // Adjust for removal
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Update local state immediately for smooth UX
    final controls = List<Control>.from(state.controls);
    final control = controls.removeAt(oldIndex);
    controls.insert(newIndex, control);

    // Update positions
    final updatedControls = <Control>[];
    for (var i = 0; i < controls.length; i++) {
      updatedControls.add(controls[i].copyWith(position: i));
    }

    state = state.copyWith(controls: updatedControls);

    // Sync with server
    try {
      await _repository.reorderControls(updatedControls);
    } catch (e) {
      debugPrint('DashboardViewModel: Failed to save reorder: $e');
      // Reload to get server state
      await loadControls();
    }
  }

  /// Delete a control
  Future<void> deleteControl(int controlId) async {
    if (_repository == null) return;

    try {
      await _repository.deleteControl(controlId);

      // Remove from local state
      final controls = state.controls.where((c) => c.id != controlId).toList();
      state = state.copyWith(controls: controls);
    } catch (e) {
      debugPrint('DashboardViewModel: Failed to delete control: $e');
      state = state.copyWith(error: 'Failed to delete control');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Get event type for control type
  EventType _getEventTypeForControl(String controlType) {
    switch (controlType) {
      case 'button':
        return EventType.buttonPress;
      case 'toggle':
        return EventType.toggleChange;
      case 'slider':
        return EventType.sliderChange;
      case 'input':
        return EventType.inputSubmit;
      case 'dropdown':
        return EventType.dropdownSelect;
      default:
        return EventType.buttonPress;
    }
  }
}

/// Parse control config JSON
Map<String, dynamic> parseControlConfig(String configJson) {
  try {
    return jsonDecode(configJson) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

/// Get ControlType enum from string
ControlType? getControlTypeFromString(String type) {
  switch (type) {
    case 'button':
      return ControlType.button;
    case 'toggle':
      return ControlType.toggle;
    case 'slider':
      return ControlType.slider;
    case 'input':
      return ControlType.input;
    case 'dropdown':
      return ControlType.dropdown;
    default:
      return null;
  }
}
