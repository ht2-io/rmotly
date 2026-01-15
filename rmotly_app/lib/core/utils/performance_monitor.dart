import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Performance monitoring utility for tracking and logging performance metrics.
///
/// Use this in debug mode to measure the performance impact of optimizations.
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<int>> _measurements = {};

  /// Start timing an operation
  static void startTimer(String label) {
    if (kReleaseMode) return;

    _timers[label] = Stopwatch()..start();
  }

  /// Stop timing an operation and log the result
  static void stopTimer(String label) {
    if (kReleaseMode) return;

    final timer = _timers[label];
    if (timer == null) {
      developer.log('Timer not found: $label', name: 'PerformanceMonitor');
      return;
    }

    timer.stop();
    final elapsed = timer.elapsedMilliseconds;

    // Store measurement
    _measurements.putIfAbsent(label, () => []);
    _measurements[label]!.add(elapsed);

    developer.log(
      '$label completed in ${elapsed}ms',
      name: 'PerformanceMonitor',
    );

    _timers.remove(label);
  }

  /// Measure a synchronous operation
  static T measure<T>(String label, T Function() operation) {
    if (kReleaseMode) return operation();

    startTimer(label);
    try {
      return operation();
    } finally {
      stopTimer(label);
    }
  }

  /// Measure an asynchronous operation
  static Future<T> measureAsync<T>(
    String label,
    Future<T> Function() operation,
  ) async {
    if (kReleaseMode) return await operation();

    startTimer(label);
    try {
      return await operation();
    } finally {
      stopTimer(label);
    }
  }

  /// Get statistics for a measured operation
  static PerformanceStats? getStats(String label) {
    final measurements = _measurements[label];
    if (measurements == null || measurements.isEmpty) return null;

    final sorted = List<int>.from(measurements)..sort();
    final sum = measurements.reduce((a, b) => a + b);
    final avg = sum / measurements.length;
    final min = sorted.first;
    final max = sorted.last;
    final median = sorted[sorted.length ~/ 2];
    final p95 = sorted[(sorted.length * 0.95).toInt()];

    return PerformanceStats(
      label: label,
      count: measurements.length,
      average: avg,
      min: min,
      max: max,
      median: median.toDouble(),
      p95: p95.toDouble(),
    );
  }

  /// Print statistics for all measured operations
  static void printAllStats() {
    if (kReleaseMode) return;

    developer.log('=== Performance Statistics ===', name: 'PerformanceMonitor');

    for (final label in _measurements.keys) {
      final stats = getStats(label);
      if (stats != null) {
        developer.log(
          '$label: ${stats.toString()}',
          name: 'PerformanceMonitor',
        );
      }
    }
  }

  /// Clear all measurements
  static void clear() {
    _timers.clear();
    _measurements.clear();
  }

  /// Mark a build event
  static void markBuild(String widgetName) {
    if (kReleaseMode) return;

    developer.log(
      'Built: $widgetName',
      name: 'PerformanceMonitor',
      level: 800,
    );
  }

  /// Mark a rebuild event
  static void markRebuild(String widgetName, {String? reason}) {
    if (kReleaseMode) return;

    final message = reason != null
        ? 'Rebuilt: $widgetName (reason: $reason)'
        : 'Rebuilt: $widgetName';

    developer.log(
      message,
      name: 'PerformanceMonitor',
      level: 900,
    );
  }
}

/// Performance statistics for a measured operation
class PerformanceStats {
  final String label;
  final int count;
  final double average;
  final int min;
  final int max;
  final double median;
  final double p95;

  PerformanceStats({
    required this.label,
    required this.count,
    required this.average,
    required this.min,
    required this.max,
    required this.median,
    required this.p95,
  });

  @override
  String toString() {
    return 'count=$count, avg=${average.toStringAsFixed(2)}ms, '
        'min=${min}ms, max=${max}ms, median=${median.toStringAsFixed(2)}ms, '
        'p95=${p95.toStringAsFixed(2)}ms';
  }
}

/// Mixin for widgets to track build performance
mixin PerformanceTracking on Widget {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    PerformanceMonitor.markBuild(runtimeType.toString());
    return super.toString(minLevel: minLevel);
  }
}
