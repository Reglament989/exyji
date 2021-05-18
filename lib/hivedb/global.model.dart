import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'global.model.g.dart';

@HiveType(typeId: 9)
class Global extends HiveObject {
  @HiveField(0)
  Uint8List? avatar;
}
