import '../../../plugins/translator/model.dart'
    show LanguageCodes, LanguageName;
import '../model.dart';

enum Qualities { q_144p, q_360p, q_480p, q_720p, q_1080p, unknown }

class Quality {
  final Qualities quality;
  final String code;
  final String short;

  Quality(
    this.quality,
    this.code,
    this.short,
  );
}

final Map<Qualities, Quality> quality = {
  Qualities.q_144p: Quality(Qualities.q_144p, '144p', 'sd'),
  Qualities.q_360p: Quality(Qualities.q_360p, '360p', 'sd'),
  Qualities.q_480p: Quality(Qualities.q_480p, '480p', 'sd'),
  Qualities.q_720p: Quality(Qualities.q_720p, '720p', 'hd'),
  Qualities.q_1080p: Quality(Qualities.q_1080p, '1080p', 'fhd'),
  Qualities.unknown: Quality(Qualities.unknown, 'unknown', '?'),
};

class SearchInfo extends BaseSearchInfo {
  LanguageCodes locale;

  SearchInfo({
    required final url,
    required final title,
    final thumbnail,
    required final this.locale,
  }) : super(
          title: title,
          thumbnail: thumbnail,
          url: url,
        );

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'locale': locale.code,
      };
}

class EpisodeInfo {
  String? title;
  String episode;
  String url;
  LanguageCodes locale;

  EpisodeInfo({
    this.title,
    required final this.episode,
    required final this.url,
    required final this.locale,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'episode': episode,
        'url': url,
        'locale': locale.code,
      };
}

class AnimeInfo {
  String title;
  String url;
  List<EpisodeInfo> episodes;
  String? thumbnail;
  LanguageCodes locale;

  AnimeInfo({
    required final this.url,
    required final this.title,
    required final this.episodes,
    final this.thumbnail,
    required final this.locale,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'episodes': episodes.map((x) => x.toJson()).toList(),
        'locale': locale.code,
      };
}

class EpisodeSource {
  String url;
  Quality quality;
  Map<String, String> headers;
  LanguageCodes locale;

  EpisodeSource({
    required final this.url,
    required final this.quality,
    final this.headers = const {},
    required final this.locale,
  });

  Map<String, dynamic> toJson() => {
        'quality': quality,
        'url': url,
        'headers': headers,
        'locale': locale.code,
      };
}

abstract class AnimeExtractor extends BaseExtractorPlugin<SearchInfo> {
  Future<AnimeInfo> getInfo(
    final String url, {
    required final LanguageCodes locale,
  });

  Future<List<EpisodeSource>> getSources(final EpisodeInfo episode);
}
