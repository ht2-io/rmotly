/// Parsed notification payload
class NotificationPayload {
  /// Notification title
  final String title;

  /// Notification body/message
  final String body;

  /// Optional data payload
  final Map<String, dynamic>? data;

  /// Priority level (low, normal, high, urgent)
  final String priority;

  /// Optional image URL for rich notifications
  final String? imageUrl;

  /// Optional click/action URL
  final String? actionUrl;

  /// Optional tags/categories
  final List<String>? tags;

  /// Detected source format
  final PayloadFormat sourceFormat;

  NotificationPayload({
    required this.title,
    required this.body,
    this.data,
    this.priority = 'normal',
    this.imageUrl,
    this.actionUrl,
    this.tags,
    required this.sourceFormat,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        if (data != null) 'data': data,
        'priority': priority,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (actionUrl != null) 'actionUrl': actionUrl,
        if (tags != null) 'tags': tags,
        'sourceFormat': sourceFormat.name,
      };
}

/// Known payload formats for auto-detection
enum PayloadFormat {
  /// Firebase Cloud Messaging format
  firebase,

  /// Pushover API format
  pushover,

  /// ntfy.sh format
  ntfy,

  /// Gotify format
  gotify,

  /// Home Assistant format
  homeAssistant,

  /// Generic/unknown format
  generic,
}

/// Service for parsing notification payloads from various sources.
///
/// Supports automatic format detection for:
/// - Firebase Cloud Messaging
/// - Pushover
/// - ntfy
/// - Gotify
/// - Home Assistant
/// - Generic JSON payloads
class PayloadParserService {
  /// Parse a notification payload, auto-detecting the format
  NotificationPayload parse(Map<String, dynamic> body) {
    // Try each format in order of specificity
    // Check Firebase first (most specific with 'notification' wrapper)
    if (_isFirebaseFormat(body)) {
      return _parseFirebase(body);
    }
    // Check ntfy (has 'topic' field or specific priority range with message)
    if (_isNtfyFormat(body)) {
      return _parseNtfy(body);
    }
    // Check Home Assistant before Gotify (has 'data' with specific fields)
    if (_isHomeAssistantFormat(body)) {
      return _parseHomeAssistant(body);
    }
    // Check Gotify before Pushover (has 'extras' or 'appid')
    if (_isGotifyFormat(body)) {
      return _parseGotify(body);
    }
    // Check Pushover (has limited priority range)
    if (_isPushoverFormat(body)) {
      return _parsePushover(body);
    }

    // Fall back to generic parsing
    return _parseGeneric(body);
  }

  /// Parse payload with explicit format
  NotificationPayload parseWithFormat(
    Map<String, dynamic> body,
    PayloadFormat format,
  ) {
    switch (format) {
      case PayloadFormat.firebase:
        return _parseFirebase(body);
      case PayloadFormat.pushover:
        return _parsePushover(body);
      case PayloadFormat.ntfy:
        return _parseNtfy(body);
      case PayloadFormat.gotify:
        return _parseGotify(body);
      case PayloadFormat.homeAssistant:
        return _parseHomeAssistant(body);
      case PayloadFormat.generic:
        return _parseGeneric(body);
    }
  }

  // ===== Format Detection =====

  bool _isFirebaseFormat(Map<String, dynamic> body) {
    // Firebase has a 'notification' object with 'title' and 'body'
    if (!body.containsKey('notification')) return false;
    final notification = body['notification'];
    if (notification is! Map<String, dynamic>) return false;
    // Must have at least title or body to be considered Firebase format
    return notification.containsKey('title') || notification.containsKey('body');
  }

  bool _isNtfyFormat(Map<String, dynamic> body) {
    // ntfy has 'topic' and 'message' fields
    return body.containsKey('topic') ||
        (body.containsKey('message') && body.containsKey('priority') is int);
  }

  bool _isPushoverFormat(Map<String, dynamic> body) {
    // Pushover uses 'message' (not 'body') and has numeric priority (-2 to 2)
    if (!body.containsKey('message')) return false;
    final priority = body['priority'];
    if (priority == null) return body.containsKey('user') || body.containsKey('token');
    // Check if priority is int or parseable as int in range -2 to 2
    if (priority is int) {
      return priority >= -2 && priority <= 2;
    }
    if (priority is String) {
      final parsed = int.tryParse(priority);
      return parsed != null && parsed >= -2 && parsed <= 2;
    }
    return false;
  }

