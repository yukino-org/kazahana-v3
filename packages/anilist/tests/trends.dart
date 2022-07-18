import 'package:anilist/anilist.dart';
import '../../../cli/utils/exports.dart';
import '_utils.dart';

const Logger _logger = Logger('anilist_trending');

typedef _TrendingFn = Future<List<AnilistMedia>> Function();

Future<void> main() async {
  final Map<String, _TrendingFn> fns = <String, _TrendingFn>{
    'Trending Animes': () async => AnilistMediaEndpoints.trendingAnimes(),
    // 'Top Ongoing Animes': () async => AnilistMediaEndpoints.topOngoingAnimes(),
    // 'Most Popular Animes': () async =>
    //     AnilistMediaEndpoints.mostPopularAnimes(),
    // 'Trending Mangas': () async => AnilistMediaEndpoints.trendingMangas(),
    // 'Top Ongoing Mangas': () async => AnilistMediaEndpoints.topOngoingMangas(),
    // 'Most Popular Mangas': () async =>
    //     AnilistMediaEndpoints.mostPopularMangas(),
  };

  for (final MapEntry<String, _TrendingFn> x in fns.entries) {
    final Stopwatch watch = Stopwatch()..start();
    final List<AnilistMedia> results = await x.value();
    watch.stop();
    _logger.info('Results for "${x.key}" (${watch.elapsedMilliseconds}ms)');
    if (results.isEmpty) throw Exception('Query results are empty');

    int i = 1;
    for (final AnilistMedia y in results) {
      _logger.info('$i.');
      _logger.info(padLeftMultilineString(stringifyAnilistMedia(y)));
      i++;
    }
    _logger.println();
  }
}
