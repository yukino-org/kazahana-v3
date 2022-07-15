import 'dart:convert';

import 'package:kazahana/core/kitsu/exports.dart';
import '../cli/utils/exports.dart';

const Logger _logger = Logger('kitsu_manga_search');

Future<void> main() async {
  const List<String> terms = <String>[
    'mayo chiki',
    'naruto',
    'spy x family',
  ];

  for (final String x in terms) {
    final Stopwatch watch = Stopwatch()..start();
    final List<KitsuManga> results = await KitsuMangaSearchEndpoint.search(x);
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

String stringifyKitsuManga(final KitsuManga manga) => '''
id: ${manga.id}
type: ${manga.type}
url: ${manga.url}
slug: ${manga.slug}
synopsis: ${manga.synopsis}
titles: ${json.encode(manga.titles)}
canonicalTitle: ${manga.canonicalTitle}
abbreviatedTitles: ${json.encode(manga.abbreviatedTitles)}
averageRating: ${manga.averageRating}
startDate: ${manga.startDate}
endDate: ${manga.endDate}
popularityRank: ${manga.popularityRank}
ratingRank: ${manga.ratingRank}
ageRating: ${manga.ageRating}
ageRatingGuide: ${manga.ageRatingGuide}
subtype: ${manga.subtype}
status: ${manga.status}
posterImageTiny: ${manga.posterImageTiny}
posterImageSmall: ${manga.posterImageSmall}
posterImageMedium: ${manga.posterImageMedium}
posterImageLarge: ${manga.posterImageLarge}
posterImageOriginal: ${manga.posterImageOriginal}
coverImageTiny: ${manga.coverImageTiny}
coverImageSmall: ${manga.coverImageSmall}
coverImageLarge: ${manga.coverImageLarge}
coverImageOriginal: ${manga.coverImageOriginal}
chapterCount: ${manga.chapterCount}
volumeCount: ${manga.volumeCount}
serialization: ${manga.serialization}
''';
