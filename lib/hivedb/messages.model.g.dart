// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TypeMessageAdapter extends TypeAdapter<TypeMessage> {
  @override
  final int typeId = 7;

  @override
  TypeMessage read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TypeMessage.photo;
      case 1:
        return TypeMessage.text;
      case 2:
        return TypeMessage.file;
      default:
        return TypeMessage.photo;
    }
  }

  @override
  void write(BinaryWriter writer, TypeMessage obj) {
    switch (obj) {
      case TypeMessage.photo:
        writer.writeByte(0);
        break;
      case TypeMessage.text:
        writer.writeByte(1);
        break;
      case TypeMessage.file:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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

class ReplyModelAdapter extends TypeAdapter<ReplyModel> {
  @override
  final int typeId = 6;

  @override
  ReplyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReplyModel()
      ..body = fields[0] as String
      ..from = fields[1] as String
      ..fromUid = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, ReplyModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.body)
      ..writeByte(1)
      ..write(obj.from)
      ..writeByte(2)
      ..write(obj.fromUid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReplyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MediaMessageAdapter extends TypeAdapter<MediaMessage> {
  @override
  final int typeId = 8;

  @override
  MediaMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaMessage()..data = fields[0] as Uint8List?;
  }

  @override
  void write(BinaryWriter writer, MediaMessage obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaMessageAdapter &&
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
      ..replyUid = fields[3] as String?
      ..isDecrypted = fields[4] as bool
      ..messageData = fields[5] as String
      ..reply = fields[6] as ReplyModel?
      ..senderUid = fields[7] as String
      ..type = fields[8] as TypeMessage
      ..media = fields[9] as MediaMessage?;
  }

  @override
  void write(BinaryWriter writer, MessagesModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.block)
      ..writeByte(3)
      ..write(obj.replyUid)
      ..writeByte(4)
      ..write(obj.isDecrypted)
      ..writeByte(5)
      ..write(obj.messageData)
      ..writeByte(6)
      ..write(obj.reply)
      ..writeByte(7)
      ..write(obj.senderUid)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.media);
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
