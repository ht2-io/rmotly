import 'dart:convert';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

/// End-to-end integration test for control → action flow (Task 5.3.1)
///
/// Tests the complete flow:
/// 1. Create an action (HTTP request template)
/// 2. Create a control linked to that action
/// 3. Trigger the control by sending an event
/// 4. Verify the action was executed and result stored
void main() {
  withServerpod('Control → Action Flow E2E', (sessionBuilder, endpoints) {
    group('Task 5.3.1 - Complete control to action execution flow', () {
      test(
          'when control is triggered then action executes and result is recorded',
          () async {
        // Arrange: Create authenticated session for user
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Step 1: Create an action that will be triggered
        // Using httpbin.org as a reliable test endpoint
        final action = await endpoints.action.createAction(
          authenticatedSession,
          userId: 1,
          name: 'Test HTTP Action',
          httpMethod: 'POST',
          urlTemplate: 'https://httpbin.org/post',
          description: 'Test action for E2E flow',
          headersTemplate: jsonEncode({
            'Content-Type': 'application/json',
          }),
          bodyTemplate: jsonEncode({
            'event': '{{eventType}}',
            'value': '{{value}}',
            'timestamp': '{{timestamp}}',
          }),
          parameters: jsonEncode({
            'eventType': {'type': 'string', 'required': true},
            'value': {'type': 'string', 'required': false},
          }),
        );

        expect(action.id, isNotNull);
        expect(action.name, 'Test HTTP Action');
        expect(action.httpMethod, 'POST');

        // Step 2: Create a control linked to the action
        final control = await endpoints.control.createControl(
          authenticatedSession,
          userId: 1,
          name: 'Test Button',
          controlType: 'button',
          config: jsonEncode({
            'icon': 'power',
            'color': '#FF5722',
          }),
          position: 0,
          actionId: action.id,
        );

        expect(control.id, isNotNull);
        expect(control.name, 'Test Button');
        expect(control.actionId, action.id);
        expect(control.userId, 1);

        // Step 3: Trigger the control by sending an event
        final event = await endpoints.event.sendEvent(
          authenticatedSession,
          sourceType: 'control',
          sourceId: control.id.toString(),
          eventType: 'button_press',
          payload: jsonEncode({
            'value': 'on',
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );

        // Assert: Verify event was created
        expect(event.id, isNotNull);
        expect(event.sourceType, 'control');
        expect(event.sourceId, control.id.toString());
        expect(event.eventType, 'button_press');
        expect(event.userId, 1);

        // Assert: Verify action result is recorded
        expect(event.actionResult, isNotNull);

        final actionResult = jsonDecode(event.actionResult!);
        expect(actionResult['success'], isTrue);
        expect(actionResult['statusCode'], 200);
        expect(actionResult['executionTimeMs'], greaterThan(0));

        // Optional: Verify the action received our payload
        if (actionResult['responseBody'] != null) {
          final responseBody =
              jsonDecode(actionResult['responseBody'] as String);
          // httpbin.org echoes back the JSON we sent
          expect(responseBody['json']['event'], 'button_press');
        }
      });

      test('when action fails then error is recorded in event', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Create an action that will fail (invalid URL)
        final action = await endpoints.action.createAction(
          authenticatedSession,
          userId: 1,
          name: 'Failing Action',
          httpMethod: 'GET',
          urlTemplate: 'https://invalid-domain-that-does-not-exist.com/api',
        );

        final control = await endpoints.control.createControl(
          authenticatedSession,
          userId: 1,
          name: 'Failing Button',
          controlType: 'button',
          config: '{}',
          position: 1,
          actionId: action.id,
        );

        // Act: Trigger the control
        final event = await endpoints.event.sendEvent(
          authenticatedSession,
          sourceType: 'control',
          sourceId: control.id.toString(),
          eventType: 'button_press',
        );

        // Assert: Event created but action failed
        expect(event.id, isNotNull);
        expect(event.actionResult, isNotNull);

        final actionResult = jsonDecode(event.actionResult!);
        expect(actionResult['success'], isFalse);
        expect(actionResult['error'], isNotNull);
      });

      test('when control has no action then event is recorded without execution',
          () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Create a control without an action
        final control = await endpoints.control.createControl(
          authenticatedSession,
          userId: 1,
          name: 'No Action Button',
          controlType: 'button',
          config: '{}',
          position: 2,
          actionId: null, // No action linked
        );

        // Act: Trigger the control
        final event = await endpoints.event.sendEvent(
          authenticatedSession,
          sourceType: 'control',
          sourceId: control.id.toString(),
          eventType: 'button_press',
        );

        // Assert: Event created but no action result
        expect(event.id, isNotNull);
        expect(event.sourceType, 'control');
        expect(event.eventType, 'button_press');
        expect(event.actionResult, isNull); // No action was executed
      });

      test('when action uses variable substitution then variables are replaced',
          () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Create action with template variables
        final action = await endpoints.action.createAction(
          authenticatedSession,
          userId: 1,
          name: 'Templated Action',
          httpMethod: 'POST',
          urlTemplate: 'https://httpbin.org/post',
          bodyTemplate: jsonEncode({
            'device': '{{device_id}}',
            'state': '{{state}}',
            'level': '{{level}}',
          }),
        );

        final control = await endpoints.control.createControl(
          authenticatedSession,
          userId: 1,
          name: 'Smart Light',
          controlType: 'slider',
          config: '{}',
          position: 3,
          actionId: action.id,
        );

        // Act: Send event with variable values
        final event = await endpoints.event.sendEvent(
          authenticatedSession,
          sourceType: 'control',
          sourceId: control.id.toString(),
          eventType: 'slider_change',
          payload: jsonEncode({
            'device_id': 'light_001',
            'state': 'on',
            'level': 75,
          }),
        );

        // Assert: Action executed successfully with variables substituted
        expect(event.actionResult, isNotNull);

        final actionResult = jsonDecode(event.actionResult!);
        expect(actionResult['success'], isTrue);

        // Verify variables were substituted in the request
        if (actionResult['responseBody'] != null) {
          final responseBody =
              jsonDecode(actionResult['responseBody'] as String);
          final sentData = responseBody['json'];
          expect(sentData['device'], 'light_001');
          expect(sentData['state'], 'on');
          // Template substitution converts all values to strings
          expect(sentData['level'], '75');
        }
      });

      test('when multiple controls share same action then all trigger it',
          () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Create one action
        final action = await endpoints.action.createAction(
          authenticatedSession,
          userId: 1,
          name: 'Shared Action',
          httpMethod: 'POST',
          urlTemplate: 'https://httpbin.org/post',
        );

        // Create two controls using the same action
        final control1 = await endpoints.control.createControl(
          authenticatedSession,
          userId: 1,
          name: 'Button 1',
          controlType: 'button',
          config: '{}',
          position: 4,
          actionId: action.id,
        );

        final control2 = await endpoints.control.createControl(
          authenticatedSession,
          userId: 1,
          name: 'Button 2',
          controlType: 'button',
          config: '{}',
          position: 5,
          actionId: action.id,
        );

        // Act: Trigger both controls
        final event1 = await endpoints.event.sendEvent(
          authenticatedSession,
          sourceType: 'control',
          sourceId: control1.id.toString(),
          eventType: 'button_press',
        );

        final event2 = await endpoints.event.sendEvent(
          authenticatedSession,
          sourceType: 'control',
          sourceId: control2.id.toString(),
          eventType: 'button_press',
        );

        // Assert: Both events executed the action successfully
        expect(event1.actionResult, isNotNull);
        expect(event2.actionResult, isNotNull);

        final result1 = jsonDecode(event1.actionResult!);
        final result2 = jsonDecode(event2.actionResult!);

        expect(result1['success'], isTrue);
        expect(result2['success'], isTrue);
      });

      test('when event is retrieved then it includes action result', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        final action = await endpoints.action.createAction(
          authenticatedSession,
          userId: 1,
          name: 'Test Action for Retrieval',
          httpMethod: 'GET',
          urlTemplate: 'https://httpbin.org/get',
        );

        final control = await endpoints.control.createControl(
          authenticatedSession,
          userId: 1,
          name: 'Test Control',
          controlType: 'button',
          config: '{}',
          position: 6,
          actionId: action.id,
        );

        final sentEvent = await endpoints.event.sendEvent(
          authenticatedSession,
          sourceType: 'control',
          sourceId: control.id.toString(),
          eventType: 'button_press',
        );

        // Act: Retrieve the event by ID
        final retrievedEvent = await endpoints.event.getEvent(
          authenticatedSession,
          eventId: sentEvent.id!,
        );

        // Assert: Retrieved event contains the action result
        expect(retrievedEvent.id, sentEvent.id);
        expect(retrievedEvent.actionResult, isNotNull);
        expect(retrievedEvent.actionResult, sentEvent.actionResult);

        final actionResult = jsonDecode(retrievedEvent.actionResult!);
        expect(actionResult['success'], isTrue);
        expect(actionResult['statusCode'], 200);
      });
    });
  });
}
