import 'package:anilist/anilist.dart';
import '../../../cli/utils/exports.dart';
import '_utils.dart';

const Logger _logger = Logger('anilist_search');

Future<void> main() async {
  const List<String> terms = <String>[
    'mayo chiki',
    'naruto',
    'masamune kun 2',
  ];

  for (final String x in terms) {
    final Stopwatch watch = Stopwatch()..start();
    final List<AnilistMedia> results = await AnilistMediaEndpoints.search(x);
    watch.stop();
    _logger.info('Results for "$x" (${watch.elapsedMilliseconds}ms)');
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
