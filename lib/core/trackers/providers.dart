import './anilist/provider.dart' as anilist;
import './myanimelist/providers/anime.dart' as myanimelist;
import './myanimelist/providers/manga.dart' as myanimelist;
import '../../../core/models/tracker_provider.dart';

final List<TrackerProvider<AnimeProgress>> animeProviders =
    <TrackerProvider<AnimeProgress>>[
  anilist.anime,
  myanimelist.anime,
];

final List<TrackerProvider<MangaProgress>> mangaProviders =
    <TrackerProvider<MangaProgress>>[
  anilist.manga,
  myanimelist.manga,
];
