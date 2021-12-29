import 'package:flutter/services.dart';
import '../../utils/keyboard_shortcuts.dart';

enum AnimeKeyboardShortcutsKeys {
  fullscreen,
  playPause,
  seekBackward,
  seekForward,
  skipIntro,
  exit,
  previousEpisode,
  nextEpisode,
}

final Map<AnimeKeyboardShortcutsKeys, Set<LogicalKeyboardKey>>
    animeKeyboardShortcutsDefaults =
    <AnimeKeyboardShortcutsKeys, Set<LogicalKeyboardKey>>{
  AnimeKeyboardShortcutsKeys.fullscreen: <LogicalKeyboardKey>{
    LogicalKeyboardKey.keyF,
  },
  AnimeKeyboardShortcutsKeys.playPause: <LogicalKeyboardKey>{
    LogicalKeyboardKey.space,
  },
  AnimeKeyboardShortcutsKeys.seekBackward: <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowLeft,
  },
  AnimeKeyboardShortcutsKeys.seekForward: <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowRight,
  },
  AnimeKeyboardShortcutsKeys.skipIntro: <LogicalKeyboardKey>{
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.arrowRight,
  },
  AnimeKeyboardShortcutsKeys.exit: <LogicalKeyboardKey>{
    LogicalKeyboardKey.escape,
  },
  AnimeKeyboardShortcutsKeys.previousEpisode: <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.arrowLeft,
  },
  AnimeKeyboardShortcutsKeys.nextEpisode: <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.arrowRight,
  },
};

class AnimeKeyboardShortcuts {
  const AnimeKeyboardShortcuts(this.values);

  factory AnimeKeyboardShortcuts.fromJson(final Map<dynamic, dynamic> json) =>
      AnimeKeyboardShortcuts(
        KeyboardShortcutsSchemaUtils.fromJson(
          enumValues: AnimeKeyboardShortcutsKeys.values,
          json: json.cast<String, dynamic>(),
        ),
      );

  final Map<AnimeKeyboardShortcutsKeys, Set<LogicalKeyboardKey>?> values;

  Set<LogicalKeyboardKey> get(final AnimeKeyboardShortcutsKeys key) =>
      KeyboardShortcutsSchemaUtils.getter(
        key: key,
        values: values,
        defaults: animeKeyboardShortcutsDefaults,
      );

  void set(
    final AnimeKeyboardShortcutsKeys key,
    final Set<LogicalKeyboardKey>? value,
  ) =>
      KeyboardShortcutsSchemaUtils.setter(
        key: key,
        value: value,
        values: values,
      );

  Map<dynamic, dynamic> toJson() => KeyboardShortcutsSchemaUtils.toJson(values);
}
