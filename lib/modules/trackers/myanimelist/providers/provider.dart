import './anime.dart';
import './manga.dart';
import '../../provider.dart';

abstract class MyAnimeListProvider {
  static final TrackerProvider<AnimeProgress> anime = animeProvider;
  static final TrackerProvider<MangaProgress> manga = mangaProvider;
}
