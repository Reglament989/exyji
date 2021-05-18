// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GlobalAdapter extends TypeAdapter<Global> {
  @override
  final int typeId = 9;

  @override
  Global read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Global()..avatar = fields[0] as Uint8List?;
  }

  @override
  void write(BinaryWriter writer, Global obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.avatar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
