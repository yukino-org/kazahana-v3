import '../../models/languages.dart' show LanguageCodes, LanguageName;
import '../model.dart';
import './sources/model.dart' show RetrievedSource;

enum Qualities {
  q_144p,
  q_360p,
  q_480p,
  q_720p,
  q_1080p,
  unknown,
}

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

final quality = [
  Quality(Qualities.q_144p, '144p', 'sd'),
  Quality(Qualities.q_360p, '360p', 'sd'),
  Quality(Qualities.q_480p, '480p', 'sd'),
  Quality(Qualities.q_720p, '720p', 'hd'),
  Quality(Qualities.q_1080p, '1080p', 'fhd'),
  Quality(Qualities.unknown, 'unknown', '?'),
].asMap().map(
      (k, x) => MapEntry(x.quality, x),
    );

Quality getQuality(Qualities q) => quality[q]!;

class SearchInfo extends BaseSearchInfo {
  LanguageCodes locale;

  SearchInfo({
    required String url,
    required String title,
    String? thumbnail,
    required this.locale,
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
  String episode;
  String url;
  LanguageCodes locale;

  EpisodeInfo({
    required this.episode,
    required this.url,
    required this.locale,
  });

  Map<String, dynamic> toJson() => {
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
  final List<LanguageCodes> availableLocales;

  AnimeInfo({
    required this.url,
    required this.title,
    required this.episodes,
    this.thumbnail,
    required this.locale,
    required this.availableLocales,
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
    required this.url,
    required this.quality,
    this.headers = const {},
    required this.locale,
  });

  factory EpisodeSource.fromRetrievedSource({
    required RetrievedSource retrieved,
    required LanguageCodes locale,
  }) {
    return EpisodeSource(
      url: retrieved.url,
      headers: retrieved.headers,
      quality: retrieved.quality,
      locale: locale,
    );
  }

  Map<String, dynamic> toJson() => {
        'quality': quality.code,
        'url': url,
        'headers': headers,
        'locale': locale.code,
      };
}

abstract class AnimeExtractor extends BaseExtractorPlugin<SearchInfo> {
  LanguageCodes get defaultLocale;

  Future<AnimeInfo> getInfo(
    String url, {
    required LanguageCodes locale,
  });

  Future<List<EpisodeSource>> getSources(EpisodeInfo episode);
}
