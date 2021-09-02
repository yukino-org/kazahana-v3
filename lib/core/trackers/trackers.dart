import './anilist/anilist.dart';

abstract class Trackers {
  static Future<void> initialize() async {
    await AnilistManager.initialize();
  }
}
