import 'package:utilx/utils.dart';

enum KitsuAgeRating {
  general,
  parentalGuidance,
  restricted,
  explicit,
}

const Map<KitsuAgeRating, String> _kitsuAgeRatingCodeMap =
    <KitsuAgeRating, String>{
  KitsuAgeRating.general: 'G',
  KitsuAgeRating.parentalGuidance: 'PG',
  KitsuAgeRating.restricted: 'R',
  KitsuAgeRating.explicit: 'R18',
};

extension KitsuAgeRatingUtils on KitsuAgeRating {
  String get code => _kitsuAgeRatingCodeMap[this]!;

  String get titleCase =>
      StringUtils.getWords(name).map(StringUtils.capitalize).join(' ');
}

KitsuAgeRating parseKitsuAgeRating(final String code) => KitsuAgeRating.values
    .firstWhere((final KitsuAgeRating x) => x.code == code);
