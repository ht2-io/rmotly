import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

/// Result of an action execution
class ActionResult {
  /// Whether the action executed successfully
  final bool success;

  /// Error message if execution failed
  final String? error;

  /// HTTP status code from the response
  final int? statusCode;

  /// Response body
  final String? responseBody;

  /// Response headers
  final Map<String, String>? responseHeaders;

  /// Execution time in milliseconds
  final int executionTimeMs;

  ActionResult({
    required this.success,
    this.error,
    this.statusCode,
    this.responseBody,
    this.responseHeaders,
    required this.executionTimeMs,
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        if (error != null) 'error': error,
        if (statusCode != null) 'statusCode': statusCode,
        if (responseBody != null) 'responseBody': responseBody,
        if (responseHeaders != null) 'responseHeaders': responseHeaders,
        'executionTimeMs': executionTimeMs,
      };
}

/// Configuration for action execution
class ActionConfig {
  /// HTTP method (GET, POST, PUT, DELETE, PATCH)
  final String httpMethod;

  /// URL template with {{variable}} placeholders
  final String urlTemplate;

  /// Headers template as JSON string
  final String? headersTemplate;

  /// Body template with {{variable}} placeholders
  final String? bodyTemplate;

  ActionConfig({
    required this.httpMethod,
    required this.urlTemplate,
    this.headersTemplate,
    this.bodyTemplate,
  });
}

/// Service for executing HTTP actions with template variable substitution.
///
/// Features:
/// - Template variable substitution ({{variable}} syntax)
/// - Support for all HTTP methods
/// - Retry logic with exponential backoff
/// - Timeout handling
/// - Response parsing
class ActionExecutorService {
  /// Default request timeout
  static const defaultTimeout = Duration(seconds: 30);

  /// Maximum number of retry attempts
  static const maxRetries = 3;

  /// Base delay for exponential backoff
  static const baseRetryDelay = Duration(seconds: 1);

  final HttpClient _httpClient;

  ActionExecutorService() : _httpClient = HttpClient() {
    _httpClient.connectionTimeout = defaultTimeout;
  }

