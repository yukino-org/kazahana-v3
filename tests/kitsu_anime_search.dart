import 'dart:convert';

import 'package:kazahana/core/kitsu/exports.dart';
import '../cli/utils/exports.dart';

const Logger _logger = Logger('kitsu_anime_search');

Future<void> main() async {
  const List<String> terms = <String>[
    'mayo chiki',
    'naruto',
    'masamune kun 2',
  ];

  for (final String x in terms) {
    final Stopwatch watch = Stopwatch()..start();
    final List<KitsuAnime> results = await KitsuAnimeSearchEndpoint.search(x);
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

String stringifyKitsuAnime(final KitsuAnime anime) => '''
id: ${anime.id}
type: ${anime.type}
url: ${anime.url}
slug: ${anime.slug}
synopsis: ${anime.synopsis}
titles: ${json.encode(anime.titles)}
canonicalTitle: ${anime.canonicalTitle}
abbreviatedTitles: ${json.encode(anime.abbreviatedTitles)}
averageRating: ${anime.averageRating}
startDate: ${anime.startDate}
endDate: ${anime.endDate}
popularityRank: ${anime.popularityRank}
ratingRank: ${anime.ratingRank}
ageRating: ${anime.ageRating}
ageRatingGuide: ${anime.ageRatingGuide}
subtype: ${anime.subtype}
status: ${anime.status}
posterImageTiny: ${anime.posterImageTiny}
posterImageSmall: ${anime.posterImageSmall}
posterImageMedium: ${anime.posterImageMedium}
posterImageLarge: ${anime.posterImageLarge}
posterImageOriginal: ${anime.posterImageOriginal}
coverImageTiny: ${anime.coverImageTiny}
coverImageSmall: ${anime.coverImageSmall}
coverImageLarge: ${anime.coverImageLarge}
coverImageOriginal: ${anime.coverImageOriginal}
episodeCount: ${anime.episodeCount}
episodeLength: ${anime.episodeLength}
nsfw: ${anime.nsfw}
''';
