import 'package:hive_flutter/hive_flutter.dart';
import 'package:rmotly_client/rmotly_client.dart';

/// Hive type adapter for Control model
class ControlAdapter extends TypeAdapter<Control> {
  @override
  final int typeId = 0;

  @override
  Control read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return Control.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, Control obj) {
    writer.writeMap(obj.toJson());
  }
}