  /// Execute an action with the given parameters
  ///
  /// [config] - Action configuration (method, URL template, etc.)
  /// [parameters] - Variable values to substitute in templates
  /// [session] - Serverpod session for logging
  Future<ActionResult> execute(
    ActionConfig config,
    Map<String, dynamic>? parameters, {
    Session? session,
    Duration timeout = defaultTimeout,
    int retryCount = 0,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Substitute variables in URL
      final url = substituteVariables(config.urlTemplate, parameters ?? {});

      // Validate URL
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        throw ActionExecutionException(
          'Invalid URL scheme: ${uri.scheme}. Must be http or https.',
        );
      }

      // Substitute variables in headers
      Map<String, String> headers = {};
      if (config.headersTemplate != null && config.headersTemplate!.isNotEmpty) {
        final headersJson =
            substituteVariables(config.headersTemplate!, parameters ?? {});
        try {
          final decoded = jsonDecode(headersJson) as Map<String, dynamic>;
          headers = decoded.map((k, v) => MapEntry(k, v.toString()));
        } catch (e) {
          throw ActionExecutionException('Invalid headers JSON: $e');
        }
      }

      // Substitute variables in body
      String? body;
      if (config.bodyTemplate != null && config.bodyTemplate!.isNotEmpty) {
        body = substituteVariables(config.bodyTemplate!, parameters ?? {});
      }

      // Execute the request
      final result = await _executeRequest(
        method: config.httpMethod,
        uri: uri,
        headers: headers,
        body: body,
        timeout: timeout,
      );

      stopwatch.stop();

      session?.log(
        'Action executed: ${config.httpMethod} $url -> ${result.statusCode}',
        level: LogLevel.info,
      );

      return ActionResult(
        success: result.statusCode >= 200 && result.statusCode < 300,
        statusCode: result.statusCode,
        responseBody: result.body,
        responseHeaders: result.headers,
        executionTimeMs: stopwatch.elapsedMilliseconds,
      );
    } on SocketException catch (e) {
      stopwatch.stop();

      // Retry on network errors
      if (retryCount < maxRetries) {
        final delay = baseRetryDelay * (1 << retryCount); // Exponential backoff
        session?.log(
          'Action failed, retrying in ${delay.inSeconds}s: $e',
          level: LogLevel.warning,
        );
        await Future.delayed(delay);
        return execute(
          config,
          parameters,
          session: session,
          timeout: timeout,
          retryCount: retryCount + 1,
        );
      }

      return ActionResult(
        success: false,
        error: 'Network error after $maxRetries retries: $e',
        executionTimeMs: stopwatch.elapsedMilliseconds,
      );
    } on TimeoutException catch (e) {
      stopwatch.stop();
      return ActionResult(
        success: false,
        error: 'Request timed out after ${timeout.inSeconds}s: $e',
        executionTimeMs: stopwatch.elapsedMilliseconds,
      );
    } on ActionExecutionException catch (e) {
      stopwatch.stop();
      return ActionResult(
        success: false,
        error: e.message,
        executionTimeMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      return ActionResult(
        success: false,
        error: 'Unexpected error: $e',
        executionTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  /// Substitute template variables in a string
  ///
  /// Variables use the syntax: {{variableName}}
  /// Missing variables are replaced with empty string.
  String substituteVariables(String template, Map<String, dynamic> variables) {
    return template.replaceAllMapped(
      RegExp(r'\{\{(\w+)\}\}'),
      (match) {
        final variableName = match.group(1)!;
        final value = variables[variableName];
        if (value == null) {
          return '';
        }
        // Handle different value types
        if (value is String) {
          return value;
        }
        if (value is num || value is bool) {
          return value.toString();
        }
        // For complex objects, JSON encode
        return jsonEncode(value);
      },
    );
  }

  /// Execute an HTTP request
  Future<_HttpResponse> _executeRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
    required Duration timeout,
  }) async {
    late HttpClientRequest request;

    switch (method.toUpperCase()) {
      case 'GET':
        request = await _httpClient.getUrl(uri);
        break;
      case 'POST':
        request = await _httpClient.postUrl(uri);
        break;
      case 'PUT':
        request = await _httpClient.putUrl(uri);
        break;
      case 'DELETE':
        request = await _httpClient.deleteUrl(uri);
        break;
      case 'PATCH':
        request = await _httpClient.patchUrl(uri);
        break;
      case 'HEAD':
        request = await _httpClient.headUrl(uri);
        break;
      default:
        throw ActionExecutionException('Unsupported HTTP method: $method');
    }

    // Set default headers
    request.headers.set('Accept', 'application/json');
    request.headers.set('User-Agent', 'Rmotly/1.0');

    // Set custom headers
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });

    // Write body if present
    if (body != null && body.isNotEmpty) {
      if (!headers.containsKey('Content-Type')) {
        request.headers.set('Content-Type', 'application/json');
      }
      request.write(body);
    }

    // Send request with timeout
    final response = await request.close().timeout(timeout);

    // Read response body
    final responseBody = await response.transform(utf8.decoder).join();

    // Extract response headers
    final responseHeaders = <String, String>{};
    response.headers.forEach((name, values) {
      responseHeaders[name] = values.join(', ');
    });

    return _HttpResponse(
      statusCode: response.statusCode,
      body: responseBody,
      headers: responseHeaders,
    );
  }

  /// Test an action without actually executing it
  ///
  /// Returns the resolved URL, headers, and body after variable substitution.
  Map<String, dynamic> testSubstitution(
    ActionConfig config,
    Map<String, dynamic> parameters,
  ) {
    final url = substituteVariables(config.urlTemplate, parameters);

    Map<String, dynamic>? headers;
    if (config.headersTemplate != null && config.headersTemplate!.isNotEmpty) {
      final headersJson = substituteVariables(config.headersTemplate!, parameters);
      try {
        headers = jsonDecode(headersJson) as Map<String, dynamic>;
      } catch (_) {
        headers = {'_raw': headersJson};
      }
    }

    String? body;
    if (config.bodyTemplate != null && config.bodyTemplate!.isNotEmpty) {
      body = substituteVariables(config.bodyTemplate!, parameters);
    }

    return {
      'method': config.httpMethod,
      'url': url,
      if (headers != null) 'headers': headers,
      if (body != null) 'body': body,
    };
  }

  /// Close the HTTP client
  void close() {
    _httpClient.close();
  }
}

/// Internal HTTP response holder
class _HttpResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  _HttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });
}

/// Exception thrown during action execution
class ActionExecutionException implements Exception {
  final String message;
  final int? statusCode;

  ActionExecutionException(this.message, {this.statusCode});

  @override
  String toString() => 'ActionExecutionException: $message';
}
