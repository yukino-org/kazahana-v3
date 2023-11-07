import 'package:utilx/utilx.dart';

enum AnimeSeasons {
  winter,
  spring,
  summer,
  fall,
}

extension AnimeSeasonsUtils on AnimeSeasons {
  String get stringify => name.toUpperCase();
}

AnimeSeasons parseAnimeSeason(final String code) =>
    EnumUtils.find(AnimeSeasons.values, code.toLowerCase());

AnimeSeasons getAnimeSeasonFromMonth(final int month) => switch (month) {
      1 || 2 || 3 => AnimeSeasons.winter,
      4 || 5 || 6 => AnimeSeasons.spring,
      7 || 8 || 9 => AnimeSeasons.summer,
      10 || 11 || 12 => AnimeSeasons.fall,
      _ => throw Exception('Unexpected anime season month'),
    };
