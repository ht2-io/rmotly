/// API-related constants
///
/// Contains API endpoints, parameter names, header keys, and other
/// API-specific configuration.
class ApiConstants {
  ApiConstants._();

  // Base URLs (should be configured per environment)
  static const String developmentBaseUrl = 'http://localhost:8080/';
  static const String stagingBaseUrl = 'https://staging.rmotly.app/';
  static const String productionBaseUrl = 'https://api.rmotly.app/';

  // API Endpoints
  static const String eventsEndpoint = 'events';
  static const String controlsEndpoint = 'controls';
  static const String actionsEndpoint = 'actions';
  static const String topicsEndpoint = 'topics';
  static const String notificationsEndpoint = 'notifications';
  static const String openApiEndpoint = 'openapi';
  static const String authEndpoint = 'auth';

  // Webhook Routes
  static const String notifyWebhookPath = '/api/notify';

  // Query Parameters
  static const String limitParam = 'limit';
  static const String offsetParam = 'offset';
  static const String sortParam = 'sort';
  static const String orderParam = 'order';

  // Headers
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String apiKeyHeader = 'X-API-Key';

  // Content Types
  static const String jsonContentType = 'application/json';
  static const String formContentType = 'application/x-www-form-urlencoded';

  // API Key Configuration
  static const String apiKeyPrefix = 'rmt_key_';
  static const int apiKeyLength = 32;

  // Pagination Defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Built-in Variable Names (for template substitution)
  static const String controlValueVariable = 'controlValue';
  static const String controlIdVariable = 'controlId';
  static const String timestampVariable = 'timestamp';
  static const String userIdVariable = 'userId';
}
