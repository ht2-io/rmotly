import 'package:flutter/material.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../viewmodel/dashboard_viewmodel.dart';

/// Widget for toggle control type
class ToggleControlWidget extends StatefulWidget {
  final Control control;
  final void Function(bool value) onChanged;
  final bool isExecuting;

  const ToggleControlWidget({
    super.key,
    required this.control,
    required this.onChanged,
    this.isExecuting = false,
  });

  @override
  State<ToggleControlWidget> createState() => _ToggleControlWidgetState();
}

class _ToggleControlWidgetState extends State<ToggleControlWidget> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    final config = parseControlConfig(widget.control.config);
    _value = config['state'] as bool? ?? false;
  }

  @override
  void didUpdateWidget(ToggleControlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.control.config != widget.control.config) {
      final config = parseControlConfig(widget.control.config);
      _value = config['state'] as bool? ?? _value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = parseControlConfig(widget.control.config);

    final onLabel = config['onLabel'] as String? ?? 'ON';
    final offLabel = config['offLabel'] as String? ?? 'OFF';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: _value,
          onChanged: widget.isExecuting
              ? null
              : (value) {
                  setState(() => _value = value);
                  widget.onChanged(value);
                },
        ),
        const SizedBox(height: 8),
        Text(
          _value ? onLabel : offLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: _value ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: _value ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
