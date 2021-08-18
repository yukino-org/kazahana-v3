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
  PlayerSource({
    required final this.url,
    final this.headers = const <String, String>{},
  });

  final String url;
  final Map<String, String> headers;
}

abstract class Player extends Eventer<PlayerEvents> {
  Player(this.source);

  final PlayerSource source;
  bool ready = false;

  Future<void> load();
  Future<void> play();
  Future<void> pause();
  Future<void> seek(final Duration position);
  Future<void> setVolume(final int volume);
  Future<void> setSpeed(final double speed);
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

  static const int minVolume = 0;
  static const int maxVolume = 100;

  static const int minIntroLength = 30;
  static const int maxIntroLength = 180;
  static const int defaultIntroLength = 85;

  static const int minSeekLength = 0;
  static const int maxSeekLength = 60;
  static const int defaultSeekLength = 15;

  static const List<double> allowedSpeeds = <double>[
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];
  static const double defaultSpeed = 1.0;
}
