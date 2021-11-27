import 'package:flutter/services.dart';
import '../../../../../helpers/keyboard.dart';
import '../_utils.dart';

class MangaKeyboardShortcuts {
  MangaKeyboardShortcuts({
    required final this.fullscreen,
    required final this.exit,
    required final this.previousPage,
    required final this.nextPage,
    required final this.previousChapter,
    required final this.nextChapter,
  });

  factory MangaKeyboardShortcuts.fromJson(final Map<dynamic, dynamic> json) =>
      MangaKeyboardShortcuts.fromPartial(
        fullscreen: pickKeySetFromJson(json, 'fullscreen'),
        exit: pickKeySetFromJson(json, 'exit'),
        previousPage: pickKeySetFromJson(json, 'previousPage'),
        nextPage: pickKeySetFromJson(json, 'nextPage'),
        previousChapter: pickKeySetFromJson(json, 'previousChapter'),
        nextChapter: pickKeySetFromJson(json, 'nextChapter'),
      );

  factory MangaKeyboardShortcuts.fromPartial({
    final Set<LogicalKeyboardKey>? fullscreen,
    final Set<LogicalKeyboardKey>? exit,
    final Set<LogicalKeyboardKey>? previousPage,
    final Set<LogicalKeyboardKey>? nextPage,
    final Set<LogicalKeyboardKey>? previousChapter,
    final Set<LogicalKeyboardKey>? nextChapter,
  }) =>
      MangaKeyboardShortcuts(
        fullscreen: pickNonNullKeySet(fullscreen, _fullscreen),
        exit: pickNonNullKeySet(exit, _exit),
        previousPage: pickNonNullKeySet(previousPage, _previousPage),
        nextPage: pickNonNullKeySet(nextPage, _nextPage),
        previousChapter: pickNonNullKeySet(previousChapter, _previousChapter),
        nextChapter: pickNonNullKeySet(nextChapter, _nextChapter),
      );

  Set<LogicalKeyboardKey> fullscreen;
  Set<LogicalKeyboardKey> exit;
  Set<LogicalKeyboardKey> previousPage;
  Set<LogicalKeyboardKey> nextPage;
  Set<LogicalKeyboardKey> previousChapter;
  Set<LogicalKeyboardKey> nextChapter;

  Map<dynamic, dynamic> toJson() => <String, List<String>>{
        'fullscreen': KeyboardHandler.toLabels(fullscreen),
        'exit': KeyboardHandler.toLabels(exit),
        'previousPage': KeyboardHandler.toLabels(previousPage),
        'nextPage': KeyboardHandler.toLabels(nextPage),
        'previousChapter': KeyboardHandler.toLabels(previousChapter),
        'nextChapter': KeyboardHandler.toLabels(nextChapter),
      };

  static final Set<LogicalKeyboardKey> _fullscreen = <LogicalKeyboardKey>{
    LogicalKeyboardKey.keyF,
  };

  static final Set<LogicalKeyboardKey> _exit = <LogicalKeyboardKey>{
    LogicalKeyboardKey.escape,
  };

  static final Set<LogicalKeyboardKey> _previousPage = <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowLeft,
  };

  static final Set<LogicalKeyboardKey> _nextPage = <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowRight,
  };

  static final Set<LogicalKeyboardKey> _previousChapter = <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.arrowLeft,
  };

  static final Set<LogicalKeyboardKey> _nextChapter = <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.arrowRight,
  };
}
