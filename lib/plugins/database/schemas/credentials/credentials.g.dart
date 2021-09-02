// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CredentialsSchemaAdapter extends TypeAdapter<CredentialsSchema> {
  @override
  final int typeId = 6;

  @override
  CredentialsSchema read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CredentialsSchema(
      anilist: (fields[1] as Map?)?.cast<dynamic, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CredentialsSchema obj) {
    writer
      ..writeByte(1)
      ..writeByte(1)
      ..write(obj.anilist);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialsSchemaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
