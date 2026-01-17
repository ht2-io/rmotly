# End-to-End Integration Tests

This directory contains comprehensive end-to-end integration tests for the Rmotly system.

## Test Files

### 1. `control_action_flow_test.dart` (Task 5.3.1)
Tests the complete control → action execution flow:
- Creating HTTP actions with templates
- Linking controls to actions
- Triggering controls via events
- Verifying action execution results
- Template variable substitution
- Error handling

**Test Count**: 6 comprehensive test cases

### 2. `webhook_notification_flow_test.dart` (Task 5.3.2)
Tests the webhook → notification delivery flow:
- Creating notification topics with API keys
- Topic CRUD operations
- API key management and regeneration
- Webhook URL generation
- Notification delivery
- Multi-user isolation

**Test Count**: 17 comprehensive test cases

### 3. `openapi_import_flow_test.dart` (Task 5.3.3)
Tests the OpenAPI import → action execution flow:
- Parsing OpenAPI specifications
- Listing available operations
- Importing operations as actions
- Testing actions with various HTTP methods (GET, POST, PUT, DELETE)
- Path and query parameter handling
- Authentication header support

**Test Count**: 12 comprehensive test cases

## Running Tests

### Prerequisites

1. **PostgreSQL 17** - Database service
2. **Redis 8** - Cache service (optional for most tests)
3. **Dart SDK 3.6.2+**

### Local Development

#### Option 1: Docker Compose (Recommended)

```bash
# From project root
cd rmotly_server
docker-compose -f ../docker-compose.yaml up -d postgres redis

# Wait for services to be ready
sleep 5

# Run tests
dart test
```

#### Option 2: Manual Setup

1. Start PostgreSQL and Redis:
```bash
# PostgreSQL
docker run -d \
  --name rmotly-test-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=rmotly_test \
  -p 5432:5432 \
  postgres:17

# Redis (optional)
docker run -d \
  --name rmotly-test-redis \
  -p 6379:6379 \
  redis:8
```

2. Create `config/passwords.yaml`:
```yaml
test:
  database: 'postgres'
```

3. Run tests:
```bash
cd rmotly_server
dart test
```

### Run Specific Test Files

```bash
# Control → Action flow only
dart test test/integration/control_action_flow_test.dart

# Webhook → Notification flow only
dart test test/integration/webhook_notification_flow_test.dart

# OpenAPI import flow only
dart test test/integration/openapi_import_flow_test.dart
```

### Run Only Integration Tests

```bash
# Run all integration tests (excluding unit tests)
dart test -t integration
```

### Continuous Integration (CI)

Tests run automatically in GitHub Actions on every push and pull request. The CI environment:
- Uses Docker services for PostgreSQL and Redis
- Runs all tests including integration tests
- Reports coverage and test results

See `.github/workflows/ci.yml` for the complete CI configuration.

## Test Framework

These tests use:
- **serverpod_test** - Serverpod's built-in testing framework
- **withServerpod** - Helper that provides test database transaction rollback
- **TestSessionBuilder** - Creates test sessions with authentication

### Test Structure

```dart
withServerpod('Test Group Name', (sessionBuilder, endpoints) {
  group('Feature tests', () {
    test('specific behavior', () async {
      // Arrange
      final session = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(1, {}),
      );
      
      // Act
      final result = await endpoints.something.doSomething(session, ...);
      
      // Assert
      expect(result, ...);
    });
  });
});
```

## Key Features

### Automatic Database Rollback
All tests run in transactions that are automatically rolled back after each test, ensuring:
- No test pollution
- Parallel test execution capability
- Fast test runs

### Authentication Testing
Tests can simulate authenticated users:
```dart
final authenticatedSession = sessionBuilder.copyWith(
  authentication: AuthenticationOverride.authenticationInfo(userId, {}),
);
```

### External Service Testing
Tests that depend on external services (e.g., httpbin.org for HTTP testing) gracefully handle failures:
- Tests skip gracefully if external services are unavailable
- Uses reliable public test APIs
- Comments indicate which tests require network access

## Test Coverage

Total end-to-end integration tests: **35 test cases**

Coverage areas:
- ✅ Action creation and execution
- ✅ Control management and triggering
- ✅ Event logging and retrieval
- ✅ Notification topic management
- ✅ API key generation and authentication
- ✅ Webhook URL generation
- ✅ OpenAPI spec parsing
- ✅ HTTP method support (GET, POST, PUT, DELETE, PATCH)
- ✅ Template variable substitution
- ✅ Path and query parameter handling
- ✅ Authentication header support
- ✅ Error handling and edge cases
- ✅ Multi-user isolation

## Troubleshooting

### "Missing database password"
Create `config/passwords.yaml` with test database password:
```yaml
test:
  database: 'postgres'
```

### "Connection refused" or "Database not found"
Ensure PostgreSQL is running and accessible:
```bash
pg_isready -h localhost -p 5432
psql -h localhost -U postgres -d rmotly_test -c "SELECT 1"
```

### Tests timing out
Some tests make real HTTP requests to external services (httpbin.org, OpenAPI specs). These may timeout if:
- Network is restricted
- External service is down
- Firewall blocks outbound connections

These tests are designed to skip gracefully in such cases.

### Port conflicts
Default ports:
- PostgreSQL: 5432
- Redis: 6379

If these ports are in use, either:
1. Stop conflicting services
2. Update `config/test.yaml` to use different ports
3. Use Docker with port mapping

## Contributing

When adding new integration tests:

1. **Follow the AAA pattern**: Arrange, Act, Assert
2. **Use descriptive test names**: Describe the expected behavior
3. **Include error cases**: Test both success and failure paths
4. **Clean up resources**: Tests should be idempotent
5. **Add documentation**: Update this README with new test coverage

## References

- [Serverpod Testing Guide](https://docs.serverpod.dev/concepts/testing)
- [TASKS.md](../../../TASKS.md) - Project task tracking
- [TESTING.md](../../../docs/TESTING.md) - General testing guidelines
- [CI/CD Workflows](../../../.github/workflows/ci.yml)
