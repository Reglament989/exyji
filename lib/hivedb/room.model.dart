import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'room.model.g.dart';

@HiveType(typeId: 2)
enum RoomType {
  @HiveField(0, defaultValue: true)
  contact,
  @HiveField(1, defaultValue: true)
  channel,
  @HiveField(2, defaultValue: true)
  bot,
  @HiveField(3, defaultValue: true)
  any
}

@HiveType(typeId: 1)
class RoomModel extends HiveObject {
  @HiveField(0, defaultValue: true)
  String uid = Uuid().v4();

  @HiveField(1, defaultValue: true)
  String title = "N/A";

  @HiveField(2, defaultValue: true)
  List messages = List.of([]);

  @HiveField(3, defaultValue: true)
  List members = List.of([]);

  @HiveField(4, defaultValue: true)
  RoomType type = RoomType.contact;

  @HiveField(5, defaultValue: true)
  String photoURL = "https://source.unsplash.com/random/56x56";

  @HiveField(6, defaultValue: true)
  String lastMessage = "New room";

  // @HiveField(7, defaultValue: true)
  // DateTime
}
