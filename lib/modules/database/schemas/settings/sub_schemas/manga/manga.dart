import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import './keyboard_shortcuts.dart';

export './keyboard_shortcuts.dart';

part 'manga.g.dart';

enum MangaReaderDirection {
  leftToRight,
  rightToLeft,
}

enum MangaSwipeDirection {
  horizontal,
  vertical,
}

enum MangaReaderMode {
  page,
  list,
}

enum MangaListModeSizing {
  fitWidth,
  fitHeight,
  custom,
}

abstract class MangaSettingsSchemaDefaults {
  static const bool fullscreen = true;
  static const bool doubleClickSwitchChapter = true;
  static const int listModeCustomWidth = 70;

  static const MangaReaderDirection readerDirection =
      MangaReaderDirection.leftToRight;

  static const MangaSwipeDirection swipeDirection =
      MangaSwipeDirection.horizontal;

  static const MangaReaderMode readerMode = MangaReaderMode.page;

  static const MangaListModeSizing listModeSizing =
      MangaListModeSizing.fitHeight;
}

@JsonSerializable()
class MangaSettingsSchema {
  MangaSettingsSchema({
    final this.doubleClickSwitchChapter =
        MangaSettingsSchemaDefaults.doubleClickSwitchChapter,
    final this.fullscreen = MangaSettingsSchemaDefaults.fullscreen,
    final this.listModeCustomWidth =
        MangaSettingsSchemaDefaults.listModeCustomWidth,
    final this.listModeSizing = MangaSettingsSchemaDefaults.listModeSizing,
    final this.readerDirection = MangaSettingsSchemaDefaults.readerDirection,
    final this.swipeDirection = MangaSettingsSchemaDefaults.swipeDirection,
    final this.readerMode = MangaSettingsSchemaDefaults.readerMode,
    final this.shortcuts = const MangaKeyboardShortcuts(
      <MangaKeyboardShortcutsKeys, Set<LogicalKeyboardKey>?>{},
    ),
  });

  factory MangaSettingsSchema.fromJson(final Map<dynamic, dynamic> json) =>
      _$MangaSettingsSchemaFromJson(json.cast<String, dynamic>());

  int id = 0;

  bool doubleClickSwitchChapter;
  bool fullscreen;
  MangaReaderDirection readerDirection;
  MangaSwipeDirection swipeDirection;
  MangaReaderMode readerMode;
  MangaListModeSizing listModeSizing;
  int listModeCustomWidth;
  final MangaKeyboardShortcuts shortcuts;

  Map<dynamic, dynamic> toJson() => _$MangaSettingsSchemaToJson(this);
}
