import '../../../plugins/translator/model.dart' show LanguageCodes;

class SearchInfo {
  String title;
  String url;
  String? thumbnail;
  LanguageCodes locale;

  SearchInfo({
    required this.url,
    required this.title,
    this.thumbnail,
    required this.locale,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
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
      };
}

class AnimeInfo {
  String title;
  String url;
  List<EpisodeInfo> episodes;
  String? thumbnail;
  LanguageCodes locale;

  AnimeInfo({
    required this.url,
    required this.title,
    required this.episodes,
    this.thumbnail,
    required this.locale,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'episodes': episodes.map((x) => x.toJson()).toList(),
      };
}

class EpisodeSource {
  String url;
  String quality;
  Map<String, String> headers;
  LanguageCodes locale;

  EpisodeSource({
    required this.url,
    required this.quality,
    this.headers = const {},
    required this.locale,
  });

  Map<String, dynamic> toJson() => {
        'quality': quality,
        'url': url,
        'headers': headers,
      };
}

abstract class AnimeExtractor {
  Future<List<SearchInfo>> search(
    String terms, {
    required LanguageCodes locale,
  });

  Future<AnimeInfo> getInfo(
    String url, {
    required LanguageCodes locale,
  });

  Future<List<EpisodeSource>> getSources(
    String url, {
    required LanguageCodes locale,
  });
}
