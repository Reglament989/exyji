// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EncryptedBlockAdapter extends TypeAdapter<EncryptedBlock> {
  @override
  final int typeId = 4;

  @override
  EncryptedBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EncryptedBlock()
      ..crypto = fields[0] as String
      ..signature = fields[1] as String
      ..hash = fields[2] as String
      ..prevHash = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, EncryptedBlock obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.crypto)
      ..writeByte(1)
      ..write(obj.signature)
      ..writeByte(2)
      ..write(obj.hash)
      ..writeByte(3)
      ..write(obj.prevHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptedBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessagesModelAdapter extends TypeAdapter<MessagesModel> {
  @override
  final int typeId = 3;

  @override
  MessagesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessagesModel()
      ..uid = fields[0] as String
      ..createdAt = fields[1] as DateTime
      ..block = fields[2] as EncryptedBlock
      ..isDecrypted = fields[3] as bool
      ..messageData = fields[4] as String
      ..senderUid = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, MessagesModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.block)
      ..writeByte(3)
      ..write(obj.isDecrypted)
      ..writeByte(4)
      ..write(obj.messageData)
      ..writeByte(5)
      ..write(obj.senderUid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
