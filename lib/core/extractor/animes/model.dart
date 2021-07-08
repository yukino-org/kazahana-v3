class SearchInfo {
  String title;
  String url;
  String? thumbnail;

  SearchInfo(this.url, this.title, {this.thumbnail});
}

class EpisodeInfo {
  String episode;
  String url;

  EpisodeInfo(this.episode, this.url);
}

class AnimeInfo {
  String title;
  String url;
  List<EpisodeInfo> episodes;
  String? thumbnail;

  AnimeInfo(this.url, this.title, this.episodes, {this.thumbnail});
}

class EpisodeSource {
  String url;
  String quality;
  Map<String, String>? headers;

  EpisodeSource(this.url, this.quality, {this.headers = const {}});
}

abstract class AnimeExtractor {
  Future<List<SearchInfo>> search(String terms);
  Future<AnimeInfo> getInfo(Uri url);
  Future<List<EpisodeSource>> getSources(Uri url);
}
