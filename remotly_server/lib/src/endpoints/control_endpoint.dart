import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'notification_stream_endpoint.dart' show AuthenticationException;

/// Endpoint for managing user controls.
///
/// This endpoint allows clients to create, read, update, delete, and reorder
/// controls on their dashboard. Controls are UI elements (buttons, toggles,
/// sliders, etc.) that can trigger actions.
///
/// Usage:
/// ```dart
/// // Create a new control
/// final control = await client.control.createControl(
///   name: 'Living Room Light',
///   controlType: 'toggle',
///   actionId: 42,
///   config: '{"color": "blue"}',
/// );
///
/// // List all controls
/// final controls = await client.control.listControls();
///
/// // Update a control
/// final updated = await client.control.updateControl(
///   controlId: 1,
///   name: 'Bedroom Light',
/// );
///
/// // Delete a control
/// await client.control.deleteControl(controlId: 1);
///
/// // Reorder controls
/// await client.control.reorderControls(controlIds: [3, 1, 2]);
/// ```
class ControlEndpoint extends Endpoint {
  /// Create a new control for the authenticated user.
  ///
  /// [name] - Display name for the control
  /// [controlType] - Type of control (button, toggle, slider, input, dropdown)
  /// [actionId] - Optional ID of the action triggered by this control
  /// [config] - Control configuration as JSON string
  /// [position] - Optional position/order in the dashboard. If not provided,
  ///              the control will be placed at the end (max position + 1)
  ///
  /// Returns the created [Control] with ID assigned.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if name or controlType is empty, or config is invalid.
  Future<Control> createControl(
    Session session, {
    required String name,
    required String controlType,
    int? actionId,
    required String config,
    int? position,
  }) async {
    // Authenticate user
    final userId = (await session.authenticated)?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated control creation rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    // Validate input
    if (name.trim().isEmpty) {
      throw ArgumentError('Control name cannot be empty');
    }

    if (controlType.trim().isEmpty) {
      throw ArgumentError('Control type cannot be empty');
    }

    if (config.trim().isEmpty) {
      throw ArgumentError('Control config cannot be empty');
    }

    // Determine position
    int finalPosition;
    if (position != null) {
      finalPosition = position;
    } else {
      // Find the max position for this user's controls
      final existingControls = await Control.db.find(
        session,
        where: (t) => t.userId.equals(userId),
        orderBy: (t) => t.position,
        orderDescending: true,
        limit: 1,
      );

      finalPosition = existingControls.isEmpty
          ? 0
          : (existingControls.first.position + 1);
    }

    // Create the control
    final now = DateTime.now();
    final control = Control(
      userId: userId,
      name: name,
      controlType: controlType,
      actionId: actionId,
      config: config,
      position: finalPosition,
      createdAt: now,
      updatedAt: now,
    );

    // Save to database
    final savedControl = await Control.db.insertRow(session, control);

    session.log(
      'Control created: ${savedControl.id} for user $userId',
      level: LogLevel.info,
    );

    return savedControl;
  }

  /// List all controls for the authenticated user.
  ///
  /// Returns a list of [Control]s ordered by position (ascending).
  /// Returns an empty list if the user has no controls.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  Future<List<Control>> listControls(Session session) async {
    // Authenticate user
    final userId = (await session.authenticated)?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated control list request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    session.log(
      'Listing controls for user $userId',
      level: LogLevel.debug,
    );

