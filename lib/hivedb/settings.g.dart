// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GlobalSettingsAdapter extends TypeAdapter<GlobalSettings> {
  @override
  final int typeId = 1;

  @override
  GlobalSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GlobalSettings()
      ..primaryColor = fields[0] as Color
      ..accentColor = fields[1] as Color;
  }

  @override
  void write(BinaryWriter writer, GlobalSettings obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.primaryColor)
      ..writeByte(1)
      ..write(obj.accentColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobalSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
