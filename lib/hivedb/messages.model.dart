import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'messages.model.g.dart';

@HiveType(typeId: 4)
class EncryptedBlock extends HiveObject {
  @HiveField(0)
  late String crypto;
  @HiveField(1)
  late String signature;
  @HiveField(2)
  late String hash;
  @HiveField(3)
  late String prevHash;
}

@HiveType(typeId: 3)
class MessagesModel extends HiveObject {
  @HiveField(0, defaultValue: true)
  String uid = Uuid().v4();
  @HiveField(1, defaultValue: true)
  DateTime createdAt = DateTime.now();
  @HiveField(2)
  late EncryptedBlock block;
  @HiveField(3, defaultValue: true)
  bool isDecrypted = false;
  @HiveField(4, defaultValue: true)
  String messageData = "";
  @HiveField(5)
  late String senderUid;
}
