import './sources/model.dart' show RetrievedSource;
import '../../models/languages.dart' show LanguageCodes, LanguageName;
import '../model.dart';

enum Qualities {
  q_144p,
  q_360p,
  q_480p,
  q_720p,
  q_1080p,
  unknown,
}

class Quality {
  Quality(
    this.quality,
    this.code,
    this.short,
  );

  final Qualities quality;
  final String code;
  final String short;
}

final Map<Qualities, Quality> quality = <Quality>[
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

Quality getQuality(final Qualities q) => quality[q]!;

Quality resolveQuality(final String _approx) {
  final String approx = _approx.toLowerCase();
  for (final Quality q in quality.values) {
    if (q.code == approx ||
        q.code.substring(0, q.code.length - 1) == approx ||
        q.short == approx) return q;
  }
  return getQuality(Qualities.unknown);
}

class SearchInfo extends BaseSearchInfo {
  SearchInfo({
    required final String url,
    required final String title,
    required final this.locale,
    final String? thumbnail,
  }) : super(
          title: title,
          thumbnail: thumbnail,
          url: url,
        );

  LanguageCodes locale;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'locale': locale.code,
      };
}

class EpisodeInfo {
  EpisodeInfo({
    required final this.episode,
    required final this.url,
    required final this.locale,
  });

  String episode;
  String url;
  LanguageCodes locale;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'episode': episode,
        'url': url,
        'locale': locale.code,
      };
}

class AnimeInfo {
  AnimeInfo({
    required final this.url,
    required final this.title,
    required final this.episodes,
    required final this.locale,
    required final this.availableLocales,
    final this.thumbnail,
  });

  String title;
  String url;
  List<EpisodeInfo> episodes;
  String? thumbnail;
  LanguageCodes locale;
  final List<LanguageCodes> availableLocales;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'episodes': episodes.map((final EpisodeInfo x) => x.toJson()).toList(),
        'locale': locale.code,
      };
}

class EpisodeSource {
  EpisodeSource({
    required final this.url,
    required final this.quality,
    required final this.headers,
    required final this.locale,
  });

  factory EpisodeSource.fromRetrievedSource({
    required final RetrievedSource retrieved,
    required final LanguageCodes locale,
  }) =>
      EpisodeSource(
        url: retrieved.url,
        headers: retrieved.headers,
        quality: retrieved.quality,
        locale: locale,
      );

  String url;
  Quality quality;
  Map<String, String> headers;
  LanguageCodes locale;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'quality': quality.code,
        'url': url,
        'headers': headers,
        'locale': locale.code,
      };
}

abstract class AnimeExtractor extends BaseExtractorPlugin<SearchInfo> {
  LanguageCodes get defaultLocale;

  Future<AnimeInfo> getInfo(
    final String url, {
    required final LanguageCodes locale,
  });

  Future<List<EpisodeSource>> getSources(final EpisodeInfo episode);
}
