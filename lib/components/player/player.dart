import './better_player.dart' as better_player;
import './dart_vlc.dart' as dart_vlc;
import '../../core/models/player.dart';

Future<void> initialize() async {
  if (dart_vlc.isSupported()) {
    await dart_vlc.initialize();
  }
}

Player createPlayer(final PlayerSource source) {
  if (better_player.isSupported()) {
    return better_player.VideoPlayer(source);
  }

  if (dart_vlc.isSupported()) {
    return dart_vlc.VideoPlayer(source);
  }

  throw UnimplementedError();
}
