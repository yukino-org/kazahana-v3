import 'package:anilist/anilist.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../translator/exports.dart';
import '../utils/dates.dart';

extension AnilistFuzzyDateTUtils on AnilistFuzzyDate {
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

extension AnilistMediaTypeTUtils on AnilistMediaType {
  TenkaType get asTenkaType => _anilistMediaTypeTenkaTypeMap[this]!;
}

extension AnimeSeasonsTUtils on AnimeSeasons {
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

extension AnilistMediaTUtils on AnilistMedia {
  String get watchtime {
    switch (type) {
      case AnilistMediaType.anime:
        if (format == AnilistMediaFormat.movie) {
          return duration != null
              ? PrettyDurations.prettyHoursMinutesShort(
                  Duration(minutes: duration!),
                )
              : Translator.t.nMins('?');
        }
        return Translator.t.nEps(episodes?.toString() ?? '?');

      case AnilistMediaType.manga:
        return Translator.t.nChs(chapters?.toString() ?? '?');
    }
  }
}

extension AnilistRelationTypeTUtils on AnilistRelationType {
  String get titleCase => StringCase(name).titleCase;
}

extension AnilistMediaStatusTUtils on AnilistMediaStatus {
  String get titleCase {
    switch (this) {
      case AnilistMediaStatus.cancelled:
        return Translator.t.cancelled();

      case AnilistMediaStatus.releasing:
        return Translator.t.releasing();

      case AnilistMediaStatus.notYetReleased:
        return Translator.t.notYetReleased();

      case AnilistMediaStatus.finished:
        return Translator.t.finished();

      case AnilistMediaStatus.hiatus:
        return Translator.t.hiatus();
    }
  }
}
