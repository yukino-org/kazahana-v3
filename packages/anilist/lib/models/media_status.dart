import 'package:utilx/utilx.dart';

enum AnilistMediaStatus {
  finished,
  releasing,
  notYetReleased,
  cancelled,
  hiatus,
}

final Map<AnilistMediaStatus, String> _anilistMediaStatusStringifyMap =
    AnilistMediaStatus.values.asMap().map(
          (final _, final AnilistMediaStatus x) =>
              MapEntry<AnilistMediaStatus, String>(
            x,
            StringCase(x.name).snakeCase.toUpperCase(),
          ),
        );

extension AnilistMediaStatusUtils on AnilistMediaStatus {
  String get stringify => _anilistMediaStatusStringifyMap[this]!;
}

AnilistMediaStatus parseAnilistMediaStatus(final String value) =>
    _anilistMediaStatusStringifyMap.entries
        .firstWhere(
          (final MapEntry<AnilistMediaStatus, String> x) => x.value == value,
        )
        .key;
