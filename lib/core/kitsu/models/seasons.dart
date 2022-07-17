import 'package:utilx/utils.dart';
import '../../translator/exports.dart';

enum AnimeSeasons {
  winter,
  spring,
  summer,
  autumn,
}

extension AnimeSeasonsUtils on AnimeSeasons {
  String get titleCase {
    switch (this) {
      case AnimeSeasons.winter:
        return Translator.t.winter();

      case AnimeSeasons.spring:
        return Translator.t.spring();

      case AnimeSeasons.summer:
        return Translator.t.summer();

      case AnimeSeasons.autumn:
        return Translator.t.autumn();
    }
  }
}

AnimeSeasons parseAnimeSeason(final String code) =>
    EnumUtils.find(AnimeSeasons.values, code);

AnimeSeasons getCurrentAnimeSeason() =>
    getAnimeSeasonFromYear(DateTime.now().month);

AnimeSeasons getAnimeSeasonFromYear(final int month) {
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
      return AnimeSeasons.autumn;

    default:
      throw Error();
  }
}
