import 'package:test/test.dart';
import 'package:remotly_server/src/generated/protocol.dart';

// Import the generated test helper file
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Control model', (sessionBuilder, endpoints) {
    group('database operations', () {
      test('when creating a control then it is saved to database', () async {
        // Arrange
        final session = await sessionBuilder.build();
        final control = Control(
          userId: 1,
          name: 'Test Button',
          controlType: 'button',
          actionId: null,
          config: '{"icon": "lightbulb", "color": "#FF5722"}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final savedControl = await Control.db.insertRow(session, control);

        // Assert
        expect(savedControl.id, isNotNull);
        expect(savedControl.name, 'Test Button');
        expect(savedControl.controlType, 'button');
        expect(savedControl.userId, 1);
      });

      test('when finding control by id then returns correct control', () async {
        // Arrange
        final session = await sessionBuilder.build();
        final control = Control(
          userId: 1,
          name: 'Toggle Switch',
          controlType: 'toggle',
          actionId: null,
          config: '{"onLabel": "On", "offLabel": "Off"}',
          position: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final savedControl = await Control.db.insertRow(session, control);

        // Act
        final foundControl = await Control.db.findById(session, savedControl.id!);

        // Assert
        expect(foundControl, isNotNull);
        expect(foundControl!.id, savedControl.id);
        expect(foundControl.name, 'Toggle Switch');
        expect(foundControl.controlType, 'toggle');
      });

      test('when updating control then changes are persisted', () async {
        // Arrange
        final session = await sessionBuilder.build();
        final control = Control(
          userId: 1,
          name: 'Old Name',
          controlType: 'slider',
          actionId: null,
          config: '{"min": 0, "max": 100}',
          position: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final savedControl = await Control.db.insertRow(session, control);

        // Act
        savedControl.name = 'New Name';
        savedControl.updatedAt = DateTime.now();
        await Control.db.updateRow(session, savedControl);

        // Assert
        final updatedControl = await Control.db.findById(session, savedControl.id!);
        expect(updatedControl!.name, 'New Name');
      });

      test('when deleting control then it is removed from database', () async {
        // Arrange
        final session = await sessionBuilder.build();
        final control = Control(
          userId: 1,
          name: 'To Delete',
          controlType: 'button',
          actionId: null,
          config: '{}',
          position: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final savedControl = await Control.db.insertRow(session, control);

        // Act
        await Control.db.deleteRow(session, savedControl);

        // Assert
        final deletedControl = await Control.db.findById(session, savedControl.id!);
        expect(deletedControl, isNull);
      });

      test('when finding controls by userId then returns user controls', () async {
        // Arrange
        final session = await sessionBuilder.build();
        final userId = 2;
        
        // Create multiple controls for the same user
        await Control.db.insertRow(session, Control(
          userId: userId,
          name: 'Control 1',
          controlType: 'button',
          actionId: null,
          config: '{}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        
        await Control.db.insertRow(session, Control(
          userId: userId,
          name: 'Control 2',
          controlType: 'toggle',
          actionId: null,
          config: '{}',
          position: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        
        // Create a control for a different user
        await Control.db.insertRow(session, Control(
          userId: 3,
          name: 'Other User Control',
          controlType: 'slider',
          actionId: null,
          config: '{}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        // Act
        final userControls = await Control.db.find(
          session,
          where: (t) => t.userId.equals(userId),
          orderBy: (t) => t.position,
        );

        // Assert
        expect(userControls.length, 2);
        expect(userControls[0].name, 'Control 1');
        expect(userControls[1].name, 'Control 2');
      });

      test('when controls ordered by position then returns correct order', () async {
        // Arrange
        final session = await sessionBuilder.build();
        final userId = 4;
        
        await Control.db.insertRow(session, Control(
          userId: userId,
          name: 'Third',
          controlType: 'button',
          actionId: null,
          config: '{}',
          position: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        
        await Control.db.insertRow(session, Control(
          userId: userId,
          name: 'First',
          controlType: 'button',
          actionId: null,
          config: '{}',
          position: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        
        await Control.db.insertRow(session, Control(
          userId: userId,
          name: 'Second',
          controlType: 'button',
          actionId: null,
          config: '{}',
          position: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        // Act
        final orderedControls = await Control.db.find(
          session,
          where: (t) => t.userId.equals(userId),
          orderBy: (t) => t.position,
        );

        // Assert
        expect(orderedControls.length, 3);
        expect(orderedControls[0].name, 'First');
        expect(orderedControls[1].name, 'Second');
        expect(orderedControls[2].name, 'Third');
      });
    });
  });
}
