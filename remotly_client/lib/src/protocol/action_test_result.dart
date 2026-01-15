/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class ActionTestResult implements _i1.SerializableModel {
  ActionTestResult._({
    required this.success,
    this.error,
    this.statusCode,
    this.responseBody,
    this.responseHeaders,
    required this.executionTimeMs,
    this.resolvedUrl,
    this.resolvedHeaders,
    this.resolvedBody,
  });

  factory ActionTestResult({
    required bool success,
    String? error,
    int? statusCode,
    String? responseBody,
    String? responseHeaders,
    required int executionTimeMs,
    String? resolvedUrl,
    String? resolvedHeaders,
    String? resolvedBody,
  }) = _ActionTestResultImpl;

  factory ActionTestResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ActionTestResult(
      success: jsonSerialization['success'] as bool,
      error: jsonSerialization['error'] as String?,
      statusCode: jsonSerialization['statusCode'] as int?,
      responseBody: jsonSerialization['responseBody'] as String?,
      responseHeaders: jsonSerialization['responseHeaders'] as String?,
      executionTimeMs: jsonSerialization['executionTimeMs'] as int,
      resolvedUrl: jsonSerialization['resolvedUrl'] as String?,
      resolvedHeaders: jsonSerialization['resolvedHeaders'] as String?,
      resolvedBody: jsonSerialization['resolvedBody'] as String?,
    );
  }

  /// Whether the test execution was successful
  bool success;

  /// Error message if test failed
  String? error;

  /// HTTP status code from the response
  int? statusCode;

  /// Response body from the test execution
  String? responseBody;

  /// Response headers as JSON string
  String? responseHeaders;

  /// Execution time in milliseconds
  int executionTimeMs;

  /// Resolved URL after variable substitution
  String? resolvedUrl;

  /// Resolved headers after variable substitution
  String? resolvedHeaders;

  /// Resolved body after variable substitution
  String? resolvedBody;

  /// Returns a shallow copy of this [ActionTestResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ActionTestResult copyWith({
    bool? success,
    String? error,
    int? statusCode,
    String? responseBody,
    String? responseHeaders,
    int? executionTimeMs,
    String? resolvedUrl,
    String? resolvedHeaders,
    String? resolvedBody,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (error != null) 'error': error,
      if (statusCode != null) 'statusCode': statusCode,
      if (responseBody != null) 'responseBody': responseBody,
      if (responseHeaders != null) 'responseHeaders': responseHeaders,
      'executionTimeMs': executionTimeMs,
      if (resolvedUrl != null) 'resolvedUrl': resolvedUrl,
      if (resolvedHeaders != null) 'resolvedHeaders': resolvedHeaders,
      if (resolvedBody != null) 'resolvedBody': resolvedBody,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ActionTestResultImpl extends ActionTestResult {
  _ActionTestResultImpl({
    required bool success,
    String? error,
    int? statusCode,
    String? responseBody,
    String? responseHeaders,
    required int executionTimeMs,
    String? resolvedUrl,
    String? resolvedHeaders,
    String? resolvedBody,
  }) : super._(
          success: success,
          error: error,
          statusCode: statusCode,
          responseBody: responseBody,
          responseHeaders: responseHeaders,
          executionTimeMs: executionTimeMs,
          resolvedUrl: resolvedUrl,
          resolvedHeaders: resolvedHeaders,
          resolvedBody: resolvedBody,
        );

  /// Returns a shallow copy of this [ActionTestResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ActionTestResult copyWith({
    bool? success,
    Object? error = _Undefined,
    Object? statusCode = _Undefined,
    Object? responseBody = _Undefined,
    Object? responseHeaders = _Undefined,
    int? executionTimeMs,
    Object? resolvedUrl = _Undefined,
    Object? resolvedHeaders = _Undefined,
    Object? resolvedBody = _Undefined,
  }) {
    return ActionTestResult(
      success: success ?? this.success,
      error: error is String? ? error : this.error,
      statusCode: statusCode is int? ? statusCode : this.statusCode,
      responseBody: responseBody is String? ? responseBody : this.responseBody,
      responseHeaders:
          responseHeaders is String? ? responseHeaders : this.responseHeaders,
      executionTimeMs: executionTimeMs ?? this.executionTimeMs,
      resolvedUrl: resolvedUrl is String? ? resolvedUrl : this.resolvedUrl,
      resolvedHeaders:
          resolvedHeaders is String? ? resolvedHeaders : this.resolvedHeaders,
      resolvedBody: resolvedBody is String? ? resolvedBody : this.resolvedBody,
    );
  }
}
