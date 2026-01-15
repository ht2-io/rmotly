---
applyTo: "rmotly_app/**"
---

# Flutter App Development Instructions

## Project Structure (Clean Architecture)

```
rmotly_app/lib/
├── core/                          # Shared utilities
│   ├── constants/                 # App-wide constants
│   ├── errors/                    # Custom exceptions
│   ├── extensions/                # Dart extensions
│   ├── utils/                     # Utility classes
│   └── providers/                 # Core Riverpod providers
├── features/                      # Feature modules
│   └── {feature_name}/
│       ├── data/
│       │   ├── repositories/      # Repository implementations
│       │   └── data_sources/      # API/local data sources
│       ├── domain/
│       │   ├── entities/          # Business entities
│       │   └── repositories/      # Repository interfaces (abstract)
│       └── presentation/
│           ├── views/             # Screen widgets
│           ├── view_models/       # Riverpod state notifiers
│           └── widgets/           # Feature-specific widgets
└── shared/
    ├── widgets/                   # Reusable widgets
    └── services/                  # Shared services
```

## Test Structure

Tests MUST mirror the source structure:

```
rmotly_app/test/
├── unit/                          # Unit tests
│   ├── core/
│   │   └── utils/
│   │       └── template_parser_test.dart
│   └── features/
│       └── dashboard/
│           └── dashboard_viewmodel_test.dart
├── widget/                        # Widget tests
│   └── features/
│       └── dashboard/
│           └── button_control_widget_test.dart
├── integration/                   # Integration tests
└── fixtures/                      # Test data
    └── test_data.dart
```

## File Naming

- Use `snake_case` for all file names
- Suffix test files with `_test.dart`
- Suffix provider files with `_provider.dart`
- Suffix view model files with `_view_model.dart`

```
✅ CORRECT: dashboard_view_model.dart
✅ CORRECT: control_repository.dart
✅ CORRECT: button_control_widget_test.dart

❌ WRONG: DashboardViewModel.dart
❌ WRONG: controlRepository.dart
```

## Riverpod Patterns

```dart
// Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Repository provider
final controlRepositoryProvider = Provider<ControlRepository>((ref) {
  return ControlRepositoryImpl(ref.watch(apiServiceProvider));
});

// ViewModel provider (StateNotifier)
final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardState>>((ref) {
  return DashboardViewModel(ref.watch(controlRepositoryProvider));
});

// Simple state
final selectedControlProvider = StateProvider<String?>((ref) => null);
```

## Testing with Mocktail

```dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockControlRepository extends Mock implements ControlRepository {}

void main() {
  late MockControlRepository mockRepo;

  setUp(() {
    mockRepo = MockControlRepository();
  });

  test('description', () {
    // Arrange
    when(() => mockRepo.getControls()).thenAnswer((_) async => []);

    // Act
    final result = await mockRepo.getControls();

    // Assert
    expect(result, isEmpty);
    verify(() => mockRepo.getControls()).called(1);
  });
}
```

## Widget Creation

Widgets MUST:
- Use `const` constructors where possible
- Accept required data via constructor parameters
- Use `Key` parameter for testing
- Follow Material 3 design guidelines

```dart
class ControlCard extends StatelessWidget {
  const ControlCard({
    super.key,
    required this.control,
    required this.onTap,
  });

  final Control control;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(control.name),
        ),
      ),
    );
  }
}
```

## Validation Commands

Before committing Flutter app changes:

```bash
cd rmotly_app
flutter pub get          # Get dependencies
dart format .            # Format code
dart analyze             # Check for issues
flutter test             # Run all tests
```

## Do NOT

- Use Mockito (use Mocktail instead)
- Skip writing tests for new code
- Put business logic in widgets
- Use `setState` for complex state (use Riverpod)
- Import from `lib/src/generated/` in app code
