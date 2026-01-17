import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/features/dashboard/domain/repositories/control_repository.dart';
import 'package:rmotly_app/features/dashboard/presentation/viewmodel/dashboard_viewmodel.dart';
import 'package:rmotly_app/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:rmotly_app/features/dashboard/presentation/widgets/button_control_widget.dart';
import 'package:rmotly_app/features/dashboard/presentation/widgets/control_card.dart';
import 'package:rmotly_client/rmotly_client.dart';

// Mock classes
class MockControlRepository extends Mock implements ControlRepository {}

void main() {
  late MockControlRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      Control(
        id: 0,
        userId: 0,
        name: '',
        controlType: '',
        config: '{}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockRepository = MockControlRepository();
    // Set up default stub to return empty list
    // This prevents null errors when constructor calls loadControls()
    when(() => mockRepository.getControls(
            forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => []);
  });

  group('Dashboard Integration Tests', () {
    testWidgets('complete dashboard load and control execution flow',
        (tester) async {
      // Arrange
      final testControls = [
        Control(
          id: 1,
          userId: 1,
          name: 'Living Room Light',
          controlType: 'button',
          config: '{"label": "Toggle", "icon": "light"}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Control(
          id: 2,
          userId: 1,
          name: 'Thermostat',
          controlType: 'slider',
          config: '{"min": 60, "max": 80, "value": 72, "unit": "°F"}',
          position: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getControls(
              forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => testControls);
      when(() => mockRepository.sendControlEvent(any(), any(), any()))
          .thenAnswer((_) async => {});

      // Create provider override
      final container = ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(
            (ref) => DashboardViewModel(mockRepository),
          ),
        ],
      );

      // Act - Build app with dashboard
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final dashboardState = ref.watch(dashboardViewModelProvider);

                if (dashboardState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (dashboardState.error != null) {
                  return Center(child: Text('Error: ${dashboardState.error}'));
                }

                return Scaffold(
                  appBar: AppBar(title: const Text('Dashboard')),
                  body: ListView.builder(
                    itemCount: dashboardState.controls.length,
                    itemBuilder: (context, index) {
                      final control = dashboardState.controls[index];
                      return ControlCard(
                        control: control,
                        onEdit: () {},
                        onDelete: () {},
                        child: Text(control.name),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Assert - Dashboard loaded
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Living Room Light'), findsOneWidget);
      expect(find.text('Thermostat'), findsOneWidget);
      // Constructor calls getControls() once
      verify(() => mockRepository.getControls(forceRefresh: false)).called(1);

      container.dispose();
    });

    testWidgets('control execution updates state correctly', (tester) async {
      // Arrange
      final testControl = Control(
        id: 1,
        userId: 1,
        name: 'Test Button',
        controlType: 'button',
        config: '{"label": "Press Me"}',
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRepository.getControls(
              forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => [testControl]);
      when(() => mockRepository.sendControlEvent(any(), any(), any()))
          .thenAnswer(
              (_) async => Future.delayed(const Duration(milliseconds: 100)));

      final container = ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(
            (ref) => DashboardViewModel(mockRepository),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final dashboardState = ref.watch(dashboardViewModelProvider);
                final viewModel = ref.read(dashboardViewModelProvider.notifier);

                if (dashboardState.controls.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final control = dashboardState.controls.first;
                final isExecuting =
                    dashboardState.isControlExecuting(control.id!);

                return Scaffold(
                  body: Center(
                    child: ButtonControlWidget(
                      control: control,
                      onPressed: () => viewModel.onButtonPressed(control),
                      isExecuting: isExecuting,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Execute control
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      // Assert - Control is executing
      final dashboardState = container.read(dashboardViewModelProvider);
      expect(dashboardState.executingControlId, 1);

      // Wait for execution to complete
      await tester.pumpAndSettle();

      // Assert - Execution completed
      final finalState = container.read(dashboardViewModelProvider);
      expect(finalState.executingControlId, isNull);
      verify(() => mockRepository
          .sendControlEvent(1, 'button_press', {'pressed': true})).called(1);

      container.dispose();
    });

    testWidgets('error handling displays error message', (tester) async {
      // Arrange
      when(() => mockRepository.getControls(
              forceRefresh: any(named: 'forceRefresh')))
          .thenThrow(Exception('Network error'));

      final container = ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(
            (ref) => DashboardViewModel(mockRepository),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final dashboardState = ref.watch(dashboardViewModelProvider);

                if (dashboardState.error != null) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${dashboardState.error}'),
                    ),
                  );
                }

                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.textContaining('Network error'), findsOneWidget);

      container.dispose();
    });

    testWidgets('refresh controls reloads dashboard', (tester) async {
      // Arrange
      final initialControls = [
        Control(
          id: 1,
          userId: 1,
          name: 'Control 1',
          controlType: 'button',
          config: '{}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final refreshedControls = [
        ...initialControls,
        Control(
          id: 2,
          userId: 1,
          name: 'Control 2',
          controlType: 'button',
          config: '{}',
          position: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getControls(
              forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => initialControls);

      final container = ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(
            (ref) => DashboardViewModel(mockRepository),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final dashboardState = ref.watch(dashboardViewModelProvider);
                final viewModel = ref.read(dashboardViewModelProvider.notifier);

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Dashboard'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => viewModel.refreshControls(),
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      Text('Controls: ${dashboardState.controls.length}'),
                      for (final control in dashboardState.controls)
                        ListTile(title: Text(control.name)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert initial state
      expect(find.text('Controls: 1'), findsOneWidget);
      expect(find.text('Control 1'), findsOneWidget);

      // Act - Refresh
      when(() => mockRepository.getControls(
              forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => refreshedControls);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Assert - New controls loaded
      expect(find.text('Controls: 2'), findsOneWidget);
      expect(find.text('Control 2'), findsOneWidget);
      // Constructor calls once with forceRefresh: false, refresh() calls with forceRefresh: true
      verify(() => mockRepository.getControls(forceRefresh: false)).called(1);
      verify(() => mockRepository.getControls(forceRefresh: true)).called(1);

      container.dispose();
    });

    testWidgets('delete control removes it from list', (tester) async {
      // Arrange
      final testControls = [
        Control(
          id: 1,
          userId: 1,
          name: 'Control 1',
          controlType: 'button',
          config: '{}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Control(
          id: 2,
          userId: 1,
          name: 'Control 2',
          controlType: 'button',
          config: '{}',
          position: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getControls(
              forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => testControls);
      when(() => mockRepository.deleteControl(any()))
          .thenAnswer((_) async => {});

      final container = ProviderContainer(
        overrides: [
          dashboardViewModelProvider.overrideWith(
            (ref) => DashboardViewModel(mockRepository),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final dashboardState = ref.watch(dashboardViewModelProvider);
                final viewModel = ref.read(dashboardViewModelProvider.notifier);

                return Scaffold(
                  body: Column(
                    children: [
                      Text('Controls: ${dashboardState.controls.length}'),
                      for (final control in dashboardState.controls)
                        ListTile(
                          title: Text(control.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                viewModel.deleteControl(control.id!),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert initial state
      expect(find.text('Controls: 2'), findsOneWidget);
      expect(find.text('Control 1'), findsOneWidget);
      expect(find.text('Control 2'), findsOneWidget);

      // Act - Delete first control
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Assert - Control removed
      expect(find.text('Controls: 1'), findsOneWidget);
      expect(find.text('Control 1'), findsNothing);
      expect(find.text('Control 2'), findsOneWidget);
      verify(() => mockRepository.deleteControl(1)).called(1);

      container.dispose();
    });
  });
}

// Provider definition for testing
final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  throw UnimplementedError();
});
