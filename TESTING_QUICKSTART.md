# Quick Start: Running Rmotly Tests

This guide gets you up and running with the Rmotly test suite in under 5 minutes.

## Prerequisites

- Flutter SDK installed (>=3.24.0)
- Dart SDK (>=3.5.0)
- Project dependencies installed

## 1. Install Dependencies

```bash
cd rmotly_app
flutter pub get
```

## 2. Run Tests

### Run All Tests (Recommended)
```bash
flutter test
```

**Expected Output:**
```
✓ All tests passed! (120+ tests)
```

### Run with Coverage
```bash
flutter test --coverage
```

**Expected Output:**
```
✓ All tests passed!
Coverage: >80%
Report: coverage/lcov.info
```

## 3. View Coverage Report

### Generate HTML Report
```bash
# Install lcov (if not already installed)
# macOS:
brew install lcov

# Ubuntu/Debian:
sudo apt-get install lcov

# Generate HTML
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
```

## 4. Run Specific Tests

### Run Single Test File
```bash
flutter test test/dashboard_view_model_test.dart
```

### Run Tests by Pattern
```bash
# Run all widget tests
flutter test --name "Widget"

# Run all repository tests
flutter test --name "Repository"

# Run specific test
flutter test --name "should load controls"
```

## 5. Continuous Testing (Watch Mode)

```bash
# Install watchman (macOS)
brew install watchman

# Run tests on file changes
flutter test --watch
```

## Common Commands Reference

| Command | Purpose |
|---------|---------|
| `flutter test` | Run all tests |
| `flutter test --coverage` | Run tests with coverage |
| `flutter test test/FILE_test.dart` | Run specific file |
| `flutter test --name "TEST_NAME"` | Run specific test |
| `flutter test --watch` | Watch mode |
| `flutter test --verbose` | Verbose output |

## Test Categories

### Unit Tests (46 tests)
```bash
# Repositories
flutter test test/action_repository_test.dart
flutter test test/event_repository_test.dart
flutter test test/topic_repository_test.dart
flutter test test/control_repository_impl_test.dart

# Services
flutter test test/auth_service_test.dart
flutter test test/secure_storage_service_test.dart

# ViewModels
flutter test test/dashboard_view_model_test.dart
```

### Widget Tests (49 tests)
```bash
# Control Widgets
flutter test test/button_control_widget_test.dart
flutter test test/toggle_control_widget_test.dart
flutter test test/slider_control_widget_test.dart

# Components
flutter test test/control_card_test.dart
```

### Integration Tests (6 scenarios)
```bash
flutter test test/dashboard_integration_test.dart
```

## Troubleshooting

### Tests Failing?

**1. Ensure dependencies are up to date:**
```bash
flutter pub get
flutter pub upgrade
```

**2. Clear build cache:**
```bash
flutter clean
flutter pub get
```

**3. Run specific failing test with verbose output:**
```bash
flutter test test/FILE_test.dart --verbose
```

### Coverage Not Generating?

**Install lcov:**
```bash
# macOS
brew install lcov

# Ubuntu/Debian
sudo apt-get install lcov

# Windows
# Download from: https://github.com/linux-test-project/lcov/releases
```

### Test Timeout?

**Increase timeout:**
```bash
flutter test --timeout 60s
```

## IDE Integration

### VS Code

1. Install "Flutter" extension
2. Install "Dart" extension  
3. Use Testing sidebar (beaker icon)
4. Click play button next to tests

### Android Studio / IntelliJ

1. Install Flutter and Dart plugins
2. Right-click test file → "Run tests"
3. Use gutter icons to run individual tests
4. View results in Run panel

## CI/CD

Tests run automatically on:
- Every PR
- Every commit to main
- Nightly builds

**GitHub Actions**: `.github/workflows/test.yml`

## Success Indicators

✅ **All tests should pass:**
```
00:05 +120: All tests passed!
```

✅ **Coverage should be >80%:**
```
Lines: 85.3%
Functions: 87.1%
Branches: 82.4%
```

✅ **No warnings or errors in output**

## Next Steps

1. ✅ Verify all tests pass
2. ✅ Review coverage report
3. ✅ Run tests before committing
4. ✅ Add tests for new features
5. ✅ Keep coverage >80%

## Documentation

- **Detailed Guide**: `rmotly_app/test/README.md`
- **Coverage Report**: `rmotly_app/test/TEST_SUMMARY.md`
- **Completion Report**: `TESTING_COMPLETION_REPORT.md`

## Quick Tips

💡 **Run tests before committing:**
```bash
flutter test && git commit
```

💡 **Watch specific test file:**
```bash
flutter test test/FILE_test.dart --watch
```

💡 **Debug failing test:**
```bash
flutter test test/FILE_test.dart --name "failing test" --verbose
```

💡 **Check coverage for specific file:**
```bash
flutter test --coverage test/FILE_test.dart
genhtml coverage/lcov.info -o coverage/html
```

## Need Help?

- 📖 Read `rmotly_app/test/README.md`
- 📊 Check `rmotly_app/test/TEST_SUMMARY.md`
- 🐛 Check test output for error messages
- 💬 Open an issue on GitHub

---

**Ready to test!** 🚀

Run `flutter test` in the `rmotly_app` directory to get started.
