import 'package:hive/hive.dart';

part 'room.g.dart';

@HiveType(typeId: 3)
class Room extends HiveObject {
  @HiveField(0)
  List<String> secretKey;

  @HiveField(1)
  int secretKeyVersion;
}
