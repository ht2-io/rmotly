import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../endpoints/webhook_endpoint.dart';

/// Route handler for webhook endpoint
/// 
/// Handles POST /api/notify/:topicId
class WebhookRoute extends Route {
  final Serverpod pod;
  late final WebhookHandler _handler;

  WebhookRoute(this.pod) {
    _handler = WebhookHandler(pod);
  }

  @override
  Future<void> handleRequest(HttpRequest request) async {
    // Extract topic ID from path
    final uri = request.uri;
    final pathSegments = uri.pathSegments;
    
    // Path should be: api/notify/:topicId
    if (pathSegments.length != 3 || 
        pathSegments[0] != 'api' || 
        pathSegments[1] != 'notify') {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Not found');
      await request.response.close();
      return;
    }
    
    final topicId = pathSegments[2];
    await _handler.handleRequest(request, topicId);
  }
}
