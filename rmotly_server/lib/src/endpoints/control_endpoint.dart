import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:rmotly_server/src/generated/protocol.dart';

/// Serverpod endpoint for managing controls (dashboard UI elements).
///
/// Provides methods to create, read, update, and delete controls,
/// as well as reorder them within a user's dashboard.
class ControlEndpoint extends Endpoint {
  /// Create a new control
  ///
  /// Creates a control that can trigger actions from the dashboard.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [userId]: ID of the user creating the control (temporary until auth is implemented)
  /// - [name]: Display name for the control
  /// - [controlType]: Type of control (button, toggle, slider, input, dropdown)
  /// - [config]: Control configuration as JSON string
  /// - [position]: Position/order in the dashboard
  /// - [actionId]: Optional ID of the action to trigger
  ///
  /// Returns: The created [Control] with generated ID
  ///
  /// Throws: [ArgumentError] if validation fails
  Future<Control> createControl(
    Session session, {
    required int userId,
    required String name,
    required String controlType,
    required String config,
    required int position,
    int? actionId,
  }) async {
    // Validate input
    if (name.trim().isEmpty) {
      throw ArgumentError('name cannot be empty');
    }

    if (controlType.trim().isEmpty) {
      throw ArgumentError('controlType cannot be empty');
    }

    // Validate controlType is one of the allowed values
    const allowedTypes = ['button', 'toggle', 'slider', 'input', 'dropdown'];
    if (!allowedTypes.contains(controlType)) {
      throw ArgumentError(
        'controlType must be one of: ${allowedTypes.join(', ')}',
      );
    }

    // Validate config is valid JSON
    try {
      jsonDecode(config);
    } catch (e) {
      throw ArgumentError('config must be valid JSON: $e');
    }

    if (position < 0) {
      throw ArgumentError('position must be non-negative');
    }

    // Verify action exists if actionId is provided
    if (actionId != null) {
      final action = await Action.db.findById(session, actionId);
      if (action == null) {
        throw ArgumentError('Action with ID $actionId not found');
      }
      // Verify action belongs to the same user
      if (action.userId != userId) {
        throw ArgumentError('Action does not belong to the specified user');
      }
    }

    // Create the control
    final now = DateTime.now();
    final control = Control(
      userId: userId,
      name: name,
      controlType: controlType,
      config: config,
      position: position,
      actionId: actionId,
      createdAt: now,
      updatedAt: now,
    );

    final savedControl = await Control.db.insertRow(session, control);

    session.log(
      'Control created: ${savedControl.id} - $name ($controlType)',
      level: LogLevel.info,
    );

    return savedControl;
  }

  /// List all controls for a user
  ///
  /// Returns controls ordered by position.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [userId]: ID of the user whose controls to list
  ///
  /// Returns: List of [Control] ordered by position
  Future<List<Control>> listControls(
    Session session, {
    required int userId,
  }) async {
    final controls = await Control.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.position,
      orderDescending: false,
    );

    session.log(
      'Listed ${controls.length} controls for user $userId',
      level: LogLevel.debug,
    );

