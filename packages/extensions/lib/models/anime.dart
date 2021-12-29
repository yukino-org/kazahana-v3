import 'package:utilx/utilities/locale.dart';
import './base.dart';

enum Qualities {
  q_144p,
  q_360p,
  q_480p,
  q_720p,
  q_1080p,
  unknown,
}

class Quality {
  const Quality(this.quality, this.code, this.short);

  final Qualities quality;
  final String code;
  final String short;

  static final Map<Qualities, Quality> qualities = const <Quality>[
    Quality(Qualities.q_144p, '144p', 'sd'),
    Quality(Qualities.q_360p, '360p', 'sd'),
    Quality(Qualities.q_480p, '480p', 'sd'),
    Quality(Qualities.q_720p, '720p', 'hd'),
    Quality(Qualities.q_1080p, '1080p', 'fhd'),
    Quality(Qualities.unknown, 'unknown', '?'),
  ].asMap().map(
        (final int k, final Quality x) =>
            MapEntry<Qualities, Quality>(x.quality, x),
      );

  static Quality getQuality(final Qualities q) => qualities[q]!;

  static Quality resolveQuality(final String _approx) {
    final String approx = _approx.toLowerCase();
    for (final Quality q in qualities.values) {
      if (q.code == approx ||
          q.code.substring(0, q.code.length - 1) == approx ||
          q.short == approx) return q;
    }
    return getQuality(Qualities.unknown);
  }
}

class EpisodeInfo {
  const EpisodeInfo({
    required final this.episode,
    required final this.url,
    required final this.locale,
  });

  factory EpisodeInfo.fromJson(final Map<dynamic, dynamic> json) => EpisodeInfo(
        episode: json['episode'] as String,
        url: json['url'] as String,
        locale: Locale.parse(json['locale'] as String),
      );

  final String episode;
  final String url;
  final Locale locale;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'episode': episode,
        'url': url,
        'locale': locale.toCodeString(),
      };
}

class AnimeInfo {
  const AnimeInfo({
    required final this.title,
    required final this.url,
    required final this.episodes,
    required final this.locale,
    required final this.availableLocales,
    final this.thumbnail,
  });

  factory AnimeInfo.fromJson(final Map<dynamic, dynamic> json) => AnimeInfo(
        title: json['title'] as String,
        url: json['url'] as String,
        episodes: (json['episodes'] as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .map((final Map<dynamic, dynamic> x) => EpisodeInfo.fromJson(x))
            .toList(),
        thumbnail: json['thumbnail'] != null
            ? ImageDescriber.fromJson(
                json['thumbnail'] as Map<dynamic, dynamic>,
              )
            : null,
        locale: Locale.parse(json['locale'] as String),
        availableLocales: (json['availableLocales'] as List<dynamic>)
            .cast<String>()
            .map((final String x) => Locale.parse(x))
            .toList(),
      );

  final String title;
  final String url;
  final List<EpisodeInfo> episodes;
  final ImageDescriber? thumbnail;
  final Locale locale;
  final List<Locale> availableLocales;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'url': url,
        'thumbnail': thumbnail?.toJson(),
        'episodes': episodes.map((final EpisodeInfo x) => x.toJson()).toList(),
        'locale': locale.toCodeString(),
        'availableLocales':
            availableLocales.map((final Locale x) => x.toCodeString()).toList(),
      };
}

class EpisodeSource {
  const EpisodeSource({
    required final this.url,
    required final this.quality,
    required final this.headers,
    required final this.locale,
  });

  factory EpisodeSource.fromJson(final Map<dynamic, dynamic> json) =>
      EpisodeSource(
        url: json['url'] as String,
        headers:
            (json['headers'] as Map<dynamic, dynamic>).cast<String, String>(),
        quality: Quality.resolveQuality(json['quality'] as String),
        locale: Locale.parse(json['locale'] as String),
      );

  final String url;
  final Quality quality;
  final Map<String, String> headers;
  final Locale locale;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'quality': quality.code,
        'url': url,
        'headers': headers,
        'locale': locale.toCodeString(),
      };
}

typedef GetAnimeInfoFn = Future<AnimeInfo> Function(String, Locale);

typedef GetSourcesFn = Future<List<EpisodeSource>> Function(EpisodeInfo);

class AnimeExtractor extends BaseExtractor {
  const AnimeExtractor({
    required final String name,
    required final String id,
    required final SearchFn search,
    required final Locale defaultLocale,
    required final this.getInfo,
    required final this.getSources,
  }) : super(
          name: name,
          id: id,
          search: search,
          defaultLocale: defaultLocale,
        );

  final GetAnimeInfoFn getInfo;
  final GetSourcesFn getSources;
}
