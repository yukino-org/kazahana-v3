import 'package:kazahana/core/kitsu/exports.dart';
import 'package:utilx/utils.dart';
import '../cli/utils/exports.dart';
import '_utils.dart';

const Logger _logger = Logger('kitsu_anime_bulks');

typedef _BulkKitsuAnimeFn = Future<List<KitsuAnime>> Function();

Future<void> main() async {
  const List<TwinTuple<String, _BulkKitsuAnimeFn>> fns =
      <TwinTuple<String, _BulkKitsuAnimeFn>>[
    TwinTuple<String, _BulkKitsuAnimeFn>(
      'Most Popular Animes',
      KitsuAnimeEndpoints.mostPopularAnimes,
    ),
    TwinTuple<String, _BulkKitsuAnimeFn>(
      'Top Ongoing Animes',
      KitsuAnimeEndpoints.topOngoingAnimes,
    ),
  ];

  for (final TwinTuple<String, _BulkKitsuAnimeFn> x in fns) {
    final Stopwatch watch = Stopwatch()..start();
    final List<KitsuAnime> results = await x.last();
    watch.stop();
    _logger.info('Results for "${x.first}" (${watch.elapsedMilliseconds}ms)');
    int i = 1;
    for (final KitsuAnime y in results) {
      _logger.info('$i.');
      _logger.info(
        stringifyKitsuAnime(y)
            .split('\n')
            .map((final String x) => '   $x')
            .join('\n'),
      );
      i++;
    }
    _logger.println();
  }
}
