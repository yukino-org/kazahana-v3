import 'package:utilx/utils/enum.dart';

enum KitsuMangaSubType {
  doujin,
  manga,
  manhua,
  manhwa,
  novel,
  oel,
  oneshot,
}

const Map<KitsuMangaSubType, String> _kitsuMangaSubTypeCodeMap =
    <KitsuMangaSubType, String>{
  KitsuMangaSubType.doujin: 'Doujin',
  KitsuMangaSubType.manga: 'Manga',
  KitsuMangaSubType.manhua: 'Manhua',
  KitsuMangaSubType.manhwa: 'Manhwa',
  KitsuMangaSubType.novel: 'Novel',
  KitsuMangaSubType.oel: 'OEL',
  KitsuMangaSubType.oneshot: 'One-shot',
};

extension KitsuMangaSubTypeUtils on KitsuMangaSubType {
  String get code => _kitsuMangaSubTypeCodeMap[this]!;
  String get titleCase => code;
}

KitsuMangaSubType parseKitsuMangaSubType(final String code) =>
    EnumUtils.find(KitsuMangaSubType.values, code);
