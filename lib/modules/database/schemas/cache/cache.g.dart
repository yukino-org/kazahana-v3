// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheSchemaAdapter extends TypeAdapter<CacheSchema> {
  @override
  final int typeId = 8;

  @override
  CacheSchema read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheSchema(
      fields[1] as dynamic,
      fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CacheSchema obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.cachedTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheSchemaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
