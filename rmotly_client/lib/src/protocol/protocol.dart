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
import 'greeting.dart' as _i2;
import 'action.dart' as _i3;
import 'control.dart' as _i4;
import 'event.dart' as _i5;
import 'notification_topic.dart' as _i6;
import 'openapi_operation.dart' as _i7;
import 'openapi_parameter.dart' as _i8;
import 'openapi_spec.dart' as _i9;
import 'user.dart' as _i10;
import 'package:rmotly_client/src/protocol/openapi_operation.dart' as _i11;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i12;
export 'greeting.dart';
export 'action.dart';
export 'control.dart';
export 'event.dart';
export 'notification_topic.dart';
export 'openapi_operation.dart';
export 'openapi_parameter.dart';
export 'openapi_spec.dart';
export 'user.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.Greeting) {
      return _i2.Greeting.fromJson(data) as T;
    }
    if (t == _i3.Action) {
      return _i3.Action.fromJson(data) as T;
    }
    if (t == _i4.Control) {
      return _i4.Control.fromJson(data) as T;
    }
    if (t == _i5.Event) {
      return _i5.Event.fromJson(data) as T;
    }
    if (t == _i6.NotificationTopic) {
      return _i6.NotificationTopic.fromJson(data) as T;
    }
    if (t == _i7.OpenApiOperation) {
      return _i7.OpenApiOperation.fromJson(data) as T;
    }
    if (t == _i8.OpenApiParameter) {
      return _i8.OpenApiParameter.fromJson(data) as T;
    }
    if (t == _i9.OpenApiSpec) {
      return _i9.OpenApiSpec.fromJson(data) as T;
    }
    if (t == _i10.User) {
      return _i10.User.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Greeting?>()) {
      return (data != null ? _i2.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Action?>()) {
      return (data != null ? _i3.Action.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Control?>()) {
      return (data != null ? _i4.Control.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Event?>()) {
      return (data != null ? _i5.Event.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.NotificationTopic?>()) {
      return (data != null ? _i6.NotificationTopic.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.OpenApiOperation?>()) {
      return (data != null ? _i7.OpenApiOperation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.OpenApiParameter?>()) {
      return (data != null ? _i8.OpenApiParameter.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.OpenApiSpec?>()) {
      return (data != null ? _i9.OpenApiSpec.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.User?>()) {
      return (data != null ? _i10.User.fromJson(data) : null) as T;
    }
    if (t == List<_i8.OpenApiParameter>) {
      return (data as List)
          .map((e) => deserialize<_i8.OpenApiParameter>(e))
          .toList() as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i7.OpenApiOperation>) {
      return (data as List)
          .map((e) => deserialize<_i7.OpenApiOperation>(e))
          .toList() as T;
    }
    if (t == List<_i11.OpenApiOperation>) {
      return (data as List)
          .map((e) => deserialize<_i11.OpenApiOperation>(e))
          .toList() as T;
    }
    try {
      return _i12.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.Greeting) {
      return 'Greeting';
    }
    if (data is _i3.Action) {
      return 'Action';
    }
    if (data is _i4.Control) {
      return 'Control';
    }
    if (data is _i5.Event) {
      return 'Event';
    }
    if (data is _i6.NotificationTopic) {
      return 'NotificationTopic';
    }
    if (data is _i7.OpenApiOperation) {
      return 'OpenApiOperation';
    }
    if (data is _i8.OpenApiParameter) {
      return 'OpenApiParameter';
    }
    if (data is _i9.OpenApiSpec) {
      return 'OpenApiSpec';
    }
    if (data is _i10.User) {
      return 'User';
    }
    className = _i12.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i2.Greeting>(data['data']);
    }
    if (dataClassName == 'Action') {
      return deserialize<_i3.Action>(data['data']);
    }
    if (dataClassName == 'Control') {
      return deserialize<_i4.Control>(data['data']);
    }
    if (dataClassName == 'Event') {
      return deserialize<_i5.Event>(data['data']);
    }
    if (dataClassName == 'NotificationTopic') {
      return deserialize<_i6.NotificationTopic>(data['data']);
    }
    if (dataClassName == 'OpenApiOperation') {
      return deserialize<_i7.OpenApiOperation>(data['data']);
    }
    if (dataClassName == 'OpenApiParameter') {
      return deserialize<_i8.OpenApiParameter>(data['data']);
    }
    if (dataClassName == 'OpenApiSpec') {
      return deserialize<_i9.OpenApiSpec>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i10.User>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i12.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
