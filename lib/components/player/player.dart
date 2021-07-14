import 'dart:io' show Platform;
import '../../../core/models/player.dart';
import './better_player.dart' as better_player;

Player createPlayer(PlayerSource source) {
  if (Platform.isAndroid || Platform.isIOS) {
    return better_player.VideoPlayer(source);
  }

  throw UnimplementedError();
}
