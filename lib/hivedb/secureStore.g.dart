// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secureStore.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SecureStoreAdapter extends TypeAdapter<SecureStore> {
  @override
  final int typeId = 2;

  @override
  SecureStore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SecureStore()
      ..publicKeyRsa = fields[0] as String
      ..privateKeyRsa = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, SecureStore obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.publicKeyRsa)
      ..writeByte(1)
      ..write(obj.privateKeyRsa);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecureStoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
