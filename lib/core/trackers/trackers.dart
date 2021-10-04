import './anilist/anilist.dart';
import './myanimelist/myanimelist.dart';

abstract class Trackers {
  static Future<void> initialize() async {
    await AnilistManager.initialize();
    await MyAnimeListManager.initialize();
  }
}
