// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomTypeAdapter extends TypeAdapter<RoomType> {
  @override
  final int typeId = 2;

  @override
  RoomType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RoomType.contact;
      case 1:
        return RoomType.channel;
      case 2:
        return RoomType.bot;
      case 3:
        return RoomType.any;
      default:
        return RoomType.contact;
    }
  }

  @override
  void write(BinaryWriter writer, RoomType obj) {
    switch (obj) {
      case RoomType.contact:
        writer.writeByte(0);
        break;
      case RoomType.channel:
        writer.writeByte(1);
        break;
      case RoomType.bot:
        writer.writeByte(2);
        break;
      case RoomType.any:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoomModelAdapter extends TypeAdapter<RoomModel> {
  @override
  final int typeId = 1;

  @override
  RoomModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomModel()
      ..uid = fields[0] as String
      ..title = fields[1] as String
      ..messages = (fields[2] as List).cast<dynamic>()
      ..members = (fields[3] as List).cast<dynamic>()
      ..type = fields[4] as RoomType
      ..photoURL = fields[5] as String
      ..lastMessage = fields[6] as String
      ..lastUpdate = fields[7] as DateTime;
  }

  @override
  void write(BinaryWriter writer, RoomModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.members)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.photoURL)
      ..writeByte(6)
      ..write(obj.lastMessage)
      ..writeByte(7)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
