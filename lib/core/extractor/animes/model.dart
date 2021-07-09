class SearchInfo {
  String title;
  String url;
  String? thumbnail;

  SearchInfo({required this.url, required this.title, this.thumbnail});
}

class EpisodeInfo {
  String episode;
  String url;

  EpisodeInfo({required this.episode, required this.url});
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
}

class EpisodeSource {
  String url;
  String quality;
  Map<String, String>? headers;

  EpisodeSource(
      {required this.url, required this.quality, this.headers = const {}});
}

abstract class AnimeExtractor {
  Future<List<SearchInfo>> search(String terms);
  Future<AnimeInfo> getInfo(String url);
  Future<List<EpisodeSource>> getSources(String url);
}
