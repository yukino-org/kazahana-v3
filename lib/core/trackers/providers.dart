import './anilist/provider.dart' as anilist;
import '../../../core/models/tracker_provider.dart';

final List<TrackerProvider<AnimeProgress, dynamic>> animeProviders =
    <TrackerProvider<AnimeProgress, dynamic>>[
  anilist.anime,
];

final List<TrackerProvider<MangaProgress, dynamic>> mangaProviders =
    <TrackerProvider<MangaProgress, dynamic>>[
  anilist.manga,
];
