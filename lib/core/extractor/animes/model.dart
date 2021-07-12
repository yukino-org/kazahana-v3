class SearchInfo {
  String title;
  String url;
  String? thumbnail;

  SearchInfo({required this.url, required this.title, this.thumbnail});

  Map<String, dynamic> toJson() =>
      {'title': title, 'url': url, 'thumbnail': thumbnail};
}

class EpisodeInfo {
  String episode;
  String url;

  EpisodeInfo({required this.episode, required this.url});

  Map<String, dynamic> toJson() => {'episode': episode, 'url': url};
}

class AnimeInfo {
  String title;
  String url;
  List<EpisodeInfo> episodes;
  String? thumbnail;

  AnimeInfo(
      {required this.url,
      required this.title,
      required this.episodes,
      this.thumbnail});

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'episodes': episodes.map((x) => x.toJson()).toList()
      };
}

class EpisodeSource {
  String url;
  String quality;
  Map<String, String> headers;

  EpisodeSource(
      {required this.url, required this.quality, this.headers = const {}});

  Map<String, dynamic> toJson() =>
      {'quality': quality, 'url': url, 'headers': headers};
}

abstract class AnimeExtractor {
  Future<List<SearchInfo>> search(String terms);
  Future<AnimeInfo> getInfo(String url);
  Future<List<EpisodeSource>> getSources(String url);
}
