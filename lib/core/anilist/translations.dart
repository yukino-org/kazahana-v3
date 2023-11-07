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
  String getTitleCase(final Translation translation) => switch (this) {
        AnimeSeasons.winter => translation.winter,
        AnimeSeasons.spring => translation.spring,
        AnimeSeasons.summer => translation.summer,
        AnimeSeasons.fall => translation.fall,
      };
}

extension AnilistMediaTUtils on AnilistMedia {
  String getWatchtime(final Translation translation) => switch (type) {
        AnilistMediaType.anime when format == AnilistMediaFormat.movie =>
          duration != null
              ? PrettyDurations.prettyHoursMinutesShort(
                  translation,
                  Duration(minutes: duration!),
                )
              : translation.nMins(Translation.unk),
        AnilistMediaType.anime =>
          translation.nEps(episodes?.toString() ?? Translation.unk),
        AnilistMediaType.manga =>
          translation.nChs(chapters?.toString() ?? Translation.unk),
      };

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
  String getTitleCase(final Translation translation) => switch (this) {
        AnilistMediaStatus.cancelled => translation.cancelled,
        AnilistMediaStatus.releasing => translation.releasing,
        AnilistMediaStatus.notYetReleased => translation.notYetReleased,
        AnilistMediaStatus.finished => translation.finished,
        AnilistMediaStatus.hiatus => translation.hiatus,
      };
}

extension AnilistMediaFormatTUtils on AnilistMediaFormat {
  String getTitleCase(final Translation translation) => switch (this) {
        AnilistMediaFormat.tv => 'TV',
        AnilistMediaFormat.tvShort => 'TV (Short)',
        AnilistMediaFormat.movie => 'Movie',
        AnilistMediaFormat.special => 'Special',
        AnilistMediaFormat.ova => 'OVA',
        AnilistMediaFormat.ona => 'ONA',
        AnilistMediaFormat.music => 'Music',
        AnilistMediaFormat.manga => 'Manga',
        AnilistMediaFormat.novel => 'Novel',
        AnilistMediaFormat.oneshot => 'OneShot',
      };
}

extension AnilistMediaListStatusTUtils on AnilistMediaListStatus {
  String getTitleCase(final Translation translation) => switch (this) {
        AnilistMediaListStatus.current => translation.current,
        AnilistMediaListStatus.planning => translation.planning,
        AnilistMediaListStatus.completed => translation.completed,
        AnilistMediaListStatus.dropped => translation.dropped,
        AnilistMediaListStatus.paused => translation.paused,
        AnilistMediaListStatus.repeating => translation.repeating,
      };
}
