import 'package:flutter/widgets.dart';

/// Wrapper that prevents unnecessary rebuilds by isolating a subtree.
///
/// Use this to optimize expensive widgets that don't need to rebuild
/// when their parent rebuilds. The child widget should be const whenever possible.
class RepaintBoundaryWrapper extends StatelessWidget {
  const RepaintBoundaryWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: child,
    );
  }
}

/// Memoizes a widget to prevent rebuilds when dependencies don't change.
///
/// Similar to React.memo, this widget will only rebuild when its
/// dependencies change. Useful for optimizing list items or expensive widgets.
class MemoizedWidget extends StatefulWidget {
  const MemoizedWidget({
    super.key,
    required this.builder,
    this.dependencies,
  });

  final Widget Function(BuildContext context) builder;
  final List<Object?>? dependencies;

  @override
  State<MemoizedWidget> createState() => _MemoizedWidgetState();
}

class _MemoizedWidgetState extends State<MemoizedWidget> {
  Widget? _cachedWidget;
  List<Object?>? _previousDependencies;

  @override
  Widget build(BuildContext context) {
    // Check if dependencies have changed
    final depsChanged = _dependenciesChanged();

    if (_cachedWidget == null || depsChanged) {
      _cachedWidget = widget.builder(context);
      _previousDependencies = widget.dependencies;
    }

    return _cachedWidget!;
  }

  bool _dependenciesChanged() {
    final current = widget.dependencies;
    final previous = _previousDependencies;

    if (current == null && previous == null) return false;
    if (current == null || previous == null) return true;
    if (current.length != previous.length) return true;

    for (var i = 0; i < current.length; i++) {
      if (current[i] != previous[i]) return true;
    }

    return false;
  }
}
