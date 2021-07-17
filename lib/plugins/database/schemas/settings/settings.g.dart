// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsSchemaAdapter extends TypeAdapter<SettingsSchema> {
  @override
  final int typeId = 1;

  @override
  SettingsSchema read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsSchema()
      ..useSystemPreferredTheme = fields[1] == null ? true : fields[1] as bool
      ..useDarkMode = fields[2] == null ? false : fields[2] as bool
      ..fullscreenVideoPlayer = fields[3] == null ? false : fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, SettingsSchema obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.useSystemPreferredTheme)
      ..writeByte(2)
      ..write(obj.useDarkMode)
      ..writeByte(3)
      ..write(obj.fullscreenVideoPlayer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsSchemaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
