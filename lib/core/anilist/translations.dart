import 'package:anilist/anilist.dart';
import 'package:tenka/tenka.dart';
import '../translator/exports.dart';
import '../utils/exports.dart';

extension AnilistFuzzyDateTUtils on AnilistFuzzyDate {
  String get pretty => PrettyDates.constructDateString(
        day: day?.toString() ?? Translations.unknownCharacter,
        month: month?.toString() ?? Translations.unknownCharacter,
        year: year?.toString() ?? Translations.unknownCharacter,
      );

  String? get maybePretty => isValidDateTime ? pretty : null;
}

const Map<AnilistMediaType, TenkaType> _anilistMediaTypeTenkaTypeMap =
    <AnilistMediaType, TenkaType>{
  AnilistMediaType.anime: TenkaType.anime,
  AnilistMediaType.manga: TenkaType.manga,
};

extension AnilistMediaTypeTUtils on AnilistMediaType {
  TenkaType get asTenkaType => _anilistMediaTypeTenkaTypeMap[this]!;
}

extension TenkaTypeAnilistUtils on TenkaType {
  AnilistMediaType get asAnilistMediaType =>
      _anilistMediaTypeTenkaTypeMap.entries
          .firstWhere(
            (final MapEntry<AnilistMediaType, TenkaType> x) => x.value == this,
          )
          .key;
}

extension AnimeSeasonsTUtils on AnimeSeasons {
  String getTitleCase(final Translations translations) {
    switch (this) {
      case AnimeSeasons.winter:
        return translations.winter();

      case AnimeSeasons.spring:
        return translations.spring();

      case AnimeSeasons.summer:
        return translations.summer();

      case AnimeSeasons.fall:
        return translations.fall();
    }
  }
}

extension AnilistMediaTUtils on AnilistMedia {
  String getWatchtime(final Translations translations) {
    switch (type) {
      case AnilistMediaType.anime:
        if (format == AnilistMediaFormat.movie) {
          return duration != null
              ? PrettyDurations.prettyHoursMinutesShort(
                  duration: Duration(minutes: duration!),
                  translations: translations,
                )
              : translations.nMins(Translations.unknownCharacter);
        }
        return translations
            .nEps(episodes?.toString() ?? Translations.unknownCharacter);

      case AnilistMediaType.manga:
        return translations
            .nChs(chapters?.toString() ?? Translations.unknownCharacter);
    }
  }

  String get airdate {
    final String startDatePretty =
        startDate?.maybePretty ?? Translations.unknownCharacter;
    final String endDatePretty =
        endDate?.maybePretty ?? Translations.unknownCharacter;
    if (startDatePretty == endDatePretty) return startDatePretty;
    return '$startDatePretty - $endDatePretty';
  }
}

extension AnilistRelationTypeTUtils on AnilistRelationType {
  String getTitleCase(final Translations translations) =>
      StringCase(name).titleCase;
}

extension AnilistCharacterRoleTUtils on AnilistCharacterRole {
  String getTitleCase(final Translations translations) =>
      StringCase(name).titleCase;
}

extension AnilistMediaStatusTUtils on AnilistMediaStatus {
  String getTitleCase(final Translations translations) {
    switch (this) {
      case AnilistMediaStatus.cancelled:
        return translations.cancelled();

      case AnilistMediaStatus.releasing:
        return translations.releasing();

      case AnilistMediaStatus.notYetReleased:
        return translations.notYetReleased();

      case AnilistMediaStatus.finished:
        return translations.finished();

      case AnilistMediaStatus.hiatus:
        return translations.hiatus();
    }
  }
}

const Map<AnilistMediaFormat, String> _anilistMediaFormatTitleMap =
    <AnilistMediaFormat, String>{
  AnilistMediaFormat.tv: 'TV',
  AnilistMediaFormat.tvShort: 'TV (Short)',
  AnilistMediaFormat.movie: 'Movie',
  AnilistMediaFormat.special: 'Special',
  AnilistMediaFormat.ova: 'OVA',
  AnilistMediaFormat.ona: 'ONA',
  AnilistMediaFormat.music: 'Music',
  AnilistMediaFormat.manga: 'Manga',
  AnilistMediaFormat.novel: 'Novel',
  AnilistMediaFormat.oneshot: 'OneShot',
};

extension AnilistMediaFormatTUtils on AnilistMediaFormat {
  String getTitleCase(final Translations translations) =>
      _anilistMediaFormatTitleMap[this]!;
}

extension AnilistMediaListStatusTUtils on AnilistMediaListStatus {
  String getTitleCase(final Translations translations) {
    switch (this) {
      case AnilistMediaListStatus.current:
        return translations.current();

      case AnilistMediaListStatus.planning:
        return translations.planning();

      case AnilistMediaListStatus.completed:
        return translations.completed();

      case AnilistMediaListStatus.dropped:
        return translations.dropped();

      case AnilistMediaListStatus.paused:
        return translations.paused();

      case AnilistMediaListStatus.repeating:
        return translations.repeating();
    }
  }
}
