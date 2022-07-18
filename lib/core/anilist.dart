import 'package:anilist/anilist.dart';
import 'package:tenka/tenka.dart';
import 'translator/exports.dart';
import 'utils/dates.dart';

export 'package:anilist/anilist.dart';

extension AnilistFuzzyDateUtils on AnilistFuzzyDate {
  String get pretty => PrettyDates.constructDateString(
        day: day?.toString() ?? '?',
        month: month?.toString() ?? '?',
        year: year?.toString() ?? '?',
      );
}

const Map<AnilistMediaType, TenkaType> _anilistMediaTypeTenkaTypeMap =
    <AnilistMediaType, TenkaType>{
  AnilistMediaType.anime: TenkaType.anime,
  AnilistMediaType.manga: TenkaType.manga,
};

extension AnilistMediaTypeUtils on AnilistMediaType {
  TenkaType get asTenkaType => _anilistMediaTypeTenkaTypeMap[this]!;
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

      case AnimeSeasons.fall:
        return Translator.t.fall();
    }
  }
}
