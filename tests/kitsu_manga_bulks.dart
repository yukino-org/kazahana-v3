import 'package:kazahana/core/kitsu/exports.dart';
import 'package:utilx/utils.dart';
import '../cli/utils/exports.dart';
import '_utils.dart';

const Logger _logger = Logger('kitsu_manga_bulks');

typedef _BulkKitsuMangaFn = Future<List<KitsuManga>> Function();

Future<void> main() async {
  const List<TwinTuple<String, _BulkKitsuMangaFn>> fns =
      <TwinTuple<String, _BulkKitsuMangaFn>>[
    TwinTuple<String, _BulkKitsuMangaFn>(
      'Most Popular Mangas',
      KitsuMangaEndpoints.mostPopularMangas,
    ),
    TwinTuple<String, _BulkKitsuMangaFn>(
      'Top Ongoing Mangas',
      KitsuMangaEndpoints.topOngoingMangas,
    ),
  ];

  for (final TwinTuple<String, _BulkKitsuMangaFn> x in fns) {
    final Stopwatch watch = Stopwatch()..start();
    final List<KitsuManga> results = await x.last();
    watch.stop();
    _logger.info('Results for "${x.first}" (${watch.elapsedMilliseconds}ms)');
    int i = 1;
    for (final KitsuManga y in results) {
      _logger.info('$i.');
      _logger.info(
        stringifyKitsuManga(y)
            .split('\n')
            .map((final String x) => '   $x')
            .join('\n'),
      );
      i++;
    }
    _logger.println();
  }
}
