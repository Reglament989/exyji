// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_cache.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomCacheAdapter extends TypeAdapter<RoomCache> {
  @override
  final int typeId = 5;

  @override
  RoomCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomCache()
      ..lastInput = fields[0] as String
      ..replyBodyMessage = fields[1] as String?
      ..replyMessageId = fields[2] as String?
      ..replyFrom = fields[3] as String?;
  }

  @override
  void write(BinaryWriter writer, RoomCache obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.lastInput)
      ..writeByte(1)
      ..write(obj.replyBodyMessage)
      ..writeByte(2)
      ..write(obj.replyMessageId)
      ..writeByte(3)
      ..write(obj.replyFrom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
