import 'package:utilx/utils/enum.dart';

enum KitsuAnimeSubType {
  ona,
  ova,
  tv,
  movie,
  music,
  special,
}

const Map<KitsuAnimeSubType, String> _kitsuAnimeSubTypeCodeMap =
    <KitsuAnimeSubType, String>{
  KitsuAnimeSubType.ona: 'ONA',
  KitsuAnimeSubType.ova: 'OVA',
  KitsuAnimeSubType.tv: 'TV',
  KitsuAnimeSubType.movie: 'Movie',
  KitsuAnimeSubType.music: 'Music',
  KitsuAnimeSubType.special: 'Special',
};

extension KitsuAnimeSubTypeUtils on KitsuAnimeSubType {
  String get code => _kitsuAnimeSubTypeCodeMap[this]!;
  String get titleCase => code;
}

KitsuAnimeSubType parseKitsuAnimeSubType(final String code) =>
    EnumUtils.find(KitsuAnimeSubType.values, code.toLowerCase());
