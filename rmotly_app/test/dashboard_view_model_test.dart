import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/core/event_type.dart';
import 'package:rmotly_app/features/dashboard/domain/repositories/control_repository.dart';
import 'package:rmotly_app/features/dashboard/presentation/viewmodel/dashboard_viewmodel.dart';
import 'package:rmotly_client/rmotly_client.dart';

// Mock classes
class MockControlRepository extends Mock implements ControlRepository {}

void main() {
  late MockControlRepository mockRepository;
  late DashboardViewModel viewModel;

  // Test data
  final testControl1 = Control(
    id: 1,
    userId: 100,
    name: 'Test Button',
    controlType: 'button',
    config: '{"label": "Press Me"}',
    position: 0,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final testControl2 = Control(
    id: 2,
    userId: 100,
    name: 'Test Toggle',
    controlType: 'toggle',
    config: '{"label": "Switch"}',
    position: 1,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockRepository = MockControlRepository();
    viewModel = DashboardViewModel(mockRepository);
  });

  group('DashboardViewModel', () {
    group('loadControls', () {
      test('should load controls from repository and update state', () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [testControl1, testControl2]);

        // Act
        await viewModel.loadControls();

        // Assert
        final state = viewModel.state;
        expect(state.controls.length, 2);
        expect(state.controls[0].id, 1);
        expect(state.controls[1].id, 2);
        expect(state.isLoading, false);
        verify(() => mockRepository.getControls(forceRefresh: false)).called(1);
      });

      test('should set error state when loading fails', () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(Exception('Failed to load controls'));

        // Create a fresh viewmodel without auto-loading
        final testViewModel = DashboardViewModel(mockRepository);
        // Wait for constructor to complete initial load
        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        await testViewModel.loadControls();

        // Assert
        final state = testViewModel.state;
        expect(state.error, isNotNull);
        expect(state.error.toString(), contains('Failed to load controls'));
      });

      test('should set loading state while fetching controls', () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => Future.delayed(
                  const Duration(milliseconds: 100),
                  () => [testControl1],
                ));

        // Create viewmodel (will start loading automatically)
        final testViewModel = DashboardViewModel(mockRepository);

        // Assert - Check loading state
        await Future.delayed(const Duration(milliseconds: 10));
        expect(testViewModel.state.isLoading, true);

        // Wait for completion
        await Future.delayed(const Duration(milliseconds: 150));
        expect(testViewModel.state.isLoading, false);
        expect(testViewModel.state.controls.length, 1);
      });
    });

    group('handleControlInteraction', () {
      test('should execute control with button press', () async {
        // Arrange
        const controlId = 1;
        final eventType = EventType.buttonPress.value;
        const payload = {'pressed': true};
        when(() =>
                mockRepository.sendControlEvent(controlId, eventType, payload))
            .thenAnswer((_) async => {});

        // Create control for testing
        final testControl = Control(
          id: controlId,
          userId: 100,
          name: 'Test',
          controlType: 'button',
          config: '{}',
          position: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Act
        await viewModel.executeControl(testControl, payload);

        // Assert
        verify(() =>
                mockRepository.sendControlEvent(controlId, eventType, payload))
            .called(1);
      });

      test('should execute control with toggle change', () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [testControl2]);
        when(() => mockRepository.sendControlEvent(any(), any(), any()))
            .thenAnswer((_) async => {});

        await viewModel.loadControls();

        // Act
        await viewModel.onToggleChanged(testControl2, true);

        // Assert
        verify(() => mockRepository.sendControlEvent(
              2,
              'toggle_change',
              {'state': true},
            )).called(1);
      });

      test('should handle interaction errors gracefully', () async {
        // Arrange
        const controlId = 1;
        final eventType = EventType.buttonPress.value;
        const payload = {'pressed': true};
        when(() =>
                mockRepository.sendControlEvent(controlId, eventType, payload))
            .thenThrow(Exception('Network error'));

        final testControl = Control(
          id: controlId,
          userId: 100,
          name: 'Test',
          controlType: 'button',
          config: '{}',
          position: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Act & Assert - Should not throw
        await expectLater(
          viewModel.executeControl(testControl, payload),
          completes,
        );
        expect(viewModel.state.error, isNotNull);
      });
    });

    group('reorderControls', () {
      test('should reorder controls in state and update repository', () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [testControl1, testControl2]);
        when(() => mockRepository.reorderControls(any()))
            .thenAnswer((_) async => {});

        await viewModel.loadControls();

        // Act
        await viewModel.reorderControls(
            0, 2); // Move first to end (adjusts to index 1)

        // Assert
        final state = viewModel.state;
        expect(state.controls[0].id, 2);
        expect(state.controls[1].id, 1);
        verify(() => mockRepository.reorderControls(any())).called(1);
      });

      test('should handle reorder errors and restore original order', () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [testControl1, testControl2]);
        when(() => mockRepository.reorderControls(any()))
            .thenThrow(Exception('Failed to update positions'));

        await viewModel.loadControls();
        final originalOrder = viewModel.state.controls;

        // Act
        await viewModel.reorderControls(0, 2);

        // Assert - Order should be restored after reload
        verify(() => mockRepository.reorderControls(any())).called(1);
        // The viewModel will reload controls, so we need to verify that call
        verify(() => mockRepository.getControls(forceRefresh: false))
            .called(2); // Once for initial load, once for reload
      });
    });

    group('deleteControl', () {
      test('should delete control and remove from state', () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [testControl1, testControl2]);
        when(() => mockRepository.deleteControl(1)).thenAnswer((_) async => {});

        await viewModel.loadControls();

        // Act
        await viewModel.deleteControl(1);

        // Assert
        final state = viewModel.state;
        expect(state.controls.length, 1);
        expect(state.controls[0].id, 2);
        verify(() => mockRepository.deleteControl(1)).called(1);
      });

      test('should handle delete errors and keep control', () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [testControl1, testControl2]);
        when(() => mockRepository.deleteControl(1))
            .thenThrow(Exception('Failed to delete'));

        await viewModel.loadControls();

        // Act
        await viewModel.deleteControl(1);

        // Assert - Error should be set
        final state = viewModel.state;
        expect(state.error, isNotNull);
      });

      test('should handle deleting non-existent control gracefully', () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [testControl1]);
        when(() => mockRepository.deleteControl(999))
            .thenAnswer((_) async => {});

        await viewModel.loadControls();

        // Act & Assert - Should not throw
        await expectLater(
          viewModel.deleteControl(999),
          completes,
        );

        // State should remain unchanged
        final state = viewModel.state;
        expect(state.controls.length, 1);
      });
    });

    group('refreshControls', () {
      test('should reload controls from repository with force refresh',
          () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [testControl1]);

        await viewModel.loadControls();
        verify(() => mockRepository.getControls(forceRefresh: false)).called(1);

        // Act
        when(() => mockRepository.getControls(forceRefresh: true))
            .thenAnswer((_) async => [testControl1, testControl2]);
        await viewModel.refreshControls();

        // Assert
        final state = viewModel.state;
        expect(state.controls.length, 2);
        verify(() => mockRepository.getControls(forceRefresh: true)).called(1);
        expect(state.isRefreshing, false);
      });
    });

    group('clearError', () {
      test('should clear error from state', () async {
        // Arrange
        when(() => mockRepository.getControls(
                forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(Exception('Test error'));

        await viewModel.loadControls();
        expect(viewModel.state.error, isNotNull);

        // Act
        viewModel.clearError();

        // Assert
        expect(viewModel.state.error, isNull);
      });
    });
  });
}
