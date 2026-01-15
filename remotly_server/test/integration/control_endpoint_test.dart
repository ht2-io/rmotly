import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given ControlEndpoint', (sessionBuilder, endpoints) {
    group('createControl', () {
      test('creates control with auto position', () async {
        final control = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test Button',
          controlType: 'button',
          config: '{"color": "blue"}',
        );

        expect(control.name, 'Test Button');
        expect(control.controlType, 'button');
        expect(control.config, '{"color": "blue"}');
        expect(control.position, 0);
        expect(control.id, isNotNull);
      });

      test('creates control with specified position', () async {
        final control = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test Toggle',
          controlType: 'toggle',
          config: '{"enabled": true}',
          position: 5,
        );

        expect(control.position, 5);
      });

      test('creates control with optional actionId', () async {
        final control = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test Control',
          controlType: 'button',
          actionId: 42,
          config: '{}',
        );

        expect(control.actionId, 42);
      });

      test('throws ArgumentError when name is empty', () async {
        expect(
          () => endpoints.control.createControl(
            sessionBuilder,
            name: '',
            controlType: 'button',
            config: '{}',
          ),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError when controlType is empty', () async {
        expect(
          () => endpoints.control.createControl(
            sessionBuilder,
            name: 'Test',
            controlType: '',
            config: '{}',
          ),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError when config is empty', () async {
        expect(
          () => endpoints.control.createControl(
            sessionBuilder,
            name: 'Test',
            controlType: 'button',
            config: '',
          ),
          throwsArgumentError,
        );
      });
    });

    group('listControls', () {
      test('returns empty list when no controls exist', () async {
        final controls = await endpoints.control.listControls(sessionBuilder);
        expect(controls, isEmpty);
      });

      test('returns controls ordered by position', () async {
        // Create controls in non-sequential order
        await endpoints.control.createControl(
          sessionBuilder,
          name: 'Third',
          controlType: 'button',
          config: '{}',
          position: 2,
        );
        await endpoints.control.createControl(
          sessionBuilder,
          name: 'First',
          controlType: 'button',
          config: '{}',
          position: 0,
        );
        await endpoints.control.createControl(
          sessionBuilder,
          name: 'Second',
          controlType: 'button',
          config: '{}',
          position: 1,
        );

        final controls = await endpoints.control.listControls(sessionBuilder);
        
        expect(controls.length, 3);
        expect(controls[0].name, 'First');
        expect(controls[1].name, 'Second');
        expect(controls[2].name, 'Third');
      });
    });

    group('getControl', () {
      test('returns control by id', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test Control',
          controlType: 'button',
          config: '{}',
        );

        final retrieved = await endpoints.control.getControl(
          sessionBuilder,
          created.id!,
        );

        expect(retrieved, isNotNull);
        expect(retrieved!.id, created.id);
        expect(retrieved.name, created.name);
      });

      test('returns null for non-existent control', () async {
        final control = await endpoints.control.getControl(
          sessionBuilder,
          99999,
        );

        expect(control, isNull);
      });
    });

    group('updateControl', () {
      test('updates control name', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Original Name',
          controlType: 'button',
          config: '{}',
        );

        final updated = await endpoints.control.updateControl(
          sessionBuilder,
          created.id!,
          name: 'Updated Name',
        );

        expect(updated, isNotNull);
        expect(updated!.name, 'Updated Name');
        expect(updated.controlType, 'button'); // unchanged
      });

      test('updates control type', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test',
          controlType: 'button',
          config: '{}',
        );

        final updated = await endpoints.control.updateControl(
          sessionBuilder,
          created.id!,
          controlType: 'toggle',
        );

        expect(updated!.controlType, 'toggle');
      });

      test('updates control config', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test',
          controlType: 'button',
          config: '{"a": 1}',
        );

        final updated = await endpoints.control.updateControl(
          sessionBuilder,
          created.id!,
          config: '{"b": 2}',
        );

        expect(updated!.config, '{"b": 2}');
      });

      test('updates control actionId', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test',
          controlType: 'button',
          config: '{}',
        );

        final updated = await endpoints.control.updateControl(
          sessionBuilder,
          created.id!,
          actionId: 123,
        );

        expect(updated!.actionId, 123);
      });

      test('updates multiple fields at once', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Original',
          controlType: 'button',
          config: '{}',
        );

        final updated = await endpoints.control.updateControl(
          sessionBuilder,
          created.id!,
          name: 'Updated',
          controlType: 'toggle',
          config: '{"new": true}',
          actionId: 456,
        );

        expect(updated!.name, 'Updated');
        expect(updated.controlType, 'toggle');
        expect(updated.config, '{"new": true}');
        expect(updated.actionId, 456);
      });

      test('returns null for non-existent control', () async {
        final updated = await endpoints.control.updateControl(
          sessionBuilder,
          99999,
          name: 'New Name',
        );

        expect(updated, isNull);
      });

      test('throws ArgumentError when no parameters provided', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test',
          controlType: 'button',
          config: '{}',
        );

        expect(
          () => endpoints.control.updateControl(
            sessionBuilder,
            created.id!,
          ),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError when name is empty', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test',
          controlType: 'button',
          config: '{}',
        );

        expect(
          () => endpoints.control.updateControl(
            sessionBuilder,
            created.id!,
            name: '',
          ),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError when controlType is empty', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test',
          controlType: 'button',
          config: '{}',
        );

        expect(
          () => endpoints.control.updateControl(
            sessionBuilder,
            created.id!,
            controlType: '',
          ),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError when config is empty', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test',
          controlType: 'button',
          config: '{}',
        );

        expect(
          () => endpoints.control.updateControl(
            sessionBuilder,
            created.id!,
            config: '',
          ),
          throwsArgumentError,
        );
      });
    });

    group('deleteControl', () {
      test('deletes existing control', () async {
        final created = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test',
          controlType: 'button',
          config: '{}',
        );

        final deleted = await endpoints.control.deleteControl(
          sessionBuilder,
          created.id!,
        );

        expect(deleted, isTrue);

        // Verify it's gone
        final retrieved = await endpoints.control.getControl(
          sessionBuilder,
          created.id!,
        );
        expect(retrieved, isNull);
      });

      test('returns false for non-existent control', () async {
        final deleted = await endpoints.control.deleteControl(
          sessionBuilder,
          99999,
        );

        expect(deleted, isFalse);
      });
    });

    group('reorderControls', () {
      test('reorders controls and updates positions', () async {
        // Create three controls
        final control1 = await endpoints.control.createControl(
          sessionBuilder,
          name: 'First',
          controlType: 'button',
          config: '{}',
          position: 0,
        );
        final control2 = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Second',
          controlType: 'button',
          config: '{}',
          position: 1,
        );
        final control3 = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Third',
          controlType: 'button',
          config: '{}',
          position: 2,
        );

        // Reorder them: 3, 1, 2
        final success = await endpoints.control.reorderControls(
          sessionBuilder,
          [control3.id!, control1.id!, control2.id!],
        );

        expect(success, isTrue);

        // Verify new order
        final controls = await endpoints.control.listControls(sessionBuilder);
        expect(controls[0].id, control3.id);
        expect(controls[0].position, 0);
        expect(controls[1].id, control1.id);
        expect(controls[1].position, 1);
        expect(controls[2].id, control2.id);
        expect(controls[2].position, 2);
      });

      test('throws ArgumentError when controlIds is empty', () async {
        expect(
          () => endpoints.control.reorderControls(
            sessionBuilder,
            [],
          ),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError when controlIds has duplicates', () async {
        final control = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test',
          controlType: 'button',
          config: '{}',
        );

        expect(
          () => endpoints.control.reorderControls(
            sessionBuilder,
            [control.id!, control.id!],
          ),
          throwsArgumentError,
        );
      });

      test('throws StateError when control does not exist', () async {
        final control = await endpoints.control.createControl(
          sessionBuilder,
          name: 'Test',
          controlType: 'button',
          config: '{}',
        );

        expect(
          () => endpoints.control.reorderControls(
            sessionBuilder,
            [control.id!, 99999],
          ),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
