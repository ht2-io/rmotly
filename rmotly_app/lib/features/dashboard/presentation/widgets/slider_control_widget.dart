import 'package:flutter/material.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../viewmodel/dashboard_viewmodel.dart';

/// Widget for slider control type
class SliderControlWidget extends StatefulWidget {
  final Control control;
  final void Function(double value) onChanged;
  final bool isExecuting;

  const SliderControlWidget({
    super.key,
    required this.control,
    required this.onChanged,
    this.isExecuting = false,
  });

  @override
  State<SliderControlWidget> createState() => _SliderControlWidgetState();
}

class _SliderControlWidgetState extends State<SliderControlWidget> {
  late double _value;
  late double _min;
  late double _max;
  late int _divisions;

  @override
  void initState() {
    super.initState();
    _parseConfig();
  }

  @override
  void didUpdateWidget(SliderControlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.control.config != widget.control.config) {
      _parseConfig();
    }
  }

  void _parseConfig() {
    final config = parseControlConfig(widget.control.config);
    _min = (config['min'] as num?)?.toDouble() ?? 0.0;
    _max = (config['max'] as num?)?.toDouble() ?? 100.0;
    _value = (config['value'] as num?)?.toDouble() ?? _min;
    _divisions = config['divisions'] as int? ?? 10;

    // Clamp value to valid range
    _value = _value.clamp(_min, _max);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = parseControlConfig(widget.control.config);

    final unit = config['unit'] as String? ?? '';
    final showValue = config['showValue'] as bool? ?? true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showValue) ...[
          Text(
            unit.isEmpty ? _value.toStringAsFixed(0) : '${_value.toStringAsFixed(0)}$unit',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            thumbColor: colorScheme.primary,
            overlayColor: colorScheme.primary.withOpacity(0.12),
          ),
          child: Slider(
            value: _value,
            min: _min,
            max: _max,
            divisions: _divisions > 0 ? _divisions : null,
            onChanged: widget.isExecuting
                ? null
                : (value) {
                    setState(() => _value = value);
                  },
            onChangeEnd: widget.isExecuting ? null : widget.onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              unit.isEmpty ? _min.toStringAsFixed(0) : '${_min.toStringAsFixed(0)}$unit',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              unit.isEmpty ? _max.toStringAsFixed(0) : '${_max.toStringAsFixed(0)}$unit',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
