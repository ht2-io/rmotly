import 'package:hive_flutter/hive_flutter.dart';
import 'package:rmotly_client/rmotly_client.dart';

/// Hive type adapter for Action model
class ActionAdapter extends TypeAdapter<Action> {
  @override
  final int typeId = 1;

  @override
  Action read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return Action.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, Action obj) {
    writer.writeMap(obj.toJson());
  }
}
