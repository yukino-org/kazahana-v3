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

extension AnilistMediaFormatUtils on AnilistMediaFormat {
  String get titleCase => _anilistMediaFormatTitleMap[this]!;
  String get stringify => _anilistMediaFormatStringifyMap[this]!;
}

AnilistMediaFormat parseAnilistMediaFormat(final String value) =>
    _anilistMediaFormatStringifyMap.entries
        .firstWhere(
          (final MapEntry<AnilistMediaFormat, String> x) => x.value == value,
        )
        .key;
