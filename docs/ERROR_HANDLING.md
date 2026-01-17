# Error Handling System

This document describes the error handling system implemented in the Rmotly app.

## Overview

The error handling system provides:

1. **Comprehensive error types** - All errors extend from `AppException`
2. **User-friendly error messages** - Automatic translation of technical errors to human-readable messages
3. **Offline support** - Automatic queueing of events when offline
4. **Automatic sync** - Queue processing when connectivity is restored

## Error Types

### Base Exception

All custom exceptions extend `AppException`:

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
}
```

### Built-in Exceptions

- **NetworkException** - Network connectivity issues
- **ValidationException** - Input validation failures
- **AuthException** - Authentication/authorization failures
- **ServerException** - Server-side errors (HTTP 5xx)
- **ActionExecutionException** - Action execution failures
- **OfflineException** - Operations attempted while offline

## Error Handler Service

The `ErrorHandlerService` centralizes error handling logic:

### Usage

```dart
final errorHandler = ErrorHandlerService();

try {
  await repository.fetchData();
} catch (error) {
  // Get user-friendly message
  final message = errorHandler.getErrorMessage(error);
  
  // Check if retryable
  if (errorHandler.isRetryable(error)) {
    // Show retry option
  }
  
  // Map to AppException
  final appException = errorHandler.mapToAppException(error);
}
```

### Features

1. **getErrorMessage(error)** - Returns user-friendly error message
2. **isRetryable(error)** - Determines if operation should be retried
3. **mapToAppException(error)** - Converts raw exceptions to typed AppExceptions

## Offline Support

### Architecture

```
┌─────────────┐
│   User      │
│  Action     │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│  Event Repository   │
│  - Check online     │
│  - Queue if offline │
└──────┬──────────────┘
       │
       ├── Online ──────► Server
       │
       └── Offline ───► OfflineQueueService
                              │
                              ▼
                        ┌────────────┐
                        │   Hive DB  │
                        └────────────┘
                              │
                              │ (When online)
                              ▼
                        ┌────────────┐
                        │SyncService │
                        └────────────┘
                              │
                              ▼
                          Process Queue
```

### Connectivity Service

Monitors network status:

```dart
final connectivityService = ref.watch(connectivityServiceProvider);

// Check current status
if (connectivityService.isOnline) {
  // Online
}

// Listen to status changes
connectivityService.statusStream.listen((status) {
  if (status == ConnectivityStatus.online) {
    // Back online
  }
});
```

### Offline Queue Service

Queues events when offline:

```dart
final queueService = OfflineQueueService();
await queueService.init();

// Queue an event
await queueService.queueEvent(
  controlId: 1,
  eventType: 'button_press',
  payload: '{"value": true}',
);

// Get queued events
final events = await queueService.getQueuedEvents();

// Remove processed event
await queueService.removeEvent(eventId);
```

### Sync Service

Automatically processes queue when online:

```dart
final syncService = ref.watch(syncServiceProvider);

// Manual sync
final processedCount = await syncService.processQueue();

// Check pending count
final pendingCount = await syncService.getPendingCount();
```

## Repository Error Handling

All repositories implement offline-first data access:

```dart
Future<List<Control>> listControls() async {
  try {
    // Try to fetch from server
    final controls = await _client.control.listControls();
    
    // Cache the controls
    await _localStorage.cacheControls(controls);
    
    return controls;
  } catch (error) {
    // If offline or error, try cache
    if (!_connectivityService.isOnline || _errorHandler.isRetryable(error)) {
      final cachedControls = await _localStorage.getCachedControls();
      if (cachedControls.isNotEmpty) {
        return cachedControls;
      }
    }
    
    // Map and throw error
    throw _errorHandler.mapToAppException(error);
  }
}
```

## UI Components

### Offline Indicator

Shows when device is offline:

```dart
// In your scaffold
Column(
  children: [
    OfflineIndicator(),
    // Your content
  ],
)
```

### Sync Status Indicator

Shows when syncing queued events:

```dart
Column(
  children: [
    SyncStatusIndicator(),
    // Your content
  ],
)
```

### Error Widget

Display errors with retry option:

```dart
AppErrorWidget(
  message: errorHandler.getErrorMessage(error),
  onRetry: () => _retry(),
)
```

## Best Practices

### 1. Always Use ErrorHandlerService

```dart
// ✅ Good
try {
  await operation();
} catch (error) {
  final message = errorHandler.getErrorMessage(error);
  showSnackBar(message);
}

// ❌ Bad
try {
  await operation();
} catch (error) {
  showSnackBar(error.toString()); // Not user-friendly
}
```

### 2. Check Retry Logic

```dart
// ✅ Good
if (errorHandler.isRetryable(error)) {
  showRetryButton();
} else {
  showErrorOnly();
}

// ❌ Bad
showRetryButton(); // Always showing retry
```

### 3. Handle Offline Gracefully

```dart
// ✅ Good
try {
  await repository.sendEvent(...);
} catch (error) {
  if (error is OfflineException) {
    showSnackBar('Event queued for when you\'re back online');
  } else {
    showSnackBar(errorHandler.getErrorMessage(error));
  }
}

// ❌ Bad
await repository.sendEvent(...); // No offline handling
```

### 4. Cache Data Appropriately

```dart
// ✅ Good - Repository handles caching
final controls = await controlRepository.listControls();

// ❌ Bad - Manual caching everywhere
final controls = await client.control.listControls();
await localStorage.cacheControls(controls);
```

## Testing

### Error Handler Tests

```dart
test('maps SocketException to NetworkException', () {
  final exception = SocketException('Connection refused');
  final mapped = errorHandler.mapToAppException(exception);
  expect(mapped, isA<NetworkException>());
});
```

### Offline Queue Tests

```dart
test('queues event when offline', () async {
  final eventId = await queueService.queueEvent(
    controlId: 1,
    eventType: 'button_press',
  );
  
  final count = await queueService.getQueuedCount();
  expect(count, 1);
});
```

## Future Enhancements

1. **Localization** - Add i18n support for error messages
2. **Analytics** - Track error frequency and types
3. **Advanced Retry** - Exponential backoff for retries
4. **Partial Sync** - Batch processing for large queues
5. **Conflict Resolution** - Handle data conflicts during sync
