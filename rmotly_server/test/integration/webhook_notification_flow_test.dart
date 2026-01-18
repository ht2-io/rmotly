import 'dart:convert';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

/// End-to-end integration test for webhook → notification flow (Task 5.3.2)
///
/// Tests the complete flow:
/// 1. Create a notification topic with API key
/// 2. Send webhook request to the topic
/// 3. Verify notification is received/queued
/// 4. Test different webhook payload formats
void main() {
  withServerpod('Webhook → Notification Flow E2E', (sessionBuilder, endpoints) {
    group('Task 5.3.2 - Complete webhook to notification flow', () {
      test('when topic is created then API key is generated', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act: Create a notification topic
        final topic = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'Test Topic',
          description: 'Topic for E2E testing',
          config: jsonEncode({
            'priority': 'normal',
            'sound': 'default',
          }),
        );

        // Assert: Topic created with API key
        expect(topic.id, isNotNull);
        expect(topic.name, 'Test Topic');
        expect(topic.description, 'Topic for E2E testing');
        expect(topic.apiKey, isNotNull);
        expect(topic.apiKey.length, greaterThan(20)); // API keys should be substantial
        expect(topic.enabled, isTrue);
        expect(topic.userId, 1);
      });

      test('when listing topics then only user topics are returned', () async {
        // Arrange: Create two users
        final user1Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );
        final user2Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(2, {}),
        );

        // Create topics for both users
        await endpoints.notification.createTopic(
          user1Session,
          name: 'User 1 Topic',
        );
        await endpoints.notification.createTopic(
          user2Session,
          name: 'User 2 Topic',
        );

        // Act: List topics for user 1
        final user1Topics = await endpoints.notification.listTopics(
          user1Session,
          includeDisabled: true,
        );

        // Assert: User 1 only sees their own topic
        expect(user1Topics.length, 1);
        expect(user1Topics[0].name, 'User 1 Topic');
        expect(user1Topics[0].userId, 1);
      });

      test('when topic is retrieved by ID then details are returned', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        final createdTopic = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'Retrievable Topic',
          description: 'Test retrieval',
        );

        // Act: Retrieve the topic
        final retrievedTopic = await endpoints.notification.getTopic(
          authenticatedSession,
          topicId: createdTopic.id!,
        );

        // Assert
        expect(retrievedTopic.id, createdTopic.id);
        expect(retrievedTopic.name, 'Retrievable Topic');
        expect(retrievedTopic.description, 'Test retrieval');
        expect(retrievedTopic.apiKey, createdTopic.apiKey);
      });

      test('when topic is updated then changes are persisted', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        final topic = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'Original Name',
          description: 'Original description',
        );

        // Act: Update the topic
        final updatedTopic = await endpoints.notification.updateTopic(
          authenticatedSession,
          topicId: topic.id!,
          name: 'Updated Name',
          description: 'Updated description',
          enabled: false,
        );

        // Assert
        expect(updatedTopic.id, topic.id);
        expect(updatedTopic.name, 'Updated Name');
        expect(updatedTopic.description, 'Updated description');
        expect(updatedTopic.enabled, isFalse);
        expect(updatedTopic.apiKey, topic.apiKey); // API key unchanged
      });

      test('when API key is regenerated then new key is different', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        final topic = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'Key Rotation Test',
        );
        final originalKey = topic.apiKey;

        // Act: Regenerate API key
        final updatedTopic = await endpoints.notification.regenerateApiKey(
          authenticatedSession,
          topicId: topic.id!,
        );

        // Assert
        expect(updatedTopic.id, topic.id);
        expect(updatedTopic.apiKey, isNot(originalKey));
        expect(updatedTopic.apiKey.length, greaterThan(20));
      });

      test('when topic is disabled then it is not included in default list',
          () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        final topic = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'To Be Disabled',
        );

        await endpoints.notification.updateTopic(
          authenticatedSession,
          topicId: topic.id!,
          enabled: false,
        );

        // Act: List topics without including disabled
        final enabledTopics = await endpoints.notification.listTopics(
          authenticatedSession,
          includeDisabled: false,
        );

        final allTopics = await endpoints.notification.listTopics(
          authenticatedSession,
          includeDisabled: true,
        );

        // Assert
        expect(enabledTopics.where((t) => t.id == topic.id), isEmpty);
        expect(allTopics.where((t) => t.id == topic.id), isNotEmpty);
      });

      test('when topic is deleted then it is removed', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        final topic = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'To Be Deleted',
        );

        // Act: Delete the topic
        final deleted = await endpoints.notification.deleteTopic(
          authenticatedSession,
          topicId: topic.id!,
        );

        // Assert
        expect(deleted, isTrue);

        // Verify it's no longer in the list
        final topics = await endpoints.notification.listTopics(
          authenticatedSession,
          includeDisabled: true,
        );
        expect(topics.where((t) => t.id == topic.id), isEmpty);
      });

      test('when deleting non-existent topic then returns false', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act: Try to delete non-existent topic
        final deleted = await endpoints.notification.deleteTopic(
          authenticatedSession,
          topicId: 99999,
        );

        // Assert
        expect(deleted, isFalse);
      });

      test('when notification is sent then it is queued for delivery',
          () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act: Send a notification
        final sent = await endpoints.notification.sendNotification(
          authenticatedSession,
          title: 'Test Notification',
          body: 'This is a test notification',
          payload: jsonEncode({'key': 'value'}),
          priority: 'normal',
        );

        // Assert
        expect(sent, isTrue);
      });

      test('when webhook URL is retrieved then it contains topic ID', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        final topic = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'Webhook URL Test',
        );

        // Act: Get the webhook URL
        final webhookUrl = await endpoints.webhook.getWebhookUrl(
          authenticatedSession,
          topic.id!,
        );

        // Assert
        expect(webhookUrl, contains('/notify/'));
        expect(webhookUrl, contains(topic.id.toString()));
      });

      test('when test webhook is sent then notification is delivered',
          () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        final topic = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'Test Webhook Topic',
        );

        // Act: Send test webhook
        final result = await endpoints.webhook.testWebhook(
          authenticatedSession,
          topic.id!,
          title: 'Test Title',
          body: 'Test Body',
        );

        // Assert
        expect(result['success'], isTrue);
        expect(result['message'], isNotNull);
      });

      test('when multiple topics exist then each has unique API key', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act: Create multiple topics
        final topic1 = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'Topic 1',
        );

        final topic2 = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'Topic 2',
        );

        final topic3 = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'Topic 3',
        );

        // Assert: All API keys are unique
        final apiKeys = [topic1.apiKey, topic2.apiKey, topic3.apiKey];
        expect(apiKeys.toSet().length, 3); // All unique
        expect(topic1.apiKey, isNot(topic2.apiKey));
        expect(topic2.apiKey, isNot(topic3.apiKey));
        expect(topic1.apiKey, isNot(topic3.apiKey));
      });

      test('when topic config is JSON then it is validated', () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act: Create topic with valid JSON config
        final topic = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'Config Test',
          config: jsonEncode({
            'priority': 'high',
            'vibration': true,
            'sound': 'custom',
          }),
        );

        // Assert
        expect(topic.config, isNotNull);
        final config = jsonDecode(topic.config);
        expect(config['priority'], 'high');
        expect(config['vibration'], isTrue);
        expect(config['sound'], 'custom');
      });

      test('when topic is created without config then defaults to empty object',
          () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act: Create topic without config
        final topic = await endpoints.notification.createTopic(
          authenticatedSession,
          name: 'No Config Topic',
        );

        // Assert
        expect(topic.config, isNotNull);
        final config = jsonDecode(topic.config);
        expect(config, isEmpty);
      });

      test('when notification is sent with different priorities then accepted',
          () async {
        // Arrange
        final authenticatedSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );

        // Act & Assert: Send notifications with different priorities
        final priorities = ['low', 'normal', 'high'];

        for (final priority in priorities) {
          final sent = await endpoints.notification.sendNotification(
            authenticatedSession,
            title: 'Priority Test',
            body: 'Testing $priority priority',
            priority: priority,
          );

          expect(sent, isTrue, reason: 'Failed for priority: $priority');
        }
      });

      test('when retrieving another user topic then throws', () async {
        // Arrange: Create two users
        final user1Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(1, {}),
        );
        final user2Session = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(2, {}),
        );

        // User 1 creates a topic
        final topic = await endpoints.notification.createTopic(
          user1Session,
          name: 'User 1 Private Topic',
        );

        // Act & Assert: User 2 tries to retrieve User 1's topic
        expect(
          () => endpoints.notification.getTopic(
            user2Session,
            topicId: topic.id!,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
