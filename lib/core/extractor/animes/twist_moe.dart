import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fuzzy/fuzzy.dart';
import '../../models/languages.dart' show LanguageCodes;
import '../../utils.dart' as utils;
import './model.dart';

const _defaultLocale = LanguageCodes.en;
const _twistDecryptKey = '267041df55ca2b36f2e322d05ee2c9cf';
const _twistAccessToken = '0df14814b9e590a1f26d3071a4ed7974';

class TwistSearchInfo extends SearchInfo {
  final String? altTitle;

  TwistSearchInfo(
    String url,
    String title, {
    String? thumbnail,
    this.altTitle,
    required LanguageCodes locale,
  }) : super(
          url: url,
          title: title,
          thumbnail: thumbnail,
          locale: locale,
        );
}

class TwistEpisodeSource {
  final int episode;
  final String source;
  final Map<String, String> headers;
  final LanguageCodes locale;

  EpisodeSource? cachedSource;

  TwistEpisodeSource({
    required this.episode,
    required this.source,
    required this.headers,
    required this.locale,
  });

  EpisodeSource getSource() {
    if (cachedSource == null) {
      final decrypted =
          utils.Crypto.decryptCryptoJsAES(source, _twistDecryptKey);
      cachedSource = EpisodeSource(
        url: 'https://cdn.twist.moe$decrypted',
        quality: getQuality(Qualities.unknown),
        headers: headers,
        locale: locale,
      );
    }

    return cachedSource!;
  }
}

class TwistMoe implements AnimeExtractor {
  @override
  final name = 'Twist.moe';

  @override
  final defaultLocale = _defaultLocale;

  @override
  final baseURL = 'https://twist.moe';

  final apiURL = 'https://api.twist.moe/api';

  Fuzzy<TwistSearchInfo>? searcher;
  final Map<String, List<TwistEpisodeSource>> animeSourceCache = {};
  late final Map<String, String> defaultHeaders = {
    'User-Agent': utils.Http.userAgent,
    'Referer': baseURL,
    'x-access-token': _twistAccessToken,
  };

  String searchApiURL() => '$apiURL/anime';
  String animeURL(String slug) => '$baseURL/a/$slug';
  String animeApiURL(String slug) => '$apiURL/anime/$slug';
  String animeSourcesURL(String slug) => '${animeApiURL(slug)}/sources';

  String? extractSlugFromURL(String url) =>
      RegExp(r'https?:\/\/twist\.moe\/a\/([^\/]+)').firstMatch(url)?[1];

  @override
  search(
    terms, {
    required locale,
  }) async {
    if (searcher == null) {
      try {
        final res = await http
            .get(
              Uri.parse(utils.Fns.tryEncodeURL(searchApiURL())),
              headers: defaultHeaders,
            )
            .timeout(utils.Http.timeout);
        final animes = json
            .decode(res.body)
            .cast<dynamic>()
            .map(
              (x) {
                return TwistSearchInfo(
                  animeURL(x['slug']['slug']),
                  x['title'],
                  locale: locale,
                );
              },
            )
            .whereType<TwistSearchInfo>()
            .toList();

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
  getInfo(
    url, {
    locale = _defaultLocale,
  }) async {
    final slug = extractSlugFromURL(url);
    if (slug == null) throw ('Failed to parse slug from URL');

    try {
      final res = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(animeApiURL(slug))),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);

      final parsed = json.decode(res.body);

      final animeURLP = animeURL(slug);
      final episodes = (parsed['episodes'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(
            (x) {
              return EpisodeInfo(
                episode: (x['number'] as int).toString(),
                url: '$animeURLP/${x['number']}',
                locale: locale,
              );
            },
          )
          .whereType<EpisodeInfo>()
          .toList();

      return AnimeInfo(
        url: animeURLP,
        title: (parsed['title'] as String),
        episodes: episodes,
        locale: locale,
        availableLocales: [
          _defaultLocale,
        ],
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  getSources(episode) async {
    final slug = extractSlugFromURL(episode.url);
    if (slug == null) throw ('Failed to parse slug from URL');

    final number =
        int.tryParse(RegExp(r'\d+$').stringMatch(episode.url) ?? '1');
    if (number == null) throw ('Failed to parse episode from URL');

    if (animeSourceCache[slug] == null) {
      try {
        final res = await http
            .get(
              Uri.parse(utils.Fns.tryEncodeURL(animeSourcesURL(slug))),
              headers: defaultHeaders,
            )
            .timeout(utils.Http.timeout);

        animeSourceCache[slug] = (json.decode(res.body) as List<dynamic>)
            .map(
              (x) {
                return TwistEpisodeSource(
                  episode: x['number'],
                  source: x['source'],
                  headers: {
                    'Referer': '$baseURL/a/$slug/${x['number']}',
                    'User-Agent': utils.Http.userAgent
                  },
                  locale: episode.locale,
                );
              },
            )
            .whereType<TwistEpisodeSource>()
            .toList();
      } catch (e) {
        rethrow;
      }
    }

    final source =
        animeSourceCache[slug]?.firstWhere((x) => x.episode == number);
    if (source == null) throw ('Failed to find source for the episode');

    return [
      source.getSource(),
    ];
  }
}
