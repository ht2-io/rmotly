import 'package:hive_flutter/hive_flutter.dart';
import 'package:rmotly_client/rmotly_client.dart';

/// Hive type adapter for NotificationTopic model
class NotificationTopicAdapter extends TypeAdapter<NotificationTopic> {
  @override
  final int typeId = 2;

  @override
  NotificationTopic read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return NotificationTopic.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, NotificationTopic obj) {
    writer.writeMap(obj.toJson());
  }
}
