// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaDirectionsAdapter extends TypeAdapter<MangaDirections> {
  @override
  final int typeId = 2;

  @override
  MangaDirections read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MangaDirections.leftToRight;
      case 1:
        return MangaDirections.rightToLeft;
      default:
        return MangaDirections.leftToRight;
    }
  }

  @override
  void write(BinaryWriter writer, MangaDirections obj) {
    switch (obj) {
      case MangaDirections.leftToRight:
        writer.writeByte(0);
        break;
      case MangaDirections.rightToLeft:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaDirectionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MangaSwipeDirectionsAdapter extends TypeAdapter<MangaSwipeDirections> {
  @override
  final int typeId = 3;

  @override
  MangaSwipeDirections read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MangaSwipeDirections.horizontal;
      case 1:
        return MangaSwipeDirections.vertical;
      default:
        return MangaSwipeDirections.horizontal;
    }
  }

  @override
  void write(BinaryWriter writer, MangaSwipeDirections obj) {
    switch (obj) {
      case MangaSwipeDirections.horizontal:
        writer.writeByte(0);
        break;
      case MangaSwipeDirections.vertical:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaSwipeDirectionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      ..fullscreenVideoPlayer = fields[3] == null ? false : fields[3] as bool
      ..locale = fields[4] as String?
      ..mangaReaderDirection = fields[5] == null
          ? MangaDirections.leftToRight
          : fields[5] as MangaDirections
      ..mangaReaderSwipeDirection = fields[6] == null
          ? MangaSwipeDirections.horizontal
          : fields[6] as MangaSwipeDirections;
  }

  @override
  void write(BinaryWriter writer, SettingsSchema obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.useSystemPreferredTheme)
      ..writeByte(2)
      ..write(obj.useDarkMode)
      ..writeByte(3)
      ..write(obj.fullscreenVideoPlayer)
      ..writeByte(4)
      ..write(obj.locale)
      ..writeByte(5)
      ..write(obj.mangaReaderDirection)
      ..writeByte(6)
      ..write(obj.mangaReaderSwipeDirection);
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
