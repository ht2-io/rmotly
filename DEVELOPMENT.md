# Rmotly - Development Setup Guide

Welcome to the Rmotly development environment setup guide! This document provides step-by-step instructions to get you up and running with local development.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Running Locally](#running-locally)
- [Running Tests](#running-tests)
- [Code Generation](#code-generation)
- [Debugging](#debugging)
- [IDE Setup](#ide-setup)
- [Common Workflows](#common-workflows)
- [Performance & Optimization](#performance--optimization)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have the following tools installed:

### Required Tools

| Tool | Minimum Version | Recommended | Installation |
|------|-----------------|-------------|--------------|
| **Dart SDK** | 3.5.0+ | 3.6.2+ | [dart.dev/get-dart](https://dart.dev/get-dart) |
| **Flutter SDK** | 3.24.0+ | 3.27.4+ | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| **Serverpod CLI** | 2.9.2+ | 2.9.2+ | `dart pub global activate serverpod_cli` |
| **PostgreSQL** | 14+ | 17+ | [postgresql.org/download](https://www.postgresql.org/download/) |
| **Redis** | 7+ | 8+ | [redis.io/download](https://redis.io/download) |
| **Docker** | 20.10+ | Latest | [docker.com/get-started](https://www.docker.com/get-started) |
| **Docker Compose** | 2.0+ | Latest | Included with Docker Desktop |
| **Git** | 2.30+ | Latest | [git-scm.com/downloads](https://git-scm.com/downloads) |

### Version Verification

Check your installed versions:

```bash
# Dart & Flutter
dart --version
flutter --version

# Serverpod CLI
serverpod --version

# PostgreSQL
psql --version

# Redis
redis-cli --version

# Docker
docker --version
docker compose version

# Git
git --version
```

**Expected Output (Example):**
```
Dart SDK version: 3.6.2
Flutter 3.27.4
Serverpod version: 2.9.2
psql (PostgreSQL) 17.0
redis-cli 8.0.0
Docker version 24.0.7
Docker Compose version v2.23.0
git version 2.43.0
```

### Optional (but Recommended)

#### IDE Options

**VS Code** (Recommended for Dart/Flutter)
- Download: [code.visualstudio.com](https://code.visualstudio.com/)
- Lightweight and fast
- Excellent Flutter/Dart support

**Android Studio** (Best for Android development)
- Download: [developer.android.com/studio](https://developer.android.com/studio)
- Full Android tooling
- Built-in emulator

#### Additional Tools

- **PostgreSQL GUI**: [pgAdmin](https://www.pgadmin.org/), [DBeaver](https://dbeaver.io/), or [TablePlus](https://tableplus.com/)
- **Redis GUI**: [RedisInsight](https://redis.com/redis-enterprise/redis-insight/)
- **API Testing**: [Postman](https://www.postman.com/) or [Insomnia](https://insomnia.rest/)
- **GitHub CLI**: `gh` for easier PR management ([cli.github.com](https://cli.github.com/))

---

## Initial Setup

Follow these steps to set up your development environment from scratch.

### 1. Clone the Repository

```bash
# Clone via HTTPS
git clone https://github.com/yourusername/rmotly.git
cd rmotly

# Or via SSH (recommended if you have SSH keys set up)
git clone git@github.com:yourusername/rmotly.git
cd rmotly
```

**Expected Output:**
```
Cloning into 'rmotly'...
remote: Enumerating objects: 1234, done.
remote: Counting objects: 100% (1234/1234), done.
remote: Compressing objects: 100% (567/567), done.
Receiving objects: 100% (1234/1234), 2.34 MiB | 5.67 MiB/s, done.
Resolving deltas: 100% (890/890), done.
```

### 2. Install Server Dependencies

```bash
cd rmotly_server
dart pub get
```

**Expected Output:**
```
Resolving dependencies... 
+ serverpod 2.9.2
+ serverpod_auth_server 2.9.2
+ encrypt 5.0.3
+ http 1.2.2
...
Changed 45 dependencies!
```

### 3. Install App Dependencies

```bash
cd ../rmotly_app
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in rmotly_app...
Resolving dependencies...
+ serverpod_flutter 2.9.2
+ serverpod_auth_client 2.9.2
+ flutter_riverpod 2.5.1
...
Changed 78 dependencies!
```

### 4. Start Docker Services

The easiest way to run PostgreSQL, Redis, and ntfy is using Docker Compose:

```bash
cd ../rmotly_server
docker compose up -d
```

**Expected Output:**
```
[+] Running 4/4
 ✔ Network rmotly_server_default     Created
 ✔ Container rmotly-postgres          Started
 ✔ Container rmotly-redis             Started
 ✔ Container rmotly-ntfy              Started
```

**Verify Services Are Running:**
```bash
docker compose ps
```

**Expected Output:**
```
NAME                IMAGE                      STATUS         PORTS
rmotly-postgres     pgvector/pgvector:pg16     Up (healthy)   0.0.0.0:8090->5432/tcp
rmotly-redis        redis:8-alpine             Up (healthy)   0.0.0.0:8091->6379/tcp
rmotly-ntfy         binwiederhier/ntfy         Up (healthy)   0.0.0.0:8093->80/tcp
```

**Service Endpoints:**
- PostgreSQL: `localhost:8090`
- Redis: `localhost:8091`
- ntfy: `http://localhost:8093`

### 5. Configure Environment Variables

Create a passwords file for the server:

```bash
cd rmotly_server
cat > config/passwords.yaml << 'EOF'
# Development passwords (DO NOT commit to git)
development:
  database: 'rmotly_dev_pass'
  redis: 'rmotly_redis_pass'
  
# Test passwords
test:
  database: 'postgres'
  redis: ''  # No password for test Redis
EOF
```

**Note:** The `config/passwords.yaml` file is already in `.gitignore` to prevent accidentally committing secrets.

**Optional Environment Variables:**

If you prefer using environment variables instead of the YAML file, create a `.env` file:

```bash
# Optional: Create .env file (alternative to passwords.yaml)
cat > .env << 'EOF'
# Database
DATABASE_HOST=localhost
DATABASE_PORT=8090
DATABASE_NAME=rmotly
DATABASE_USER=postgres
DATABASE_PASSWORD=rmotly_dev_pass

# Redis
REDIS_HOST=localhost
REDIS_PORT=8091
REDIS_PASSWORD=rmotly_redis_pass

# ntfy
NTFY_BASE_URL=http://localhost:8093

# Development mode
RUNMODE=development
EOF
```

### 6. Run Database Migrations

Initialize the database schema:

```bash
cd rmotly_server
serverpod create-migration
```

**Expected Output:**
```
Creating migration...
✓ Migration created: migrations/20240115_initial_schema.sql
```

Apply the migration:

```bash
serverpod apply-migrations --mode=development
```

**Expected Output:**
```
Applying migrations to development database...
✓ Applied migration: 20240115_initial_schema.sql
Database is up to date.
```

### 7. Generate Serverpod Code

Generate the server protocol and client code:

```bash
cd rmotly_server
serverpod generate
```

**Expected Output:**
```
Generating Serverpod code...
✓ Generated protocol code
✓ Generated client code
✓ Generated model classes
✓ Generated endpoint methods
Code generation complete.
```

This command generates:
- Server protocol files in `rmotly_server/lib/src/generated/`
- Client library in `rmotly_client/lib/src/protocol/`
- Endpoint stubs if needed

### 8. Verify the Setup

Check that everything is configured correctly:

```bash
# Check database connection
psql -h localhost -p 8090 -U postgres -d rmotly -c "\dt"
# Enter password when prompted: rmotly_dev_pass
```

**Expected Output:**
```
             List of relations
 Schema |        Name        | Type  |  Owner   
--------+--------------------+-------+----------
 public | actions            | table | postgres
 public | controls           | table | postgres
 public | events             | table | postgres
 public | notification_topics| table | postgres
...
```

Check Redis connection:

```bash
redis-cli -h localhost -p 8091 -a rmotly_redis_pass ping
```

**Expected Output:**
```
PONG
```

Check ntfy:

```bash
curl http://localhost:8093/v1/health
```

**Expected Output:**
```json
{"healthy":true}
```

---

## Running Locally

Now that everything is set up, let's run the application!

### Starting the Server

#### Option 1: Direct Dart Execution (Development)

```bash
cd rmotly_server
dart run bin/main.dart
```

**Expected Output:**
```
Serverpod server starting...
API server listening on http://localhost:8080
Insights server listening on http://localhost:8081
Web server listening on http://localhost:8082
Server ready.
```

#### Option 2: Using Serverpod CLI (with hot reload)

```bash
cd rmotly_server
serverpod run
```

This provides hot reload capabilities for faster development.

**Expected Output:**
```
Starting Serverpod server with hot reload...
Watching for file changes...
Server ready on http://localhost:8080
```

#### Option 3: Docker Container (Production-like)

```bash
cd rmotly_server
docker compose up server
```

This runs the server in a container, similar to production.

### Running the Flutter App

#### On an Emulator/Simulator

First, start an emulator:

```bash
# List available emulators
flutter emulators

# Launch an Android emulator
flutter emulators --launch <emulator_id>

# Or launch iOS simulator (macOS only)
open -a Simulator
```

Then run the app:

```bash
cd rmotly_app
flutter run
```

**Expected Output:**
```
Launching lib/main.dart on Android SDK built for x86 in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk.
Installing build/app/outputs/flutter-apk/app.apk...
Syncing files to device Android SDK built for x86...

Flutter run key commands.
r Hot reload. 🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

💪 Running with sound null safety 💪

An Observatory debugger and profiler on Android SDK built for x86 is available at: http://127.0.0.1:12345/
The Flutter DevTools debugger and profiler on Android SDK built for x86 is available at: http://127.0.0.1:9100?uri=http://127.0.0.1:12345/
```

#### On a Physical Device

Connect your device via USB and enable USB debugging (Android) or trust the computer (iOS):

```bash
# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

#### With Specific Configuration

```bash
# Debug mode (default)
flutter run

# Profile mode (performance testing)
flutter run --profile

# Release mode (optimized)
flutter run --release

# Specific target file
flutter run -t lib/main_staging.dart
```

### Accessing Services

Once everything is running, you can access:

| Service | URL | Description |
|---------|-----|-------------|
| **API Server** | http://localhost:8080 | Main Serverpod API |
| **Insights** | http://localhost:8081 | Serverpod monitoring dashboard |
| **Web Server** | http://localhost:8082 | Serverpod web interface |
| **PostgreSQL** | localhost:8090 | Database (use GUI client) |
| **Redis** | localhost:8091 | Cache (use redis-cli or GUI) |
| **ntfy** | http://localhost:8093 | Push notification server |

### Quick Health Check

Verify the server is responding:

```bash
# Check API health
curl http://localhost:8080/

# Check Serverpod info
curl http://localhost:8080/serverpod
```

**Expected Output:**
```json
{
  "serverpod": "2.9.2",
  "environment": "development"
}
```

### Stopping Services

When you're done developing:

```bash
# Stop the Flutter app
# Press 'q' in the terminal where flutter run is running

# Stop the Dart server
# Press Ctrl+C in the terminal where the server is running

# Stop Docker services
cd rmotly_server
docker compose down
```

**Keep Docker Running:**

If you want to keep Docker services running between sessions (recommended for active development):

```bash
# Docker services will continue running
# Just stop the Dart server and Flutter app
```

---

## Running Tests

Rmotly follows TDD (Test-Driven Development) practices. Run tests frequently to ensure code quality.

### Server Tests

#### Run All Server Tests

```bash
cd rmotly_server
dart test
```

**Expected Output:**
```
00:01 +0: loading /Users/dev/rmotly/rmotly_server/test/action_executor_test.dart
00:02 +1: ActionExecutor executes HTTP GET request successfully
00:02 +2: ActionExecutor handles template variables correctly
...
00:15 +47: All tests passed!
```

#### Run Specific Test File

```bash
dart test test/action_executor_test.dart
```

#### Run Tests by Name Pattern

```bash
# Run all tests matching "ActionExecutor"
dart test --name "ActionExecutor"

# Run all tests matching "notification"
dart test --name "notification"
```

#### Run Tests with Coverage

```bash
dart test --coverage=coverage

# Generate HTML coverage report
dart pub global activate coverage
format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

# View coverage (requires lcov tools)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
# Or: xdg-open coverage/html/index.html  # Linux
```

**Coverage Target:** Aim for 80%+ coverage on business logic.

### App Tests

#### Run All App Tests

```bash
cd rmotly_app
flutter test
```

**Expected Output:**
```
00:01 +0: loading /Users/dev/rmotly/rmotly_app/test/unit/template_parser_test.dart
00:02 +1: TemplateParser parses simple variable
00:02 +2: TemplateParser handles nested objects
...
00:25 +89: All tests passed!
```

#### Run Specific Test File

```bash
flutter test test/unit/features/dashboard/dashboard_viewmodel_test.dart
```

#### Run Widget Tests Only

```bash
flutter test test/widget/
```

#### Run Unit Tests Only

```bash
flutter test test/unit/
```

#### Run Integration Tests

```bash
# Integration tests require a running server
cd rmotly_server
dart run bin/main.dart &
SERVER_PID=$!

cd ../rmotly_app
flutter test integration_test/

# Clean up
kill $SERVER_PID
```

#### Run Tests with Coverage

```bash
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

#### Update Golden Files

Golden tests verify UI appearance. Update them when you intentionally change UI:

```bash
flutter test --update-goldens
```

### Continuous Test Running

#### Watch Mode (Server)

```bash
# Install nodemon or similar file watcher
npm install -g nodemon

# Watch and run tests on file changes
cd rmotly_server
nodemon --exec "dart test" --watch lib --watch test --ext dart
```

#### Watch Mode (App)

Use VS Code's test explorer or:

```bash
# Watch and run tests
cd rmotly_app
flutter test --watch
```

### Test Types Summary

| Test Type | Location | Command | When to Run |
|-----------|----------|---------|-------------|
| **Server Unit** | `rmotly_server/test/` | `dart test` | After every change |
| **App Unit** | `rmotly_app/test/unit/` | `flutter test test/unit/` | After every change |
| **Widget Tests** | `rmotly_app/test/widget/` | `flutter test test/widget/` | After UI changes |
| **Integration** | `rmotly_app/integration_test/` | `flutter test integration_test/` | Before commits |
| **Golden Tests** | `rmotly_app/test/golden/` | `flutter test test/golden/` | After UI changes |

### Coverage Reports

View detailed coverage information:

```bash
# Server coverage
cd rmotly_server
dart test --coverage=coverage
dart pub global run coverage:format_coverage \
  --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

# App coverage
cd rmotly_app
flutter test --coverage

# Open in browser (both)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Coverage Targets:**
- Overall: 80%+
- Business Logic: 90%+
- UI Code: 60%+ (widget tests)
- Utilities: 95%+

---

## Code Generation

Serverpod uses code generation for models, endpoints, and client libraries. Regenerate code when you make changes to protocol definitions.

### When to Regenerate

Run `serverpod generate` when you:

- Add or modify model definitions in `lib/src/models/*.yaml`
- Add or modify endpoint classes
- Change protocol classes
- Add new database tables

### Generate Server Code

```bash
cd rmotly_server
serverpod generate
```

**Expected Output:**
```
Generating Serverpod code...
✓ Analyzing protocol
✓ Generating models
✓ Generating endpoints
✓ Generating database code
✓ Generating client library
Code generation complete in 3.2s.
```

**Generated Files:**
- `lib/src/generated/` - Server-side protocol
- `../rmotly_client/lib/src/protocol/` - Client library
- `lib/src/generated/endpoints.dart` - Endpoint registry

### Creating Database Migrations

After modifying models:

```bash
cd rmotly_server

# Create a new migration
serverpod create-migration

# Migrations are created in migrations/ directory
# Example: migrations/20240115_add_user_preferences.sql
```

**Review the Migration:**

Always review generated migrations before applying:

```bash
cat migrations/20240115_add_user_preferences.sql
```

**Expected Content:**
```sql
--
-- Migration created: 2024-01-15 10:30:45
--

BEGIN;

ALTER TABLE users ADD COLUMN preferences JSONB;
CREATE INDEX idx_user_preferences ON users USING gin(preferences);

COMMIT;
```

### Applying Migrations

#### Development Database

```bash
serverpod apply-migrations --mode=development
```

#### Test Database

```bash
serverpod apply-migrations --mode=test
```

#### Production Database (careful!)

```bash
serverpod apply-migrations --mode=production
```

**Expected Output:**
```
Applying migrations to development database...
Pending migrations:
  - 20240115_add_user_preferences.sql

Apply migrations? [y/N]: y
✓ Applied migration: 20240115_add_user_preferences.sql
Database is up to date.
```

### Rolling Back Migrations

If you need to undo a migration:

```bash
# Manually create a rollback migration
serverpod create-migration --name rollback_user_preferences

# Edit the migration file to reverse changes
nano migrations/20240115_rollback_user_preferences.sql
```

**Example Rollback:**
```sql
BEGIN;

ALTER TABLE users DROP COLUMN preferences;
DROP INDEX idx_user_preferences;

COMMIT;
```

Then apply:

```bash
serverpod apply-migrations --mode=development
```

### Force Regeneration

If generation fails or produces errors:

```bash
# Clean generated files
rm -rf lib/src/generated/
rm -rf ../rmotly_client/lib/src/protocol/

# Regenerate
serverpod generate
```

### Client Code Updates

After generating server code, the client library is automatically updated. Make sure to run `flutter pub get` in the app:

```bash
cd rmotly_app
flutter pub get
```

---

## Debugging

Effective debugging speeds up development and helps catch issues early.

### VS Code Debugging

#### Server Debugging

Create `.vscode/launch.json` in `rmotly_server/`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch Serverpod Server",
      "request": "launch",
      "type": "dart",
      "program": "bin/main.dart",
      "cwd": "${workspaceFolder}/rmotly_server",
      "args": [],
      "console": "terminal"
    },
    {
      "name": "Attach to Serverpod Server",
      "request": "attach",
      "type": "dart",
      "vmServiceUri": "http://127.0.0.1:8181/"
    }
  ]
}
```

**Debug Steps:**
1. Open `rmotly_server/` in VS Code
2. Set breakpoints in your code (click left of line numbers)
3. Press F5 or click "Run and Debug"
4. Select "Launch Serverpod Server"

#### App Debugging

Create `.vscode/launch.json` in `rmotly_app/`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch Flutter App",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "cwd": "${workspaceFolder}/rmotly_app",
      "args": [
        "--dart-define=API_URL=http://localhost:8080"
      ]
    },
    {
      "name": "Launch Flutter App (Profile)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "cwd": "${workspaceFolder}/rmotly_app",
      "flutterMode": "profile"
    }
  ]
}
```

**Debug Steps:**
1. Start the server first
2. Open `rmotly_app/` in VS Code
3. Set breakpoints in Dart code
4. Press F5 or click "Run and Debug"
5. Select "Launch Flutter App"

### Flutter DevTools

DevTools provides powerful debugging and profiling capabilities.

#### Launch DevTools

```bash
cd rmotly_app
flutter run

# DevTools URL will be printed:
# http://127.0.0.1:9100?uri=http://127.0.0.1:12345/
```

Open the URL in your browser to access:

- **Inspector** - Widget tree visualization
- **Timeline** - Performance profiling
- **Memory** - Memory usage and leaks
- **Network** - HTTP request monitoring
- **Logging** - Console logs
- **Debugger** - Source-level debugging

#### Widget Inspector

Helps debug UI layout issues:

1. In DevTools, click "Inspector" tab
2. Click "Select Widget Mode" (crosshair icon)
3. Tap any widget in the app
4. View widget properties, render tree, and layout constraints

#### Performance Timeline

Profile rendering performance:

1. Click "Performance" tab in DevTools
2. Click "Record" button
3. Interact with your app
4. Click "Stop" button
5. Analyze frame rendering times (aim for <16ms per frame)

### Database Inspection

#### Using psql

```bash
# Connect to database
psql -h localhost -p 8090 -U postgres -d rmotly

# List tables
\dt

# Describe table schema
\d controls

# Query data
SELECT * FROM controls;

# Exit
\q
```

#### Using pgAdmin or DBeaver

Configure connection:
- **Host:** localhost
- **Port:** 8090
- **Database:** rmotly
- **User:** postgres
- **Password:** rmotly_dev_pass

### Redis CLI Usage

#### Connect and Inspect

```bash
# Connect to Redis
redis-cli -h localhost -p 8091 -a rmotly_redis_pass

# List all keys
KEYS *

# Get value
GET key_name

# Get hash
HGETALL user:session:abc123

# Monitor all commands (useful for debugging)
MONITOR

# Exit
exit
```

#### Flush Cache (Development Only)

```bash
redis-cli -h localhost -p 8091 -a rmotly_redis_pass FLUSHDB
```

### Log Viewing

#### Server Logs

```bash
# View server logs in real-time
cd rmotly_server
dart run bin/main.dart | tee server.log

# Or with Docker
docker compose logs -f server
```

**Increase Log Verbosity:**

Edit `config/development.yaml`:

```yaml
logging:
  level: ALL  # Change from normal to ALL for debug logs
```

#### App Logs

```bash
# View Flutter logs in real-time
flutter run --verbose

# Or filter logs
flutter run | grep 'MyFeature'
```

**Add Logging in Code:**

```dart
import 'dart:developer' as developer;

developer.log('Control tapped', name: 'rmotly.controls');
print('Debug: Value = $value');  // Simpler alternative
```

### Breakpoint Debugging

#### In Server Code

```dart
// lib/src/endpoints/event_endpoint.dart
Future<EventResponse> sendEvent(Session session, String controlId) async {
  // Set breakpoint on next line
  final control = await Control.db.findById(session, controlId);
  
  // Breakpoint here to inspect control
  if (control == null) {
    throw Exception('Control not found');
  }
  
  // ... rest of code
}
```

#### In App Code

```dart
// lib/features/dashboard/dashboard_viewmodel.dart
Future<void> onControlTapped(Control control) async {
  // Set breakpoint here
  print('Control tapped: ${control.name}');
  
  // Breakpoint to inspect state
  final result = await _repository.sendEvent(control.id);
  
  // ... rest of code
}
```

### Network Debugging

#### Inspect HTTP Requests

Use DevTools Network tab or add logging:

```dart
// Add HTTP interceptor for debugging
import 'package:http/http.dart' as http;

class LoggingClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('➡️ ${request.method} ${request.url}');
    print('Headers: ${request.headers}');
    
    final response = await _inner.send(request);
    
    print('⬅️ ${response.statusCode} ${request.url}');
    return response;
  }
}
```

#### Proxy Through Charles or Proxyman

To inspect HTTPS traffic:

```bash
# Run with proxy
flutter run --dart-define=HTTP_PROXY=http://localhost:8888
```

Configure Charles/Proxyman to listen on port 8888.

---

## IDE Setup

Configure your IDE for maximum productivity.

### VS Code Setup

#### Recommended Extensions

Install these extensions:

```bash
# Install via command palette (Cmd/Ctrl+P)
ext install Dart-Code.dart-code
ext install Dart-Code.flutter
ext install serverpod.serverpod
ext install GitHub.copilot  # Optional, paid
ext install usernamehw.errorlens
ext install streetsidesoftware.code-spell-checker
```

**Extension List:**
- **Dart** - Dart language support
- **Flutter** - Flutter development tools
- **Serverpod** - Serverpod specific tooling
- **Error Lens** - Inline error messages
- **Code Spell Checker** - Catch typos
- **GitLens** (optional) - Enhanced Git integration
- **GitHub Copilot** (optional) - AI pair programming

#### Workspace Settings

Create `.vscode/settings.json` at repository root:

```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 100,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "dart.previewLsp": true,
  "dart.debugExternalPackageLibraries": false,
  "dart.debugSdkLibraries": false,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.rulers": [100],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  },
  "files.exclude": {
    "**/.dart_tool": true,
    "**/.flutter-plugins": true,
    "**/.flutter-plugins-dependencies": true
  },
  "search.exclude": {
    "**/build": true,
    "**/.dart_tool": true,
    "**/.git": true
  }
}
```

#### Keyboard Shortcuts

Add to `.vscode/keybindings.json`:

```json
[
  {
    "key": "cmd+r",
    "command": "flutter.hotReload",
    "when": "dart-code:flutterProjectLoaded"
  },
  {
    "key": "cmd+shift+r",
    "command": "flutter.hotRestart",
    "when": "dart-code:flutterProjectLoaded"
  },
  {
    "key": "cmd+shift+t",
    "command": "dart.runAllTestsWithoutDebugging"
  }
]
```

#### Snippets

Create `.vscode/dart.code-snippets`:

```json
{
  "Riverpod Provider": {
    "prefix": "provider",
    "body": [
      "final ${1:name}Provider = Provider<${2:Type}>((ref) {",
      "  return ${3:implementation};",
      "});"
    ]
  },
  "Riverpod StateNotifier": {
    "prefix": "statenotifier",
    "body": [
      "class ${1:Name}Notifier extends StateNotifier<${2:State}> {",
      "  ${1:Name}Notifier() : super(${3:initialState});",
      "",
      "  $0",
      "}",
      "",
      "final ${4:name}Provider = StateNotifierProvider<${1:Name}Notifier, ${2:State}>((ref) {",
      "  return ${1:Name}Notifier();",
      "});"
    ]
  },
  "Test Group": {
    "prefix": "testgroup",
    "body": [
      "group('${1:GroupName}', () {",
      "  test('${2:description}', () {",
      "    // Arrange",
      "    $0",
      "",
      "    // Act",
      "",
      "",
      "    // Assert",
      "  });",
      "});"
    ]
  }
}
```

### Android Studio Setup

#### Plugins

1. Open Android Studio
2. Go to **Preferences → Plugins**
3. Search and install:
   - **Flutter**
   - **Dart**
   - **Serverpod**
   - **.env files support**

#### Code Style

1. Go to **Preferences → Editor → Code Style → Dart**
2. Set line length to **100**
3. Enable **Format on save**

#### Run Configurations

Create run configurations for easy debugging:

1. **Run → Edit Configurations**
2. Click **+** → **Dart**
3. Configure:
   - **Name:** Serverpod Server
   - **Dart file:** `rmotly_server/bin/main.dart`
   - **Working directory:** `rmotly_server/`

Repeat for Flutter app.

---

## Common Workflows

Practical workflows for common development tasks.

### Adding a New Feature

Follow this TDD workflow:

#### 1. Create Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feat/new-feature
```

#### 2. Write Tests First

```bash
# Create test file
touch rmotly_app/test/unit/features/new_feature/new_feature_test.dart
```

Write failing tests:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewFeature', () {
    test('performs expected behavior', () {
      // Arrange
      final feature = NewFeature();
      
      // Act
      final result = feature.doSomething();
      
      // Assert
      expect(result, expectedValue);
    });
  });
}
```

Run tests (they should fail):

```bash
flutter test test/unit/features/new_feature/
```

#### 3. Implement Feature

Write minimal code to pass tests:

```dart
// lib/features/new_feature/new_feature.dart
class NewFeature {
  String doSomething() {
    return expectedValue;
  }
}
```

#### 4. Run Tests (should pass now)

```bash
flutter test test/unit/features/new_feature/
```

#### 5. Refactor

Clean up code while keeping tests green.

#### 6. Commit

```bash
git add .
git commit -m "feat(feature): add new feature

- Add NewFeature class
- Implement doSomething method
- Add unit tests

Closes #123"
```

### Adding a New Model

#### 1. Define Model (YAML)

Create `rmotly_server/lib/src/models/my_model.yaml`:

```yaml
class: MyModel
table: my_models
fields:
  name: String
  description: String?
  createdAt: DateTime
  userId: String
indexes:
  my_model_user_idx:
    fields: userId
    type: btree
```

#### 2. Generate Code

```bash
cd rmotly_server
serverpod generate
```

#### 3. Create Migration

```bash
serverpod create-migration
```

#### 4. Review and Apply Migration

```bash
cat migrations/20240115_add_my_model.sql
serverpod apply-migrations --mode=development
```

#### 5. Use in Endpoint

```dart
// lib/src/endpoints/my_model_endpoint.dart
class MyModelEndpoint extends Endpoint {
  Future<MyModel> createMyModel(Session session, MyModel model) async {
    return await MyModel.db.insertRow(session, model);
  }
  
  Future<List<MyModel>> listMyModels(Session session) async {
    return await MyModel.db.find(session);
  }
}
```

#### 6. Update Client

```bash
cd rmotly_app
flutter pub get
```

#### 7. Use in App

```dart
final myModel = MyModel(
  name: 'Example',
  description: 'Description',
  createdAt: DateTime.now(),
  userId: 'user_123',
);

final created = await client.myModel.createMyModel(myModel);
```

### Adding a New Endpoint

#### 1. Create Endpoint Class

```bash
touch rmotly_server/lib/src/endpoints/my_endpoint.dart
```

```dart
import 'package:serverpod/serverpod.dart';

class MyEndpoint extends Endpoint {
  Future<String> myMethod(Session session, String input) async {
    return 'Processed: $input';
  }
}
```

#### 2. Generate Code

```bash
cd rmotly_server
serverpod generate
```

#### 3. Test Endpoint

Create `test/my_endpoint_test.dart`:

```dart
import 'package:rmotly_server/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('MyEndpoint', (sessionBuilder, endpoints) {
    test('myMethod processes input', () async {
      final session = sessionBuilder.build();
      
      final result = await endpoints.my.myMethod(session, 'test');
      
      expect(result, 'Processed: test');
    });
  });
}
```

#### 4. Use in App

```bash
cd rmotly_app
flutter pub get
```

```dart
final result = await client.my.myMethod('test');
print(result); // Processed: test
```

### Adding a New Screen

#### 1. Create Feature Directory

```bash
mkdir -p rmotly_app/lib/features/my_screen
```

#### 2. Create View

```dart
// lib/features/my_screen/my_screen_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreenView extends ConsumerWidget {
  const MyScreenView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Screen'),
      ),
      body: const Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}
```

#### 3. Add Route

```dart
// lib/core/routing/app_router.dart
GoRoute(
  path: '/my-screen',
  builder: (context, state) => const MyScreenView(),
),
```

#### 4. Add ViewModel (if needed)

```dart
// lib/features/my_screen/my_screen_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreenViewModel extends StateNotifier<AsyncValue<MyScreenState>> {
  MyScreenViewModel() : super(const AsyncValue.loading()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Load data
      return MyScreenState(data: 'loaded');
    });
  }
}

final myScreenViewModelProvider = 
    StateNotifierProvider<MyScreenViewModel, AsyncValue<MyScreenState>>((ref) {
  return MyScreenViewModel();
});
```

#### 5. Add Tests

```dart
// test/widget/features/my_screen/my_screen_view_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyScreenView displays title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MyScreenView(),
      ),
    );

    expect(find.text('My Screen'), findsOneWidget);
  });
}
```

---

## Performance & Optimization

Tips for keeping your app fast and responsive.

### Hot Reload vs Hot Restart

| Feature | Hot Reload | Hot Restart |
|---------|------------|-------------|
| **Speed** | ~1 second | ~3-5 seconds |
| **Preserves State** | Yes | No |
| **Updates** | Code changes | Everything |
| **Shortcut** | `r` / Cmd+S | `R` / Cmd+Shift+R |
| **Use When** | Most changes | State issues, new dependencies |

**Best Practice:** Use hot reload for most development. Hot restart when:
- Adding new dependencies
- Changing `main()` function
- Modifying app initialization
- State is corrupted

### Build Optimization

#### Development Builds

```bash
# Standard debug build (slow but full debugging)
flutter run

# Profile mode (optimized but with profiling)
flutter run --profile

# Release mode (fully optimized, no debugging)
flutter run --release
```

#### Reduce Build Times

**Use cached dependencies:**
```bash
flutter pub get --offline
```

**Skip unnecessary steps:**
```bash
# Skip gradle daemon
flutter run --no-gradle-daemon

# Use incremental builds
flutter build apk --split-per-abi
```

**Clean when needed:**
```bash
flutter clean
flutter pub get
```

### Profiling Tools

#### CPU Profiling

```bash
# Run in profile mode
flutter run --profile

# Open DevTools and click "Performance" tab
# Record CPU profile during interaction
```

**Look for:**
- Frame rendering >16ms (causes jank)
- Long-running synchronous operations
- Excessive widget rebuilds

#### Memory Profiling

```bash
flutter run --profile
```

In DevTools Memory tab:
- Take heap snapshots
- Look for memory leaks (retained objects)
- Analyze memory usage over time

**Common Issues:**
- Unclosed streams
- Unreleased controllers
- Cached images not released

#### Network Profiling

In DevTools Network tab:
- Monitor HTTP requests
- Check request/response sizes
- Identify slow endpoints

**Optimization Tips:**
- Cache API responses
- Use pagination
- Compress payloads
- Use WebSocket for real-time data

### Code Optimization

#### Widget Rebuilds

Minimize unnecessary rebuilds:

```dart
// Bad: Everything rebuilds
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final data = ref.watch(dataProvider);
        return Column(
          children: [
            ExpensiveWidget(),  // Rebuilds unnecessarily
            Text(data),
          ],
        );
      },
    );
  }
}

