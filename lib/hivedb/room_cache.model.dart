import 'package:hive/hive.dart';

part 'room_cache.model.g.dart';

@HiveType(typeId: 5)
class RoomCache extends HiveObject {
  @HiveField(0, defaultValue: true)
  String lastInput = "";
}
