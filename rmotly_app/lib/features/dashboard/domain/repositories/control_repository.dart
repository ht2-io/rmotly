import 'package:rmotly_client/rmotly_client.dart';

/// Repository interface for control operations
///
/// This interface defines the contract for control data operations.
/// Implementations should handle API communication and error handling.
abstract class ControlRepository {
  /// Fetch all controls for the current user
  ///
  /// Returns a list of controls ordered by their position.
  /// Throws exceptions on network or API errors.
  /// 
  /// [forceRefresh] - If true, bypasses cache and fetches from API
  Future<List<Control>> getControls({bool forceRefresh = false});

  /// Create a new control
  ///
  /// Returns the created control with its assigned ID.
  Future<Control> createControl(Control control);

  /// Update an existing control
  ///
  /// Returns the updated control.
  Future<Control> updateControl(Control control);

  /// Delete a control by ID
  ///
  /// Throws an exception if the control doesn't exist or deletion fails.
  Future<void> deleteControl(int controlId);

  /// Reorder controls by updating their positions
  ///
  /// Takes a list of controls with updated position values.
  Future<void> reorderControls(List<Control> controls);

  /// Send an event for a control interaction
  ///
  /// [controlId] - The ID of the control being interacted with
  /// [eventType] - The type of event (e.g., 'button_pressed', 'toggle_changed')
  /// [payload] - The event data (e.g., {"state": true} for toggle)
  Future<void> sendControlEvent(
      int controlId, String eventType, Map<String, dynamic> payload);
}