// Good: Only Text rebuilds
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ExpensiveWidget(),  // const prevents rebuild
        Consumer(
          builder: (context, ref, child) {
            final data = ref.watch(dataProvider);
            return Text(data);
          },
        ),
      ],
    );
  }
}
```

#### Use const Constructors

```dart
// Good
const Text('Hello')
const SizedBox(height: 16)
const Icon(Icons.home)
```

#### Lazy Loading

```dart
// Load data on demand
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(items[index]);
  },
);
```

### Server Optimization

#### Database Queries

```dart
// Bad: N+1 query problem
for (final control in controls) {
  final action = await Action.db.findById(session, control.actionId);
}

// Good: Single query with join
final controls = await Control.db.find(
  session,
  include: Control.include(action: Action.include()),
);
```

#### Caching

```dart
// Cache frequently accessed data
final cached = await session.redis.get('key');
if (cached != null) {
  return cached;
}

final data = await expensiveOperation();
await session.redis.setEx('key', 3600, data);
return data;
```

---

## Troubleshooting

Common issues and solutions.

### Server Won't Start

**Issue:** Server fails with database connection error

```
Error: Failed to connect to database
```

**Solution:**
```bash
# Check Docker services
docker compose ps

# Restart services if needed
docker compose restart postgres redis

# Verify connection
psql -h localhost -p 8090 -U postgres -d rmotly
```

---

**Issue:** Port already in use

```
Error: Address already in use (port 8080)
```

**Solution:**
```bash
# Find process using port
lsof -i :8080

