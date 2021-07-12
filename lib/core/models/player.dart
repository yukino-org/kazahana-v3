import 'package:flutter/widgets.dart' show Widget;

class PlayerSource {
  final String url;
  final Map<String, String> headers;

  PlayerSource({required this.url, this.headers = const {}});
}

abstract class Player {
  final PlayerSource source;
  bool ready = false;

  Player(this.source);

  Future<void> initialize();
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Widget getWidget();

  bool get isPlaying;
}
