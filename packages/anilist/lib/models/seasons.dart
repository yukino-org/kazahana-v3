import 'package:utilx/utils.dart';

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

AnimeSeasons getAnimeSeasonFromMonth(final int month) {
  switch (month) {
    case 1:
    case 2:
    case 3:
      return AnimeSeasons.winter;

    case 4:
    case 5:
    case 6:
      return AnimeSeasons.spring;

    case 7:
    case 8:
    case 9:
      return AnimeSeasons.summer;

    case 10:
    case 11:
    case 12:
      return AnimeSeasons.fall;

    default:
      throw Error();
  }
}
