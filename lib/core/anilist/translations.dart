import 'package:anilist/anilist.dart';
import 'package:tenka/tenka.dart';
import '../translator/exports.dart';
import '../utils/exports.dart';

extension AnilistFuzzyDateTUtils on AnilistFuzzyDate {
  String get pretty => PrettyDates.constructDateString(
        day: day?.toString() ?? Translation.unk,
        month: month?.toString() ?? Translation.unk,
        year: year?.toString() ?? Translation.unk,
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
  String getTitleCase(final Translation translation) {
    switch (this) {
      case AnimeSeasons.winter:
        return translation.winter;

      case AnimeSeasons.spring:
        return translation.spring;

      case AnimeSeasons.summer:
        return translation.summer;

      case AnimeSeasons.fall:
        return translation.fall;
    }
  }
}

extension AnilistMediaTUtils on AnilistMedia {
  String getWatchtime(final Translation translation) {
    switch (type) {
      case AnilistMediaType.anime:
        if (format == AnilistMediaFormat.movie) {
          return duration != null
              ? PrettyDurations.prettyHoursMinutesShort(
                  translation,
                  Duration(minutes: duration!),
                )
              : translation.nMins(Translation.unk);
        }
        return translation.nEps(episodes?.toString() ?? Translation.unk);

      case AnilistMediaType.manga:
        return translation.nChs(chapters?.toString() ?? Translation.unk);
    }
  }

  String get airdate {
    final String startDatePretty = startDate?.maybePretty ?? Translation.unk;
    final String endDatePretty = endDate?.maybePretty ?? Translation.unk;
    if (startDatePretty == endDatePretty) return startDatePretty;
    return '$startDatePretty - $endDatePretty';
  }
}

extension AnilistRelationTypeTUtils on AnilistRelationType {
  String getTitleCase(final Translation translation) =>
      StringCase(name).titleCase;
}

extension AnilistCharacterRoleTUtils on AnilistCharacterRole {
  String getTitleCase(final Translation translation) =>
      StringCase(name).titleCase;
}

extension AnilistMediaStatusTUtils on AnilistMediaStatus {
  String getTitleCase(final Translation translation) {
    switch (this) {
      case AnilistMediaStatus.cancelled:
        return translation.cancelled;

      case AnilistMediaStatus.releasing:
        return translation.releasing;

      case AnilistMediaStatus.notYetReleased:
        return translation.notYetReleased;

      case AnilistMediaStatus.finished:
        return translation.finished;

      case AnilistMediaStatus.hiatus:
        return translation.hiatus;
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
  String getTitleCase(final Translation translation) =>
      _anilistMediaFormatTitleMap[this]!;
}

extension AnilistMediaListStatusTUtils on AnilistMediaListStatus {
  String getTitleCase(final Translation translation) {
    switch (this) {
      case AnilistMediaListStatus.current:
        return translation.current;

      case AnilistMediaListStatus.planning:
        return translation.planning;

      case AnilistMediaListStatus.completed:
        return translation.completed;

      case AnilistMediaListStatus.dropped:
        return translation.dropped;

      case AnilistMediaListStatus.paused:
        return translation.paused;

      case AnilistMediaListStatus.repeating:
        return translation.repeating;
    }
  }
}
