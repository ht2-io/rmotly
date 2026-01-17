import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../endpoints/sse_endpoint.dart';

/// Route handler for SSE endpoint
///
/// Handles GET /api/sse/notifications
class SseRoute extends Route {
  final Serverpod pod;
  late final SseHandler _handler;

  SseRoute(this.pod) {
    _handler = SseHandler(pod);
  }

  @override
  Future<bool> handleCall(Session session, HttpRequest request) async {
    await _handler.handleRequest(request);
    return true;
  }
}
