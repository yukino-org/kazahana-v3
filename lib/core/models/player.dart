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
  speed,
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
  Future<void> setSpeed(double speed);
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
  double get speed;

  static const minVolume = 0;
  static const maxVolume = 100;

  static const minIntroLength = 30;
  static const maxIntroLength = 180;
  static const defaultIntroLength = 85;

  static const minSeekLength = 0;
  static const maxSeekLength = 60;
  static const defaultSeekLength = 15;

  static const allowedSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];
  static const defaultSpeed = 1.0;
}