    return controls;
  }

  /// Get a single control by ID
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [controlId]: ID of the control to retrieve
  ///
  /// Returns: The [Control] or null if not found
  Future<Control?> getControl(
    Session session, {
    required int controlId,
  }) async {
    final control = await Control.db.findById(session, controlId);

    if (control != null) {
      session.log(
        'Retrieved control: ${control.id} - ${control.name}',
        level: LogLevel.debug,
      );
    } else {
      session.log(
        'Control not found: $controlId',
        level: LogLevel.warning,
      );
    }

    return control;
  }

  /// Update a control
  ///
  /// Updates the specified fields of a control. All fields are optional
  /// except controlId. Only provided fields will be updated.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [controlId]: ID of the control to update
  /// - [name]: New display name (optional)
  /// - [controlType]: New control type (optional)
  /// - [config]: New configuration JSON (optional)
  /// - [position]: New position (optional)
  /// - [actionId]: New action ID (optional, can be null to remove association)
  ///
  /// Returns: The updated [Control]
  ///
  /// Throws: [ArgumentError] if control not found or validation fails
  Future<Control> updateControl(
    Session session, {
    required int controlId,
    String? name,
    String? controlType,
    String? config,
    int? position,
    int? actionId,
    bool clearActionId = false,
  }) async {
    // Fetch existing control
    final control = await Control.db.findById(session, controlId);
    if (control == null) {
      throw ArgumentError('Control with ID $controlId not found');
    }

    // Update fields if provided
    if (name != null) {
      if (name.trim().isEmpty) {
        throw ArgumentError('name cannot be empty');
      }
      control.name = name;
    }

    if (controlType != null) {
      const allowedTypes = ['button', 'toggle', 'slider', 'input', 'dropdown'];
      if (!allowedTypes.contains(controlType)) {
        throw ArgumentError(
          'controlType must be one of: ${allowedTypes.join(', ')}',
        );
      }
      control.controlType = controlType;
    }

    if (config != null) {
      // Validate config is valid JSON
      try {
        jsonDecode(config);
      } catch (e) {
        throw ArgumentError('config must be valid JSON: $e');
      }
      control.config = config;
    }

    if (position != null) {
      if (position < 0) {
        throw ArgumentError('position must be non-negative');
      }
      control.position = position;
    }

    if (actionId != null) {
      // Verify action exists and belongs to same user
      final action = await Action.db.findById(session, actionId);
      if (action == null) {
        throw ArgumentError('Action with ID $actionId not found');
      }
      if (action.userId != control.userId) {
        throw ArgumentError('Action does not belong to the same user');
      }
      control.actionId = actionId;
    } else if (clearActionId) {
      control.actionId = null;
    }

    // Update timestamp
    control.updatedAt = DateTime.now();

    final updatedControl = await Control.db.updateRow(session, control);

    session.log(
      'Control updated: ${updatedControl.id} - ${updatedControl.name}',
      level: LogLevel.info,
    );

    return updatedControl;
  }

  /// Delete a control
  ///
  /// Permanently deletes a control from the database.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [controlId]: ID of the control to delete
  ///
  /// Returns: true if deleted, false if not found
  Future<bool> deleteControl(
    Session session, {
    required int controlId,
  }) async {
    final control = await Control.db.findById(session, controlId);
    if (control == null) {
      session.log(
        'Cannot delete - control not found: $controlId',
        level: LogLevel.warning,
      );
      return false;
    }

    await Control.db.deleteRow(session, control);

    session.log(
      'Control deleted: $controlId - ${control.name}',
      level: LogLevel.info,
    );

    return true;
  }

  /// Reorder controls for a user
  ///
  /// Updates the position field for multiple controls at once.
  /// This is useful for drag-and-drop reordering in the UI.
  ///
  /// Parameters:
  /// - [session]: The current session
  /// - [userId]: ID of the user whose controls to reorder
  /// - [controlPositions]: Map of control ID to new position
  ///
  /// Returns: List of updated controls ordered by position
  ///
  /// Throws: [ArgumentError] if any control is not found or doesn't belong to user
  Future<List<Control>> reorderControls(
    Session session, {
    required int userId,
    required Map<int, int> controlPositions,
  }) async {
    if (controlPositions.isEmpty) {
      throw ArgumentError('controlPositions cannot be empty');
    }

    // Validate all positions are non-negative
    for (final position in controlPositions.values) {
      if (position < 0) {
        throw ArgumentError('All positions must be non-negative');
      }
    }

    final updatedControls = <Control>[];

    for (final entry in controlPositions.entries) {
      final controlId = entry.key;
      final newPosition = entry.value;

      final control = await Control.db.findById(session, controlId);
      if (control == null) {
        throw ArgumentError('Control with ID $controlId not found');
      }

      if (control.userId != userId) {
        throw ArgumentError('Control $controlId does not belong to user $userId');
      }

      control.position = newPosition;
      control.updatedAt = DateTime.now();

      final updated = await Control.db.updateRow(session, control);
      updatedControls.add(updated);
    }

    // Return all controls for the user, ordered by position
    final allControls = await listControls(session, userId: userId);

    session.log(
      'Reordered ${controlPositions.length} controls for user $userId',
      level: LogLevel.info,
    );

    return allControls;
  }
}
