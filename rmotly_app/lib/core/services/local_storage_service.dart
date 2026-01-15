import 'package:hive_flutter/hive_flutter.dart';
import 'package:rmotly_client/rmotly_client.dart';

/// Service for local data caching and user preferences using Hive
class LocalStorageService {
  static const String _controlsBoxName = 'controls';
  static const String _actionsBoxName = 'actions';
  static const String _topicsBoxName = 'topics';
  static const String _preferencesBoxName = 'preferences';

  // Lazy boxes for data caching
  Box<Control>? _controlsBox;
  Box<Action>? _actionsBox;
  Box<NotificationTopic>? _topicsBox;
  Box<dynamic>? _preferencesBox;

  /// Initialize the local storage service
  /// Should be called after Hive.init()
  Future<void> init() async {
    _controlsBox = await Hive.openBox<Control>(_controlsBoxName);
    _actionsBox = await Hive.openBox<Action>(_actionsBoxName);
    _topicsBox = await Hive.openBox<NotificationTopic>(_topicsBoxName);
    _preferencesBox = await Hive.openBox<dynamic>(_preferencesBoxName);
  }

  /// Cache controls locally
  Future<void> cacheControls(List<Control> controls) async {
    final box = _controlsBox;
    if (box == null) throw StateError('LocalStorageService not initialized');

    await box.clear();
    for (var i = 0; i < controls.length; i++) {
      await box.put(i, controls[i]);
    }
  }

  /// Get cached controls
  Future<List<Control>> getCachedControls() async {
    final box = _controlsBox;
    if (box == null) throw StateError('LocalStorageService not initialized');

    return box.values.toList();
  }

  /// Cache actions locally
  Future<void> cacheActions(List<Action> actions) async {
    final box = _actionsBox;
    if (box == null) throw StateError('LocalStorageService not initialized');

    await box.clear();
    for (var i = 0; i < actions.length; i++) {
      await box.put(i, actions[i]);
    }
  }

  /// Get cached actions
  Future<List<Action>> getCachedActions() async {
    final box = _actionsBox;
    if (box == null) throw StateError('LocalStorageService not initialized');

    return box.values.toList();
  }

  /// Cache topics locally
  Future<void> cacheTopics(List<NotificationTopic> topics) async {
    final box = _topicsBox;
    if (box == null) throw StateError('LocalStorageService not initialized');

    await box.clear();
    for (var i = 0; i < topics.length; i++) {
      await box.put(i, topics[i]);
    }
  }

  /// Get cached topics
  Future<List<NotificationTopic>> getCachedTopics() async {
    final box = _topicsBox;
    if (box == null) throw StateError('LocalStorageService not initialized');

    return box.values.toList();
  }

  /// Store a user preference
  Future<void> setPreference(String key, dynamic value) async {
    final box = _preferencesBox;
    if (box == null) throw StateError('LocalStorageService not initialized');

    await box.put(key, value);
  }

  /// Get a user preference
  Future<T?> getPreference<T>(String key) async {
    final box = _preferencesBox;
    if (box == null) throw StateError('LocalStorageService not initialized');

    final value = box.get(key);
    return value as T?;
  }

  /// Close all boxes (for cleanup)
  Future<void> close() async {
    await _controlsBox?.close();
    await _actionsBox?.close();
    await _topicsBox?.close();
    await _preferencesBox?.close();
  }

  /// Clear all cached data
  Future<void> clearAll() async {
    await _controlsBox?.clear();
    await _actionsBox?.clear();
    await _topicsBox?.clear();
    await _preferencesBox?.clear();
  }
}
