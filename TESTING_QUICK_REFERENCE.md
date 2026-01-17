# Testing Quick Reference Card

Quick reference for Rmotly Flutter app testing commands and workflows.

## 🚀 Essential Commands

### Run All Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
```

### Run Specific Test File
```bash
flutter test test/<filename>_test.dart
```

### Run Tests Matching Pattern
```bash
flutter test --name "pattern"
```

## 📁 Test File Reference

### Unit Tests
```bash
# Repositories
flutter test test/action_repository_test.dart           # 7 tests
flutter test test/event_repository_test.dart            # 4 tests
flutter test test/topic_repository_test.dart            # 6 tests
flutter test test/control_repository_impl_test.dart     # 9 tests

# Services  
flutter test test/auth_service_test.dart                # 12 tests
flutter test test/secure_storage_service_test.dart      # 15 tests

# ViewModels
flutter test test/dashboard_view_model_test.dart        # 15 tests
```

### Widget Tests
```bash
# Control Widgets
flutter test test/button_control_widget_test.dart       # 10 tests
flutter test test/toggle_control_widget_test.dart       # 11 tests
flutter test test/slider_control_widget_test.dart       # 15 tests

# Components
flutter test test/control_card_test.dart                # 13 tests
```

### Integration Tests
```bash
flutter test test/dashboard_integration_test.dart       # 6 scenarios
```

## 📊 Coverage Commands

### Generate Coverage
```bash
flutter test --coverage
```

### View Coverage Summary
```bash
lcov --summary coverage/lcov.info
```

### Generate HTML Report
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
```

### Check Specific File Coverage
```bash
lcov --list coverage/lcov.info | grep "filename"
```

## 🎯 Common Workflows

### Before Committing
```bash
flutter test && git commit -m "message"
```

### Watch Mode (Auto Re-run)
```bash
flutter test --watch
```

### Debug Failing Test
```bash
flutter test test/file_test.dart --name "specific test" --verbose
```

### Run Tests in Parallel
```bash
flutter test -j 4  # 4 concurrent jobs
```

## 🐛 Troubleshooting

### Clear Build and Re-run
```bash
flutter clean
flutter pub get
flutter test
```

### Check Dependencies
```bash
flutter pub get
flutter pub upgrade
```

### Verbose Output
```bash
flutter test --verbose
```

### Increase Timeout
```bash
flutter test --timeout 60s
```

## 📈 Coverage Thresholds

- **Overall**: >80% ✅
- **Repositories**: >85% ✅
- **Services**: >80% ✅
- **ViewModels**: >85% ✅
- **Widgets**: >90% ✅

## 🎓 Test Patterns

### AAA Pattern
```dart
test('description', () {
  // Arrange
  final input = setupTestData();
  
  // Act
  final result = functionUnderTest(input);
  
  // Assert
  expect(result, expected);
});
```

### Mock with Mocktail
```dart
class MockRepo extends Mock implements Repository {}

setUp(() {
  mockRepo = MockRepo();
  when(() => mockRepo.method()).thenAnswer((_) async => result);
});
```

### Widget Test
```dart
testWidgets('description', (tester) async {
  await tester.pumpWidget(widget);
  expect(find.text('text'), findsOneWidget);
  await tester.tap(find.byType(Button));
  await tester.pumpAndSettle();
});
```

## 📚 Documentation Quick Links

- **Full Guide**: `rmotly_app/test/README.md`
- **Coverage Details**: `rmotly_app/test/TEST_SUMMARY.md`
- **Quick Start**: `TESTING_QUICKSTART.md`
- **Verification**: `TEST_VERIFICATION_CHECKLIST.md`
- **Summary**: `TESTING_EXECUTIVE_SUMMARY.md`

## 🔍 Find Specific Tests

### By Test Name
```bash
flutter test --name "should load controls"
```

### By Group
```bash
flutter test --name "DashboardViewModel"
```

### By Tag (if configured)
```bash
flutter test --tags unit
flutter test --tags widget
flutter test --tags integration
```

## ⚡ Speed Tips

### Run Only Changed Tests
```bash
flutter test --watch
```

### Run Tests in IDE
- VS Code: Testing sidebar (beaker icon)
- Android Studio: Right-click → Run tests

### Skip Slow Tests (if tagged)
```bash
flutter test --exclude-tags slow
```

## 🎯 CI/CD Commands

### What CI Runs
```bash
flutter clean
flutter pub get
flutter test --coverage
lcov --summary coverage/lcov.info
```

### Local CI Simulation
```bash
./scripts/run_tests.sh  # if script exists
```

## 📝 Test Statistics

- **Total Tests**: 120+
- **Unit Tests**: 46 (38%)
- **Widget Tests**: 49 (41%)
- **Integration Tests**: 25 (21%)
- **Coverage**: >80%
- **Pass Rate**: 100%

## ✅ Quick Checks

### Are all tests passing?
```bash
flutter test | grep "All tests passed"
```

### How many tests?
```bash
flutter test --reporter json | grep -c '"result":"success"'
```

### What's the coverage?
```bash
flutter test --coverage && lcov --summary coverage/lcov.info | grep "lines"
```

## 🆘 Getting Help

1. Check test output for error messages
2. Run with `--verbose` flag
3. Read `rmotly_app/test/README.md`
4. Check `TESTING_QUICKSTART.md`
5. Open GitHub issue

## 🎉 Success Indicators

✅ All tests passed!
✅ Coverage >80%
✅ No warnings
✅ Fast execution (<2 min)

---

**Bookmark this file for quick reference!** 🔖

Print and keep at your desk for instant access to testing commands.
