import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/features/dashboard/domain/repositories/control_repository.dart';
import 'package:rmotly_app/features/dashboard/presentation/view_models/dashboard_view_model.dart';
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
        when(() => mockRepository.getControls())
            .thenAnswer((_) async => [testControl1, testControl2]);

        // Act
        await viewModel.loadControls();

        // Assert
        final state = viewModel.state;
        expect(state.hasValue, true);
        expect(state.value!.controls.length, 2);
        expect(state.value!.controls[0].id, 1);
        expect(state.value!.controls[1].id, 2);
        verify(() => mockRepository.getControls()).called(1);
      });

      test('should set error state when loading fails', () async {
        // Arrange
        when(() => mockRepository.getControls())
            .thenThrow(Exception('Failed to load controls'));

        // Act
        await viewModel.loadControls();

        // Assert
        final state = viewModel.state;
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Failed to load controls'));
        verify(() => mockRepository.getControls()).called(1);
      });

      test('should set loading state while fetching controls', () async {
        // Arrange
        when(() => mockRepository.getControls())
            .thenAnswer((_) async => Future.delayed(
                  const Duration(milliseconds: 100),
                  () => [testControl1],
                ));

        // Act - Start loading without await
        final future = viewModel.loadControls();

        // Assert - Check loading state
        await Future.delayed(const Duration(milliseconds: 10));
        expect(viewModel.state.isLoading, true);

        // Complete the operation
        await future;
        expect(viewModel.state.hasValue, true);
      });
    });

    group('handleControlInteraction', () {
      test('should send control event through repository', () async {
        // Arrange
        const controlId = 1;
        const value = {'pressed': true};
        when(() => mockRepository.sendControlEvent(controlId, value))
            .thenAnswer((_) async => {});

        // Act
        await viewModel.handleControlInteraction(controlId, value);

        // Assert
        verify(() => mockRepository.sendControlEvent(controlId, value))
            .called(1);
      });

      test('should handle interaction errors gracefully', () async {
        // Arrange
        const controlId = 1;
        const value = {'pressed': true};
        when(() => mockRepository.sendControlEvent(controlId, value))
            .thenThrow(Exception('Network error'));

        // Act & Assert - Should not throw
        await expectLater(
          viewModel.handleControlInteraction(controlId, value),
          completes,
        );
      });
    });

    group('reorderControls', () {
      test('should reorder controls in state and update repository', () async {
        // Arrange
        when(() => mockRepository.getControls())
            .thenAnswer((_) async => [testControl1, testControl2]);
        when(() => mockRepository.updateControlPositions(any()))
            .thenAnswer((_) async => {});

        await viewModel.loadControls();

        // Act
        await viewModel.reorderControls(0, 1);

        // Assert
        final state = viewModel.state.value!;
        expect(state.controls[0].id, 2);
        expect(state.controls[1].id, 1);
        verify(() => mockRepository.updateControlPositions(any())).called(1);
      });

      test('should handle reorder errors and restore original order', () async {
        // Arrange
        when(() => mockRepository.getControls())
            .thenAnswer((_) async => [testControl1, testControl2]);
        when(() => mockRepository.updateControlPositions(any()))
            .thenThrow(Exception('Failed to update positions'));

        await viewModel.loadControls();

        // Act
        await viewModel.reorderControls(0, 1);

        // Assert - Order should be restored
        final state = viewModel.state.value!;
        expect(state.controls[0].id, 1);
        expect(state.controls[1].id, 2);
      });
    });

    group('deleteControl', () {
      test('should delete control and remove from state', () async {
        // Arrange
        when(() => mockRepository.getControls())
            .thenAnswer((_) async => [testControl1, testControl2]);
        when(() => mockRepository.deleteControl(1))
            .thenAnswer((_) async => {});

        await viewModel.loadControls();

        // Act
        await viewModel.deleteControl(1);

        // Assert
        final state = viewModel.state.value!;
        expect(state.controls.length, 1);
        expect(state.controls[0].id, 2);
        verify(() => mockRepository.deleteControl(1)).called(1);
      });

      test('should handle delete errors and restore control', () async {
        // Arrange
        when(() => mockRepository.getControls())
            .thenAnswer((_) async => [testControl1, testControl2]);
        when(() => mockRepository.deleteControl(1))
            .thenThrow(Exception('Failed to delete'));

        await viewModel.loadControls();

        // Act
        await viewModel.deleteControl(1);

        // Assert - Control should still be present
        final state = viewModel.state.value!;
        expect(state.controls.length, 2);
        expect(state.controls.any((c) => c.id == 1), true);
      });

      test('should handle deleting non-existent control gracefully', () async {
        // Arrange
        when(() => mockRepository.getControls())
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
        final state = viewModel.state.value!;
        expect(state.controls.length, 1);
      });
    });

    group('refreshControls', () {
      test('should reload controls from repository', () async {
        // Arrange
        when(() => mockRepository.getControls())
            .thenAnswer((_) async => [testControl1]);

        await viewModel.loadControls();
        verify(() => mockRepository.getControls()).called(1);

        // Act
        when(() => mockRepository.getControls())
            .thenAnswer((_) async => [testControl1, testControl2]);
        await viewModel.refreshControls();

        // Assert
        final state = viewModel.state.value!;
        expect(state.controls.length, 2);
        verify(() => mockRepository.getControls()).called(2);
      });
    });
  });
}
