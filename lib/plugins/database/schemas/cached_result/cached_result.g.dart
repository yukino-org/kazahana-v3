// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedResultSchemaAdapter extends TypeAdapter<CachedResultSchema> {
  @override
  final int typeId = 5;

  @override
  CachedResultSchema read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedResultSchema(
      info: (fields[1] as Map).cast<dynamic, dynamic>(),
      cachedTime: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedResultSchema obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.info)
      ..writeByte(2)
      ..write(obj.cachedTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedResultSchemaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
