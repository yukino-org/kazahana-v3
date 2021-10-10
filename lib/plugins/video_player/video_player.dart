import './better_player.dart';
import './dart_vlc.dart';
import '../../core/models/player.dart';

abstract class VideoPlayer {
  static Future<void> initialize() async {
    if (DartVlc.isSupported()) {
      await DartVlc.initialize();
    }
  }

  static Player createPlayer(final PlayerSource source) {
    if (BetterPlayer.isSupported()) {
      return BetterPlayer(source);
    }

    if (DartVlc.isSupported()) {
      return DartVlc(source);
    }

    throw UnimplementedError();
  }
}
