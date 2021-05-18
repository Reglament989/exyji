import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'room.model.g.dart';

@HiveType(typeId: 2)
enum RoomType {
  @HiveField(0)
  contact,
  @HiveField(1)
  channel,
  @HiveField(2)
  bot,
  @HiveField(3)
  any
}

@HiveType(typeId: 1)
class RoomModel extends HiveObject {
  @HiveField(0)
  String uid = Uuid().v4();

  @HiveField(1)
  String title = "N/A";

  @HiveField(2)
  List messages = List.of([]);

  @HiveField(3)
  List members = List.of([]);

  @HiveField(4)
  RoomType type = RoomType.contact;

  @HiveField(5)
  String photoURL = "https://source.unsplash.com/random/56x56";

  @HiveField(6)
  String lastMessage = "New room";

  @HiveField(7)
  DateTime lastUpdate = DateTime.now();
}