  bool _isGotifyFormat(Map<String, dynamic> body) {
    // Gotify has 'message' and optionally 'extras' object
    return body.containsKey('message') &&
        (body.containsKey('extras') || body.containsKey('appid'));
  }

  bool _isHomeAssistantFormat(Map<String, dynamic> body) {
    // Home Assistant has 'message' and optional 'data' with HA-specific fields
    if (!body.containsKey('message')) return false;
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) return false;
    return data.containsKey('push') ||
        data.containsKey('actions') ||
        data.containsKey('entity_id');
  }

  // ===== Format Parsers =====

  /// Parse Firebase Cloud Messaging format
  ///
  /// Format:
  /// ```json
  /// {
  ///   "notification": {"title": "...", "body": "..."},
  ///   "data": {...},
  ///   "android": {...},
  ///   "apns": {...}
  /// }
  /// ```
  NotificationPayload _parseFirebase(Map<String, dynamic> body) {
    final notification = body['notification'] as Map<String, dynamic>? ?? {};
    final data = body['data'] as Map<String, dynamic>?;
    final android = body['android'] as Map<String, dynamic>?;

    String? imageUrl;
    if (notification.containsKey('image')) {
      imageUrl = notification['image'] as String?;
    } else if (android?['notification']?['image'] != null) {
      imageUrl = android!['notification']['image'] as String?;
    }

    return NotificationPayload(
      title: notification['title'] as String? ?? 'Notification',
      body: notification['body'] as String? ?? '',
      data: data,
      priority: _firebasePriorityToString(body['priority']),
      imageUrl: imageUrl,
      actionUrl: notification['click_action'] as String?,
      sourceFormat: PayloadFormat.firebase,
    );
  }

  /// Parse Pushover format
  ///
  /// Format:
  /// ```json
  /// {
  ///   "token": "...",
  ///   "user": "...",
  ///   "title": "...",
  ///   "message": "...",
  ///   "priority": -2 to 2,
  ///   "url": "...",
  ///   "url_title": "..."
  /// }
  /// ```
  NotificationPayload _parsePushover(Map<String, dynamic> body) {
    return NotificationPayload(
      title: body['title'] as String? ?? 'Notification',
      body: body['message'] as String? ?? '',
      data: {
        if (body['device'] != null) 'device': body['device'],
        if (body['sound'] != null) 'sound': body['sound'],
      },
      priority: _pushoverPriorityToString(body['priority']),
      actionUrl: body['url'] as String?,
      sourceFormat: PayloadFormat.pushover,
    );
  }

  /// Parse ntfy format
  ///
  /// Format:
  /// ```json
  /// {
  ///   "topic": "...",
  ///   "title": "...",
  ///   "message": "...",
  ///   "priority": 1-5,
  ///   "tags": ["tag1", "tag2"],
  ///   "click": "...",
  ///   "attach": "..."
  /// }
  /// ```
  NotificationPayload _parseNtfy(Map<String, dynamic> body) {
    List<String>? tags;
    if (body['tags'] != null) {
      if (body['tags'] is List) {
        tags = (body['tags'] as List).cast<String>();
      } else if (body['tags'] is String) {
        tags = (body['tags'] as String).split(',');
      }
    }

    return NotificationPayload(
      title: body['title'] as String? ?? 'Notification',
      body: body['message'] as String? ?? '',
      data: {
        if (body['topic'] != null) 'topic': body['topic'],
        if (body['actions'] != null) 'actions': body['actions'],
      },
      priority: _ntfyPriorityToString(body['priority']),
      imageUrl: body['attach'] as String?,
      actionUrl: body['click'] as String?,
      tags: tags,
      sourceFormat: PayloadFormat.ntfy,
    );
  }

  /// Parse Gotify format
  ///
  /// Format:
  /// ```json
  /// {
  ///   "title": "...",
  ///   "message": "...",
  ///   "priority": 1-10,
  ///   "extras": {...}
  /// }
  /// ```
  NotificationPayload _parseGotify(Map<String, dynamic> body) {
    Map<String, dynamic>? extras;
    if (body['extras'] is Map) {
      extras = Map<String, dynamic>.from(body['extras'] as Map);
    }
    
    String? imageUrl;
    String? actionUrl;

    if (extras != null) {
      // Gotify uses client::notification for display hints
      final clientNotif = extras['client::notification'];
      if (clientNotif is Map) {
        final clickData = clientNotif['click'];
        if (clickData is Map && clickData.containsKey('url')) {
          actionUrl = clickData['url'] as String?;
        }
        if (clientNotif.containsKey('bigImageUrl')) {
          imageUrl = clientNotif['bigImageUrl'] as String?;
        }
      }
    }

    return NotificationPayload(
      title: body['title'] as String? ?? 'Notification',
      body: body['message'] as String? ?? '',
      data: extras,
      priority: _gotifyPriorityToString(body['priority']),
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      sourceFormat: PayloadFormat.gotify,
    );
  }