# Kill process
kill -9 <PID>

# Or change port in config/development.yaml
```

### App Won't Build

**Issue:** Dependency conflicts

```
Error: Version solving failed
```

**Solution:**
```bash
# Clean and reinstall
rm pubspec.lock
flutter clean
flutter pub get
```

---

**Issue:** Gradle build fails (Android)

```
Error: Could not resolve dependencies
```

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Tests Failing

**Issue:** Tests fail after code generation

```
Error: Type 'MyModel' not found
```

**Solution:**
```bash
# Regenerate code
cd rmotly_server
serverpod generate

# Update app dependencies
cd ../rmotly_app
flutter pub get

# Run tests again
flutter test
```

### Docker Issues

**Issue:** Containers won't start

```bash
# View logs
docker compose logs postgres
docker compose logs redis

# Restart everything
docker compose down
docker compose up -d
```

---

**Issue:** Out of disk space

```bash
# Clean up Docker
docker system prune -a --volumes
```

### Need More Help?

- Check [ARCHITECTURE.md](docs/ARCHITECTURE.md) for system design
- Check [API.md](docs/API.md) for endpoint documentation
- Check [TESTING.md](docs/TESTING.md) for testing guide
- Check [GIT.md](docs/GIT.md) for Git workflows
- Check `.claude/CONVENTIONS.md` for coding standards

---

## Summary

You now have a complete development environment for Rmotly! Here's a quick reference:

**Start Development:**
```bash
# Terminal 1: Docker services
cd rmotly_server && docker compose up -d

# Terminal 2: Server
cd rmotly_server && dart run bin/main.dart

# Terminal 3: App
cd rmotly_app && flutter run
```

**Run Tests:**
```bash
# Server
cd rmotly_server && dart test

# App
cd rmotly_app && flutter test
```

**Regenerate Code:**
```bash
cd rmotly_server && serverpod generate
```

Happy coding! 🚀
