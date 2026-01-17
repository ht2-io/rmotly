import 'package:flutter/material.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../viewmodel/dashboard_viewmodel.dart';

/// Widget for button control type
class ButtonControlWidget extends StatelessWidget {
  final Control control;
  final VoidCallback onPressed;
  final bool isExecuting;

  const ButtonControlWidget({
    super.key,
    required this.control,
    required this.onPressed,
    this.isExecuting = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = parseControlConfig(control.config);

    final label = config['label'] as String? ?? 'Press';
    final icon = config['icon'] as String?;

    return FilledButton.icon(
      onPressed: isExecuting ? null : onPressed,
      icon: icon != null
          ? Icon(_getIconFromName(icon))
          : const Icon(Icons.touch_app),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(120, 56),
      ),
    );
  }

  IconData _getIconFromName(String name) {
    // Map common icon names to IconData
    switch (name.toLowerCase()) {
      case 'power':
        return Icons.power_settings_new;
      case 'play':
        return Icons.play_arrow;
      case 'stop':
        return Icons.stop;
      case 'refresh':
        return Icons.refresh;
      case 'send':
        return Icons.send;
      case 'light':
        return Icons.lightbulb;
      case 'lock':
        return Icons.lock;
      case 'unlock':
        return Icons.lock_open;
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.touch_app;
    }
  }
}
