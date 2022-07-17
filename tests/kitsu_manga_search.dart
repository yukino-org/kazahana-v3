import 'package:kazahana/core/kitsu/exports.dart';
import '../cli/utils/exports.dart';
import '_utils.dart';

const Logger _logger = Logger('kitsu_manga_search');

Future<void> main() async {
  const List<String> terms = <String>[
    'mayo chiki',
    'naruto',
    'spy x family',
  ];

  for (final String x in terms) {
    final Stopwatch watch = Stopwatch()..start();
    final List<KitsuManga> results = await KitsuMangaEndpoints.search(x);
    watch.stop();
    _logger.info('Results for "$x" (${watch.elapsedMilliseconds}ms)');
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
