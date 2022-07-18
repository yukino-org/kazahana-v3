import 'package:utilx/utils.dart';

enum AnilistMediaType {
  anime,
  manga,
}

extension AnilistMediaTypeUtils on AnilistMediaType {
  String get stringify => name.toUpperCase();
}

AnilistMediaType parseAnilistMediaType(final String value) =>
    EnumUtils.find(AnilistMediaType.values, value.toLowerCase());
