import 'dart:convert';
import 'package:kazahana/core/kitsu/exports.dart';

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
