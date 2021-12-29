import 'package:flutter/services.dart';
import '../../utils/keyboard_shortcuts.dart';

enum MangaKeyboardShortcutsKeys {
  fullscreen,
  exit,
  previousPage,
  nextPage,
  previousChapter,
  nextChapter,
}

final Map<MangaKeyboardShortcutsKeys, Set<LogicalKeyboardKey>>
    mangaKeyboardShortcutsDefaults =
    <MangaKeyboardShortcutsKeys, Set<LogicalKeyboardKey>>{
  MangaKeyboardShortcutsKeys.fullscreen: <LogicalKeyboardKey>{
    LogicalKeyboardKey.keyF,
  },
  MangaKeyboardShortcutsKeys.exit: <LogicalKeyboardKey>{
    LogicalKeyboardKey.escape,
  },
  MangaKeyboardShortcutsKeys.previousPage: <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowLeft,
  },
  MangaKeyboardShortcutsKeys.nextPage: <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowRight,
  },
  MangaKeyboardShortcutsKeys.previousChapter: <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.arrowLeft,
  },
  MangaKeyboardShortcutsKeys.nextChapter: <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.arrowRight,
  },
};

class MangaKeyboardShortcuts {
  const MangaKeyboardShortcuts(this.values);

  factory MangaKeyboardShortcuts.fromJson(final Map<dynamic, dynamic> json) =>
      MangaKeyboardShortcuts(
        KeyboardShortcutsSchemaUtils.fromJson(
          enumValues: MangaKeyboardShortcutsKeys.values,
          json: json.cast<String, dynamic>(),
        ),
      );

  final Map<MangaKeyboardShortcutsKeys, Set<LogicalKeyboardKey>?> values;

  Set<LogicalKeyboardKey> get(final MangaKeyboardShortcutsKeys key) =>
      KeyboardShortcutsSchemaUtils.getter(
        key: key,
        values: values,
        defaults: mangaKeyboardShortcutsDefaults,
      );

  void set(
    final MangaKeyboardShortcutsKeys key,
    final Set<LogicalKeyboardKey>? value,
  ) =>
      KeyboardShortcutsSchemaUtils.setter(
        key: key,
        value: value,
        values: values,
      );

  Map<dynamic, dynamic> toJson() => KeyboardShortcutsSchemaUtils.toJson(values);
}
