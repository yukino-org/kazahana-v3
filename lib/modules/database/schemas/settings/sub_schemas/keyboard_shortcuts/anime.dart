import 'package:flutter/services.dart';
import '../../../../../helpers/keyboard.dart';
import '../_utils.dart';

class AnimeKeyboardShortcuts {
  AnimeKeyboardShortcuts({
    required final this.fullscreen,
    required final this.playPause,
    required final this.seekBackward,
    required final this.seekForward,
    required final this.skipIntro,
    required final this.exit,
    required final this.previousEpisode,
    required final this.nextEpisode,
  });

  factory AnimeKeyboardShortcuts.fromJson(final Map<dynamic, dynamic> json) =>
      AnimeKeyboardShortcuts.fromPartial(
        fullscreen: pickKeySetFromJson(json, 'fullscreen'),
        playPause: pickKeySetFromJson(json, 'playPause'),
        seekBackward: pickKeySetFromJson(json, 'seekBackward'),
        seekForward: pickKeySetFromJson(json, 'seekForward'),
        skipIntro: pickKeySetFromJson(json, 'skipIntro'),
        exit: pickKeySetFromJson(json, 'exit'),
        previousEpisode: pickKeySetFromJson(json, 'previousEpisode'),
        nextEpisode: pickKeySetFromJson(json, 'nextEpisode'),
      );

  factory AnimeKeyboardShortcuts.fromPartial({
    final Set<LogicalKeyboardKey>? fullscreen,
    final Set<LogicalKeyboardKey>? playPause,
    final Set<LogicalKeyboardKey>? seekBackward,
    final Set<LogicalKeyboardKey>? seekForward,
    final Set<LogicalKeyboardKey>? skipIntro,
    final Set<LogicalKeyboardKey>? exit,
    final Set<LogicalKeyboardKey>? previousEpisode,
    final Set<LogicalKeyboardKey>? nextEpisode,
  }) =>
      AnimeKeyboardShortcuts(
        fullscreen: pickNonNullKeySet(fullscreen, _fullscreen),
        playPause: pickNonNullKeySet(playPause, _playPause),
        seekBackward: pickNonNullKeySet(seekBackward, _seekBackward),
        seekForward: pickNonNullKeySet(seekForward, _seekForward),
        skipIntro: pickNonNullKeySet(skipIntro, _skipIntro),
        exit: pickNonNullKeySet(exit, _exit),
        previousEpisode: pickNonNullKeySet(previousEpisode, _previousEpisode),
        nextEpisode: pickNonNullKeySet(nextEpisode, _nextEpisode),
      );

  Set<LogicalKeyboardKey> fullscreen;
  Set<LogicalKeyboardKey> playPause;
  Set<LogicalKeyboardKey> seekBackward;
  Set<LogicalKeyboardKey> seekForward;
  Set<LogicalKeyboardKey> skipIntro;
  Set<LogicalKeyboardKey> exit;
  Set<LogicalKeyboardKey> previousEpisode;
  Set<LogicalKeyboardKey> nextEpisode;

  Map<dynamic, dynamic> toJson() => <String, List<String>>{
        'fullscreen': KeyboardHandler.toLabels(fullscreen),
        'playPause': KeyboardHandler.toLabels(playPause),
        'seekBackward': KeyboardHandler.toLabels(seekBackward),
        'seekForward': KeyboardHandler.toLabels(seekForward),
        'skipIntro': KeyboardHandler.toLabels(skipIntro),
        'exit': KeyboardHandler.toLabels(exit),
        'previousEpisode': KeyboardHandler.toLabels(previousEpisode),
        'nextEpisode': KeyboardHandler.toLabels(nextEpisode),
      };

  static final Set<LogicalKeyboardKey> _fullscreen = <LogicalKeyboardKey>{
    LogicalKeyboardKey.keyF,
  };

  static final Set<LogicalKeyboardKey> _playPause = <LogicalKeyboardKey>{
    LogicalKeyboardKey.space,
  };

  static final Set<LogicalKeyboardKey> _seekBackward = <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowLeft,
  };

  static final Set<LogicalKeyboardKey> _seekForward = <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowRight,
  };

  static final Set<LogicalKeyboardKey> _skipIntro = <LogicalKeyboardKey>{
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.arrowRight,
  };

  static final Set<LogicalKeyboardKey> _exit = <LogicalKeyboardKey>{
    LogicalKeyboardKey.escape,
  };

  static final Set<LogicalKeyboardKey> _previousEpisode = <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.arrowLeft,
  };

  static final Set<LogicalKeyboardKey> _nextEpisode = <LogicalKeyboardKey>{
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.arrowRight,
  };
}
