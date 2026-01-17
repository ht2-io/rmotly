import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../../domain/repositories/topic_repository.dart';

/// Implementation of TopicRepository using Serverpod client.
/// Falls back to mock data when server is unavailable.
class TopicRepositoryImpl implements TopicRepository {
  final Client _client;
  final String _baseUrl;

  // Mock data for development
  final List<NotificationTopic> _mockTopics = [];
  int _mockIdCounter = 1;

  TopicRepositoryImpl(this._client, {String? baseUrl})
      : _baseUrl = baseUrl ?? 'https://api.rmotly.app';

  @override
  Future<List<NotificationTopic>> getTopics() async {
    try {
      return await _client.notification.listTopics(includeDisabled: true);
    } catch (e) {
      debugPrint('TopicRepository: Using mock data - $e');
      return List.from(_mockTopics);
    }
  }

  @override
  Future<NotificationTopic?> getTopic(int topicId) async {
    try {
      return await _client.notification.getTopic(topicId: topicId);
    } catch (e) {
      debugPrint('TopicRepository: Using mock data - $e');
      try {
        return _mockTopics.firstWhere((t) => t.id == topicId);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<NotificationTopic> createTopic(NotificationTopic topic) async {
    try {
      return await _client.notification.createTopic(
        name: topic.name,
        description: topic.description,
        config: topic.config,
      );
    } catch (e) {
      debugPrint('TopicRepository: Using mock create - $e');
      final now = DateTime.now();
      final newTopic = NotificationTopic(
        id: _mockIdCounter++,
        userId: topic.userId,
        name: topic.name,
        description: topic.description,
        apiKey: _generateApiKey(),
        enabled: true,
        config: topic.config,
        createdAt: now,
        updatedAt: now,
      );
      _mockTopics.add(newTopic);
      return newTopic;
    }
  }

  @override
  Future<NotificationTopic> updateTopic(NotificationTopic topic) async {
    if (topic.id == null) {
      throw ArgumentError('Topic ID is required for update');
    }

    try {
      return await _client.notification.updateTopic(
        topicId: topic.id!,
        name: topic.name,
        description: topic.description,
        config: topic.config,
      );
    } catch (e) {
      debugPrint('TopicRepository: Using mock update - $e');
      final index = _mockTopics.indexWhere((t) => t.id == topic.id);
      if (index >= 0) {
        final updated = topic.copyWith(updatedAt: DateTime.now());
        _mockTopics[index] = updated;
        return updated;
      }
      throw Exception('Topic not found');
    }
  }

  @override
  Future<bool> deleteTopic(int topicId) async {
    try {
      return await _client.notification.deleteTopic(topicId: topicId);
    } catch (e) {
      debugPrint('TopicRepository: Using mock delete - $e');
      final index = _mockTopics.indexWhere((t) => t.id == topicId);
      if (index >= 0) {
        _mockTopics.removeAt(index);
        return true;
      }
      return false;
    }
  }

  @override
  Future<NotificationTopic> toggleTopic(int topicId, bool enabled) async {
    try {
      return await _client.notification.updateTopic(
        topicId: topicId,
        enabled: enabled,
      );
    } catch (e) {
      debugPrint('TopicRepository: Using mock toggle - $e');
      final index = _mockTopics.indexWhere((t) => t.id == topicId);
      if (index >= 0) {
        final updated = _mockTopics[index].copyWith(
          enabled: enabled,
          updatedAt: DateTime.now(),
        );
        _mockTopics[index] = updated;
        return updated;
      }
      throw Exception('Topic not found');
    }
  }

  @override
  Future<NotificationTopic> regenerateApiKey(int topicId) async {
    try {
      return await _client.notification.regenerateApiKey(topicId: topicId);
    } catch (e) {
      debugPrint('TopicRepository: Using mock regenerate - $e');
      final index = _mockTopics.indexWhere((t) => t.id == topicId);
      if (index >= 0) {
        final updated = _mockTopics[index].copyWith(
          apiKey: _generateApiKey(),
          updatedAt: DateTime.now(),
        );
        _mockTopics[index] = updated;
        return updated;
      }
      throw Exception('Topic not found');
    }
  }

  @override
  String getWebhookUrl(int topicId) {
    return '$_baseUrl/api/notify/$topicId';
  }

  String _generateApiKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