  /// Parse Home Assistant format
  ///
  /// Format:
  /// ```json
  /// {
  ///   "message": "...",
  ///   "title": "...",
  ///   "data": {
  ///     "push": {...},
  ///     "actions": [...],
  ///     "image": "..."
  ///   }
  /// }
  /// ```
  NotificationPayload _parseHomeAssistant(Map<String, dynamic> body) {
    final data = body['data'] as Map<String, dynamic>?;

    return NotificationPayload(
      title: body['title'] as String? ?? 'Home Assistant',
      body: body['message'] as String? ?? '',
      data: data,
      priority: _homeAssistantPriorityToString(data?['push']?['priority']),
      imageUrl: data?['image'] as String?,
      actionUrl: data?['url'] as String?,
      sourceFormat: PayloadFormat.homeAssistant,
    );
  }

  /// Parse generic format
  NotificationPayload _parseGeneric(Map<String, dynamic> body) {
    // Try various common field names
    final title = body['title'] ??
        body['subject'] ??
        body['header'] ??
        'Notification';

    final message = body['body'] ??
        body['message'] ??
        body['text'] ??
        body['content'] ??
        body['description'] ??
        '';

    final data = body['data'] ??
        body['payload'] ??
        body['extras'] ??
        body['extra'];

    return NotificationPayload(
      title: title.toString(),
      body: message.toString(),
      data: data is Map<String, dynamic> ? data : null,
      priority: _genericPriorityToString(body['priority']),
      imageUrl: (body['image'] ?? body['imageUrl'] ?? body['image_url']) as String?,
      actionUrl: (body['url'] ?? body['actionUrl'] ?? body['click_url'] ?? body['link']) as String?,
      tags: body['tags'] is List ? (body['tags'] as List).cast<String>() : null,
      sourceFormat: PayloadFormat.generic,
    );
  }

  // ===== Priority Conversion =====

  String _firebasePriorityToString(dynamic priority) {
    if (priority == null) return 'normal';
    final p = priority.toString().toLowerCase();
    if (p == 'high') return 'high';
    return 'normal';
  }

  String _pushoverPriorityToString(dynamic priority) {
    if (priority == null) return 'normal';
    final p = priority is int ? priority : int.tryParse(priority.toString()) ?? 0;
    if (p <= -2) return 'low';
    if (p == -1) return 'low';
    if (p == 0) return 'normal';
    if (p == 1) return 'high';
    return 'urgent'; // 2 = emergency
  }

  String _ntfyPriorityToString(dynamic priority) {
    if (priority == null) return 'normal';
    final p = priority is int ? priority : int.tryParse(priority.toString()) ?? 3;
    if (p <= 1) return 'low';
    if (p == 2) return 'low';
    if (p == 3) return 'normal';
    if (p == 4) return 'high';
    return 'urgent'; // 5 = max
  }

  String _gotifyPriorityToString(dynamic priority) {
    if (priority == null) return 'normal';
    final p = priority is int ? priority : int.tryParse(priority.toString()) ?? 5;
    if (p <= 3) return 'low';
    if (p <= 6) return 'normal';
    if (p <= 8) return 'high';
    return 'urgent';
  }

  String _homeAssistantPriorityToString(dynamic priority) {
    if (priority == null) return 'normal';
    final p = priority.toString().toLowerCase();
    if (p == 'time-sensitive' || p == 'critical') return 'high';
    return 'normal';
  }

  String _genericPriorityToString(dynamic priority) {
    if (priority == null) return 'normal';
    final p = priority.toString().toLowerCase();
    if (p == 'low' || p == 'min' || p == '1' || p == '2') return 'low';
    if (p == 'high' || p == '4' || p == 'important') return 'high';
    if (p == 'urgent' || p == 'critical' || p == 'max' || p == '5') return 'urgent';
    return 'normal';
  }
}
