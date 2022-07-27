enum AnilistMediaFormat {
  tv,
  tvShort,
  movie,
  special,
  ova,
  ona,
  music,
  manga,
  novel,
  oneshot,
}

const Map<AnilistMediaFormat, String> _anilistMediaFormatStringifyMap =
    <AnilistMediaFormat, String>{
  AnilistMediaFormat.tv: 'TV',
  AnilistMediaFormat.tvShort: 'TV_SHORT',
  AnilistMediaFormat.movie: 'MOVIE',
  AnilistMediaFormat.special: 'SPECIAL',
  AnilistMediaFormat.ova: 'OVA',
  AnilistMediaFormat.ona: 'ONA',
  AnilistMediaFormat.music: 'MUSIC',
  AnilistMediaFormat.manga: 'MANGA',
  AnilistMediaFormat.novel: 'NOVEL',
  AnilistMediaFormat.oneshot: 'ONE_SHOT',
};

extension AnilistMediaFormatUtils on AnilistMediaFormat {
  String get stringify => _anilistMediaFormatStringifyMap[this]!;
}

AnilistMediaFormat parseAnilistMediaFormat(final String value) =>
    _anilistMediaFormatStringifyMap.entries
        .firstWhere(
          (final MapEntry<AnilistMediaFormat, String> x) => x.value == value,
        )
        .key;
