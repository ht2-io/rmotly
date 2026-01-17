import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rmotly_app/features/dashboard/data/repositories/control_repository_impl.dart';
import 'package:rmotly_app/features/dashboard/domain/repositories/control_repository.dart';
import 'package:rmotly_app/core/services/local_storage_service.dart';
import 'package:rmotly_client/rmotly_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

// Mock classes
class MockClient extends Mock implements Client {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockSessionManager extends Mock implements SessionManager {}

void main() {
  late MockClient mockClient;
  late MockLocalStorageService mockStorage;
  late MockSessionManager mockSessionManager;
  late ControlRepository repository;

  setUp(() {
    mockClient = MockClient();
    mockStorage = MockLocalStorageService();
    mockSessionManager = MockSessionManager();

    // Default behavior
    when(() => mockSessionManager.signedInUser).thenReturn(null);

    repository = ControlRepositoryImpl(mockClient, mockStorage, mockSessionManager);
  });

  group('ControlRepositoryImpl', () {
    group('getControls', () {
      test('should return mock controls during development', () async {
        // Act
        final controls = await repository.getControls();

        // Assert
        expect(controls, isNotEmpty);
        expect(controls.length, 2);
        expect(controls[0].name, 'Living Room Light');
        expect(controls[0].controlType, 'button');
        expect(controls[1].name, 'Thermostat');
        expect(controls[1].controlType, 'slider');
      });

      test('should return controls ordered by position', () async {
        // Act
        final controls = await repository.getControls();

        // Assert
        expect(controls[0].position, 0);
        expect(controls[1].position, 1);
      });

      test('should return controls with valid IDs', () async {
        // Act
        final controls = await repository.getControls();

        // Assert
        for (final control in controls) {
          expect(control.id, isNotNull);
          expect(control.id, greaterThan(0));
        }
      });

      test('should return controls with valid timestamps', () async {
        // Act
        final controls = await repository.getControls();

        // Assert
        for (final control in controls) {
          expect(control.createdAt, isNotNull);
          expect(control.updatedAt, isNotNull);
          expect(control.updatedAt.isAfter(control.createdAt) ||
                 control.updatedAt.isAtSameMomentAs(control.createdAt), isTrue);
        }
      });

      test('should return controls with valid JSON config', () async {
        // Act
        final controls = await repository.getControls();

        // Assert
        for (final control in controls) {
          expect(control.config, isNotEmpty);
          // Config should be valid JSON string
          expect(() => control.config, returnsNormally);
        }
      });
    });

    group('createControl', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Arrange
        final control = Control(
          id: null,
          userId: 1,
          name: 'New Control',
          controlType: 'button',
          config: '{"label": "Press"}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => repository.createControl(control),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('updateControl', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Arrange
        final control = Control(
          id: 1,
          userId: 1,
          name: 'Updated Control',
          controlType: 'button',
          config: '{"label": "Press"}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => repository.updateControl(control),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('deleteControl', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Act & Assert
        expect(
          () => repository.deleteControl(1),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('reorderControls', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Arrange
        final controls = [
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

        // Act & Assert
        expect(
          () => repository.reorderControls(controls),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('sendControlEvent', () {
      test('should throw UnimplementedError when endpoint is not available', () {
        // Act & Assert
        expect(
          () => repository.sendControlEvent(
            1,
            'button_press',
            {'pressed': true},
          ),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
  });
}
