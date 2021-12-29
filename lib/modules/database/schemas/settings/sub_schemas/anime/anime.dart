import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import './keyboard_shortcuts.dart';
import '../../../../../video_player/video_player.dart';

export './keyboard_shortcuts.dart';

part 'anime.g.dart';

abstract class AnimeSettingsSchemaDefaults {
  static const int introDuration = VideoPlayer.defaultIntroLength;
  static const int seekDuration = VideoPlayer.defaultSeekLength;
  static const bool autoNext = false;
  static const bool autoPlay = false;
  static const bool fullscreen = true;
  static const int syncThreshold = 80;
  static const bool landscape = true;
}

@JsonSerializable()
class AnimeSettingsSchema {
  AnimeSettingsSchema({
    final this.introDuration = AnimeSettingsSchemaDefaults.introDuration,
    final this.seekDuration = AnimeSettingsSchemaDefaults.seekDuration,
    final this.autoNext = AnimeSettingsSchemaDefaults.autoNext,
    final this.autoPlay = AnimeSettingsSchemaDefaults.autoPlay,
    final this.fullscreen = AnimeSettingsSchemaDefaults.fullscreen,
    final this.syncThreshold = AnimeSettingsSchemaDefaults.syncThreshold,
    final this.landscape = AnimeSettingsSchemaDefaults.landscape,
    final this.shortcuts = const AnimeKeyboardShortcuts(
      <AnimeKeyboardShortcutsKeys, Set<LogicalKeyboardKey>?>{},
    ),
  });

  factory AnimeSettingsSchema.fromJson(final Map<dynamic, dynamic> json) =>
      _$AnimeSettingsSchemaFromJson(json.cast<String, dynamic>());

  int id = 0;

  int introDuration;
  int seekDuration;
  bool autoNext;
  bool autoPlay;
  bool fullscreen;
  int syncThreshold;
  bool landscape;
  final AnimeKeyboardShortcuts shortcuts;

  Map<dynamic, dynamic> toJson() => _$AnimeSettingsSchemaToJson(this);
}
