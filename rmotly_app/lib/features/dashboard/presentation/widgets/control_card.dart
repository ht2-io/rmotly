import 'package:flutter/material.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../../../../core/control_type.dart';
import '../viewmodel/dashboard_viewmodel.dart';

/// Base card widget that wraps all control types
class ControlCard extends StatelessWidget {
  final Control control;
  final Widget child;
  final bool isExecuting;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ControlCard({
    super.key,
    required this.control,
    required this.child,
    this.isExecuting = false,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controlType = getControlTypeFromString(control.controlType);

    return Card(
      elevation: isExecuting ? 4 : 1,
      color: isExecuting
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.surface,
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with icon and menu
                  Row(
                    children: [
                      Icon(
                        _getIconForControlType(controlType),
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          control.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onEdit != null || onDelete != null)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit?.call();
                            } else if (value == 'delete') {
                              onDelete?.call();
                            }
                          },
                          itemBuilder: (context) => [
                            if (onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                            if (onDelete != null)
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: colorScheme.error),
                                    const SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: colorScheme.error)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Control widget
                  Expanded(
                    child: Center(child: child),
                  ),
                ],
              ),
            ),
            // Loading overlay
            if (isExecuting)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForControlType(ControlType? type) {
    switch (type) {
      case ControlType.button:
        return Icons.touch_app;
      case ControlType.toggle:
        return Icons.toggle_on;
      case ControlType.slider:
        return Icons.linear_scale;
      case ControlType.input:
        return Icons.text_fields;
      case ControlType.dropdown:
        return Icons.arrow_drop_down_circle;
      default:
        return Icons.widgets;
    }
  }
}