    // Fetch controls for this user, ordered by position
    final controls = await Control.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.position,
      orderDescending: false,
    );

    return controls;
  }

  /// Get a specific control by ID.
  ///
  /// [controlId] - The ID of the control to retrieve
  ///
  /// Returns the [Control] if found and belongs to the authenticated user,
  /// or null if not found or doesn't belong to the user.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  Future<Control?> getControl(Session session, int controlId) async {
    // Authenticate user
    final userId = (await session.authenticated)?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated control get request rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    session.log(
      'Fetching control $controlId for user $userId',
      level: LogLevel.debug,
    );

    // Fetch the control
    final control = await Control.db.findById(session, controlId);

    // Verify ownership
    if (control == null || control.userId != userId) {
      if (control != null) {
        session.log(
          'User $userId attempted to access control $controlId '
          'belonging to user ${control.userId}',
          level: LogLevel.warning,
        );
      }
      return null;
    }

    return control;
  }

  /// Update a control.
  ///
  /// [controlId] - The ID of the control to update
  /// [name] - Optional new display name
  /// [controlType] - Optional new control type
  /// [actionId] - Optional new action ID (use explicit null to remove action)
  /// [config] - Optional new configuration JSON string
  ///
  /// Returns the updated [Control], or null if the control was not found
  /// or doesn't belong to the authenticated user.
  ///
  /// Note: At least one parameter must be provided to update.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if no parameters are provided or validation fails.
  Future<Control?> updateControl(
    Session session,
    int controlId, {
    String? name,
    String? controlType,
    int? actionId,
    String? config,
  }) async {
    // Authenticate user
    final userId = (await session.authenticated)?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated control update rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    // Validate that at least one parameter is provided
    if (name == null && controlType == null && actionId == null && config == null) {
      throw ArgumentError('At least one parameter must be provided to update');
    }

    session.log(
      'Updating control $controlId for user $userId',
      level: LogLevel.info,
    );

    // Fetch the control
    final control = await Control.db.findById(session, controlId);

    // Verify ownership
    if (control == null || control.userId != userId) {
      if (control != null) {
        session.log(
          'User $userId attempted to update control $controlId '
          'belonging to user ${control.userId}',
          level: LogLevel.warning,
        );
      }
      return null;
    }

    // Update fields if provided
    if (name != null) {
      if (name.trim().isEmpty) {
        throw ArgumentError('Control name cannot be empty');
      }
      control.name = name;
    }

    if (controlType != null) {
      if (controlType.trim().isEmpty) {
        throw ArgumentError('Control type cannot be empty');
      }
      control.controlType = controlType;
    }

    if (actionId != null) {
      control.actionId = actionId;
    }

    if (config != null) {
      if (config.trim().isEmpty) {
        throw ArgumentError('Control config cannot be empty');
      }
      control.config = config;
    }

    // Update timestamp
    control.updatedAt = DateTime.now();

    // Save to database
    final updatedControl = await Control.db.updateRow(session, control);

    session.log(
      'Control $controlId updated for user $userId',
      level: LogLevel.info,
    );

    return updatedControl;
  }

  /// Delete a control.
  ///
  /// [controlId] - The ID of the control to delete
  ///
  /// Returns true if the control was deleted, false if not found
  /// or doesn't belong to the authenticated user.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  Future<bool> deleteControl(Session session, int controlId) async {
    // Authenticate user
    final userId = (await session.authenticated)?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated control deletion rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    session.log(
      'Deleting control $controlId for user $userId',
      level: LogLevel.info,
    );

    // Fetch the control
    final control = await Control.db.findById(session, controlId);

    // Verify ownership
    if (control == null || control.userId != userId) {
      if (control != null) {
        session.log(
          'User $userId attempted to delete control $controlId '
          'belonging to user ${control.userId}',
          level: LogLevel.warning,
        );
      }
      return false;
    }

    // Delete the control
    await Control.db.deleteRow(session, control);

    session.log(
      'Control $controlId deleted for user $userId',
      level: LogLevel.info,
    );

    return true;
  }

  /// Reorder controls by updating their position field.
  ///
  /// [controlIds] - List of control IDs in the desired order.
  ///                The first ID will have position 0, second will have position 1, etc.
  ///
  /// Returns true if all controls were reordered successfully.
  ///
  /// Throws [AuthenticationException] if user is not authenticated.
  /// Throws [ArgumentError] if controlIds is empty or contains duplicates.
  /// Throws [StateError] if any control doesn't exist or doesn't belong to the user.
  Future<bool> reorderControls(
    Session session,
    List<int> controlIds,
  ) async {
    // Authenticate user
    final userId = (await session.authenticated)?.userId;
    if (userId == null) {
      session.log(
        'Unauthenticated control reorder rejected',
        level: LogLevel.warning,
      );
      throw AuthenticationException('User not authenticated');
    }

    // Validate input
    if (controlIds.isEmpty) {
      throw ArgumentError('controlIds cannot be empty');
    }

    // Check for duplicates
    final uniqueIds = controlIds.toSet();
    if (uniqueIds.length != controlIds.length) {
      throw ArgumentError('controlIds cannot contain duplicates');
    }

    session.log(
      'Reordering ${controlIds.length} controls for user $userId',
      level: LogLevel.info,
    );

    // Fetch all controls
    final controls = await Control.db.find(
      session,
      where: (t) => t.id.inSet(uniqueIds),
    );

    // Verify all controls exist and belong to user
    if (controls.length != controlIds.length) {
      throw StateError(
        'Some controls were not found. Expected ${controlIds.length}, found ${controls.length}',
      );
    }

    for (final control in controls) {
      if (control.userId != userId) {
        session.log(
          'User $userId attempted to reorder control ${control.id} '
          'belonging to user ${control.userId}',
          level: LogLevel.warning,
        );
        throw StateError(
          'Control ${control.id} does not belong to the authenticated user',
        );
      }
    }

    // Create a map for quick lookup
    final controlMap = {for (var c in controls) c.id!: c};

    // Update positions
    final updatedControls = <Control>[];
    for (var i = 0; i < controlIds.length; i++) {
      final controlId = controlIds[i];
      final control = controlMap[controlId]!;
      control.position = i;
      control.updatedAt = DateTime.now();
      updatedControls.add(control);
    }

    // Save all updates
    await Control.db.update(session, updatedControls);

    session.log(
      'Reordered ${controlIds.length} controls for user $userId',
      level: LogLevel.info,
    );

    return true;
  }
}
