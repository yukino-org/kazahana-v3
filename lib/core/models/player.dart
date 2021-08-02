import 'package:flutter/widgets.dart' show Widget, mustCallSuper;
import '../../plugins/helpers/eventer.dart';

enum PlayerEvents {
  load,
  durationUpdate,
  play,
  pause,
  seek,
  volume,
  end,
}

class PlayerSource {
  final String url;
  final Map<String, String> headers;

  PlayerSource({
    required this.url,
    this.headers = const {},
  });
}

abstract class Player extends Eventer<PlayerEvents> {
  final PlayerSource source;
  bool ready = false;

  Player(this.source);

  Future<void> initialize();
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setVolume(int volume);
  Widget getWidget();

  @override
  @mustCallSuper
  Future<void> destroy() async {
    super.destroy();
  }

  bool get isPlaying;
  Duration? get duration;
  Duration? get totalDuration;
  int get volume;

  static const minVolume = 0;
  static const maxVolume = 100;

  static const minIntroLength = 30;
  static const maxIntroLength = 180;
  static const defaultIntroLength = 85;

  static const minSeekLength = 0;
  static const maxSeekLength = 60;
  static const defaultSeekLength = 15;
}
