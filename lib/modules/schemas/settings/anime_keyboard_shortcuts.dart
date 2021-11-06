import 'package:flutter/services.dart';
import '../../helpers/keyboard.dart';

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
        fullscreen: json['fullscreen'] != null
            ? KeyboardHandler.fromLabels(
                (json['fullscreen'] as List<dynamic>).cast<String>(),
              )
            : null,
        playPause: json['playPause'] != null
            ? KeyboardHandler.fromLabels(
                (json['playPause'] as List<dynamic>).cast<String>(),
              )
            : null,
        seekBackward: json['seekBackward'] != null
            ? KeyboardHandler.fromLabels(
                (json['seekBackward'] as List<dynamic>).cast<String>(),
              )
            : null,
        seekForward: json['seekForward'] != null
            ? KeyboardHandler.fromLabels(
                (json['seekForward'] as List<dynamic>).cast<String>(),
              )
            : null,
        skipIntro: json['skipIntro'] != null
            ? KeyboardHandler.fromLabels(
                (json['skipIntro'] as List<dynamic>).cast<String>(),
              )
            : null,
        exit: json['exit'] != null
            ? KeyboardHandler.fromLabels(
                (json['exit'] as List<dynamic>).cast<String>(),
              )
            : null,
        previousEpisode: json['previousEpisode'] != null
            ? KeyboardHandler.fromLabels(
                (json['previousEpisode'] as List<dynamic>).cast<String>(),
              )
            : null,
        nextEpisode: json['nextEpisode'] != null
            ? KeyboardHandler.fromLabels(
                (json['nextEpisode'] as List<dynamic>).cast<String>(),
              )
            : null,
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
        fullscreen: fullscreen?.isNotEmpty ?? false ? fullscreen! : _fullscreen,
        playPause: playPause?.isNotEmpty ?? false ? playPause! : _playPause,
        seekBackward:
            seekBackward?.isNotEmpty ?? false ? seekBackward! : _seekBackward,
        seekForward:
            seekForward?.isNotEmpty ?? false ? seekForward! : _seekForward,
        skipIntro: skipIntro?.isNotEmpty ?? false ? skipIntro! : _skipIntro,
        exit: exit?.isNotEmpty ?? false ? exit! : _exit,
        previousEpisode: previousEpisode?.isNotEmpty ?? false
            ? previousEpisode!
            : _previousEpisode,
        nextEpisode:
            nextEpisode?.isNotEmpty ?? false ? nextEpisode! : _nextEpisode,
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
        'previous': KeyboardHandler.toLabels(previousEpisode),
        'next': KeyboardHandler.toLabels(nextEpisode),
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
