import 'dart:io' show Platform;
import './better_player.dart' as better_player;
import '../../../core/models/player.dart';

Player createPlayer(final PlayerSource source) {
  if (Platform.isAndroid || Platform.isIOS) {
    return better_player.VideoPlayer(source);
  }

  throw UnimplementedError();
}
