import 'package:utilx/utilx.dart';

enum AnilistMediaListStatus {
  current,
  planning,
  completed,
  dropped,
  paused,
  repeating,
}

extension AnilistMediaListStatusUtils on AnilistMediaListStatus {
  String get stringify => name.toUpperCase();
}

AnilistMediaListStatus parseAnilistMediaListStatus(final String value) =>
    EnumUtils.find(AnilistMediaListStatus.values, value.toLowerCase());
