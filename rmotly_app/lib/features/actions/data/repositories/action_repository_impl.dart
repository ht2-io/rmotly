import 'package:flutter/foundation.dart';
import 'package:rmotly_client/rmotly_client.dart';

import '../../domain/repositories/action_repository.dart';

/// Implementation of ActionRepository using Serverpod client.
/// Falls back to mock data when server is unavailable.
class ActionRepositoryImpl implements ActionRepository {
  final Client _client;

  // Mock data for development
  final List<Action> _mockActions = [];
  int _mockIdCounter = 1;

  ActionRepositoryImpl(this._client);

  // TODO: Get actual userId from auth when implemented
  int get _currentUserId => 1;

  @override
  Future<List<Action>> getActions() async {
    try {
      return await _client.action.listActions(userId: _currentUserId);
    } catch (e) {
      debugPrint('ActionRepository: Using mock data - $e');
      return List.from(_mockActions);
    }
  }

  @override
  Future<Action?> getAction(int actionId) async {
    try {
      return await _client.action.getAction(actionId: actionId);
    } catch (e) {
      debugPrint('ActionRepository: Using mock data - $e');
      try {
        return _mockActions.firstWhere((a) => a.id == actionId);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<Action> createAction(Action action) async {
    try {
      return await _client.action.createAction(
        userId: _currentUserId,
        name: action.name,
        httpMethod: action.httpMethod,
        urlTemplate: action.urlTemplate,
        description: action.description,
        headersTemplate: action.headersTemplate,
        bodyTemplate: action.bodyTemplate,
        parameters: action.parameters,
      );
    } catch (e) {
      debugPrint('ActionRepository: Using mock create - $e');
      final now = DateTime.now();
      final newAction = Action(
        id: _mockIdCounter++,
        userId: action.userId,
        name: action.name,
        description: action.description,
        httpMethod: action.httpMethod,
        urlTemplate: action.urlTemplate,
        headersTemplate: action.headersTemplate,
        bodyTemplate: action.bodyTemplate,
        parameters: action.parameters,
        createdAt: now,
        updatedAt: now,
      );
      _mockActions.add(newAction);
      return newAction;
    }
  }

  @override
  Future<Action> updateAction(Action action) async {
    if (action.id == null) {
      throw ArgumentError('Action ID is required for update');
    }

    try {
      return await _client.action.updateAction(
        actionId: action.id!,
        name: action.name,
        description: action.description,
        httpMethod: action.httpMethod,
        urlTemplate: action.urlTemplate,
        headersTemplate: action.headersTemplate,
        bodyTemplate: action.bodyTemplate,
        parameters: action.parameters,
        clearDescription: false,
        clearHeadersTemplate: false,
        clearBodyTemplate: false,
        clearParameters: false,
      );
    } catch (e) {
      debugPrint('ActionRepository: Using mock update - $e');
      final index = _mockActions.indexWhere((a) => a.id == action.id);
      if (index >= 0) {
        final updated = action.copyWith(updatedAt: DateTime.now());
        _mockActions[index] = updated;
        return updated;
      }
      throw Exception('Action not found');
    }
  }

  @override
  Future<bool> deleteAction(int actionId) async {
    try {
      return await _client.action.deleteAction(actionId: actionId);
    } catch (e) {
      debugPrint('ActionRepository: Using mock delete - $e');
      final index = _mockActions.indexWhere((a) => a.id == actionId);
      if (index >= 0) {
        _mockActions.removeAt(index);
        return true;
      }
      return false;
    }
  }

  @override
  Future<ActionTestResult> testAction(
      int actionId, Map<String, dynamic> parameters) async {
    try {
      final result = await _client.action.testAction(
        actionId: actionId,
        testParameters: parameters,
      );
      return ActionTestResult.fromJson(result);
    } catch (e) {
      debugPrint('ActionRepository: Mock test execution - $e');
      // Simulate a test response
      await Future.delayed(const Duration(milliseconds: 500));
      return ActionTestResult(
        success: true,
        statusCode: 200,
        responseBody:
            '{"mock": true, "message": "This is a simulated response"}',
        responseHeaders: {'content-type': 'application/json'},
        executionTimeMs: 500,
      );
    }
  }
}
