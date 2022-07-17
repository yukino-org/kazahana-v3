import 'package:kazahana/core/kitsu/exports.dart';
import '../cli/utils/exports.dart';
import '_utils.dart';

const Logger _logger = Logger('kitsu_anime_search');

Future<void> main() async {
  const List<String> terms = <String>[
    'mayo chiki',
    'naruto',
    'masamune kun 2',
  ];

  for (final String x in terms) {
    final Stopwatch watch = Stopwatch()..start();
    final List<KitsuAnime> results = await KitsuAnimeEndpoints.search(x);
    watch.stop();
    _logger.info('Results for "$x" (${watch.elapsedMilliseconds}ms)');
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
