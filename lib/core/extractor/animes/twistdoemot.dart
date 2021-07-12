import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fuzzy/fuzzy.dart';
import '../../utils.dart' as utils;
import './model.dart';

const twistDecryptKey = '267041df55ca2b36f2e322d05ee2c9cf';

class TwistSearchInfo extends SearchInfo {
  final String? altTitle;

  TwistSearchInfo(String url, String title, {String? thumbnail, this.altTitle})
      : super(url: url, title: title, thumbnail: thumbnail);
}

class TwistEpisodeSource {
  final int episode;
  final String source;
  final Map<String, String> headers;

  EpisodeSource? cachedSource;

  TwistEpisodeSource(
      {required this.episode, required this.source, required this.headers});

  EpisodeSource getSource() {
    if (cachedSource == null) {
      final decrypted =
          utils.Crypto.decryptCryptoJsAES(source, twistDecryptKey);
      cachedSource = EpisodeSource(
        url: 'https://cdn.twist.moe$decrypted',
        quality: 'unknown',
        headers: headers,
      );
    }

    return cachedSource!;
  }
}

class TwistMoe implements AnimeExtractor {
  final baseURL = 'https://twist.moe';
  final apiURL = 'https://api.twist.moe/api';

  Fuzzy<TwistSearchInfo>? searcher;
  final Map<String, List<TwistEpisodeSource>> animeSourceCache = {};
  final Map<String, String> defaultHeaders = {
    'User-Agent': utils.Http.userAgent,
    'Referer': 'https://twist.moe/',
    'x-access-token': '0df14814b9e590a1f26d3071a4ed7974'
  };

  String searchApiURL() => '$apiURL/anime';
  String animeURL(String slug) => '$baseURL/a/$slug';
  String animeApiURL(String slug) => '$apiURL/anime/$slug';
  String animeSourcesURL(String slug) => '${animeApiURL(slug)}/sources';

  String? extractSlugFromURL(String url) =>
      RegExp(r'https:\/\/twist\.moe\/a\/([\d\w-_]+)\/?').firstMatch(url)?[1];

  @override
  Future<List<SearchInfo>> search(final String terms) async {
    if (searcher == null) {
      try {
        final res = await http.get(
          Uri.parse(Uri.encodeFull(searchApiURL())),
          headers: defaultHeaders,
        );
        final animes = json
            .decode(res.body)
            .cast<dynamic>()
            .map(
                (x) => TwistSearchInfo(animeURL(x['slug']['slug']), x['title']))
            .toList()
            .cast<TwistSearchInfo>();
        searcher = Fuzzy<TwistSearchInfo>(
          animes,
          options: FuzzyOptions(
            shouldSort: true,
            keys: [
              WeightedKey(name: 'title', getter: (x) => x.title, weight: 2),
              WeightedKey(
                name: 'altTitle',
                getter: (x) => x.altTitle ?? '',
                weight: 1,
              ),
            ],
          ),
        );
      } catch (e) {
        rethrow;
      }
    }

    return searcher!.search(terms, 10).map((x) => x.item).toList();
  }

  @override
  Future<AnimeInfo> getInfo(String url) async {
    final slug = extractSlugFromURL(url);
    if (slug == null) throw ('Failed to parse slug from URL');

    try {
      final res = await http.get(
        Uri.parse(Uri.encodeFull(animeApiURL(slug))),
        headers: defaultHeaders,
      );

      final parsed = json.decode(res.body);

      final animeURLP = animeURL(slug);
      final episodes = (parsed['episodes'])
          .cast<dynamic>()
          .map(
            (x) => EpisodeInfo(
              episode: (x['number'] as int).toString(),
              url: '$animeURLP/${x['number']}',
            ),
          )
          .toList()
          .cast<EpisodeInfo>();
      return AnimeInfo(
        url: animeURLP,
        title: (parsed['title'] as String),
        episodes: episodes,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<EpisodeSource>> getSources(String url) async {
    final slug = extractSlugFromURL(url);
    if (slug == null) throw ('Failed to parse slug from URL');

    final episode = int.tryParse(RegExp(r'\d+$').stringMatch(url) ?? '1');
    if (episode == null) throw ('Failed to parse episode from URL');

    if (animeSourceCache[slug] == null) {
      try {
        final res = await http.get(
          Uri.parse(Uri.encodeFull(animeSourcesURL(slug))),
          headers: defaultHeaders,
        );

        animeSourceCache[slug] = (json.decode(res.body) as List<dynamic>)
            .map(
              (x) => TwistEpisodeSource(
                episode: x['number'],
                source: x['source'],
                headers: {
                  'Referer': '$baseURL/a/$slug/${x['number']}',
                  'User-Agent': utils.Http.userAgent
                },
              ),
            )
            .toList()
            .cast<TwistEpisodeSource>();
      } catch (e) {
        rethrow;
      }
    }

    final source =
        animeSourceCache[slug]?.firstWhere((x) => x.episode == episode);
    if (source == null) throw ('Failed to find source for the episode');

    return [source.getSource()];
  }
}
