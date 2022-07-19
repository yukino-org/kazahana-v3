import 'package:utilx/utils.dart';

enum AnilistRelationType {
  adaptation,
  prequel,
  sequel,
  parent,
  sideStory,
  character,
  summary,
  alternative,
  spinOff,
  other,
  source,
  compilation,
  contains,
}

final Map<AnilistRelationType, String> _anilistMediaStatusStringifyMap =
    AnilistRelationType.values.asMap().map(
          (final _, final AnilistRelationType x) =>
              MapEntry<AnilistRelationType, String>(
            x,
            StringCase(x.name).snakeCase.toUpperCase(),
          ),
        );

extension AnilistRelationTypeUtils on AnilistRelationType {
  String get stringify => _anilistMediaStatusStringifyMap[this]!;
}

AnilistRelationType parseAnilistRelationType(final String value) =>
    _anilistMediaStatusStringifyMap.entries
        .firstWhere(
          (final MapEntry<AnilistRelationType, String> x) => x.value == value,
        )
        .key;
