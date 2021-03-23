// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomAdapter extends TypeAdapter<Room> {
  @override
  final int typeId = 3;

  @override
  Room read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Room()
      ..secretKey = (fields[0] as List)?.cast<String>()
      ..secretKeyVersion = fields[1] as int
      ..pathBackground = fields[2] as String
      ..messages = (fields[3] as List)?.cast<dynamic>()
      ..existsMessages = (fields[4] as List)?.cast<dynamic>();
  }

  @override
  void write(BinaryWriter writer, Room obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.secretKey)
      ..writeByte(1)
      ..write(obj.secretKeyVersion)
      ..writeByte(2)
      ..write(obj.pathBackground)
      ..writeByte(3)
      ..write(obj.messages)
      ..writeByte(4)
      ..write(obj.existsMessages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
