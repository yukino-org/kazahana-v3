import './anilist/anilist.dart';
import './anilist/providers/provider.dart';
import './myanimelist/myanimelist.dart';
import './myanimelist/providers/provider.dart';
import './provider.dart';

abstract class Trackers {
  static final List<TrackerProvider<AnimeProgress>> anime =
      <TrackerProvider<AnimeProgress>>[
    AniListProvider.anime,
    MyAnimeListProvider.anime,
  ];

  static final List<TrackerProvider<MangaProgress>> manga =
      <TrackerProvider<MangaProgress>>[
    AniListProvider.manga,
    MyAnimeListProvider.manga,
  ];

  static Future<void> initialize() async {
    await AnilistManager.initialize();
    await MyAnimeListManager.initialize();
  }
}
