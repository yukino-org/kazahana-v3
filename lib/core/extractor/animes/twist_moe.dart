import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:http/http.dart' as http;
import './model.dart';
import '../../../plugins/helpers/utils/crypto.dart';
import '../../../plugins/helpers/utils/http.dart';
import '../../models/languages.dart' show LanguageCodes;

const LanguageCodes _defaultLocale = LanguageCodes.en;
const String _twistDecryptKey = '267041df55ca2b36f2e322d05ee2c9cf';
const String _twistAccessToken = '0df14814b9e590a1f26d3071a4ed7974';

class TwistSearchInfo extends SearchInfo {
  TwistSearchInfo(
    final String url,
    final String title, {
    required final LanguageCodes locale,
    final String? thumbnail,
    final this.altTitle,
  }) : super(
          url: url,
          title: title,
          thumbnail: thumbnail != null
              ? ImageInfo(
                  url: thumbnail,
                  headers: <String, String>{
                    'User-Agent': HttpUtils.userAgent,
                  },
                )
              : null,
          locale: locale,
        );

  final String? altTitle;
}

class TwistEpisodeSource {
  TwistEpisodeSource({
    required final this.episode,
    required final this.source,
    required final this.headers,
    required final this.locale,
  });

  final int episode;
  final String source;
  final Map<String, String> headers;
  final LanguageCodes locale;

  EpisodeSource? cachedSource;

  EpisodeSource getSource() {
    if (cachedSource == null) {
      final String decrypted =
          CryptoUtils.decryptCryptoJsAES(source, _twistDecryptKey);
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
  final String name = 'Twist.moe';

  @override
  final LanguageCodes defaultLocale = _defaultLocale;

  @override
  final String baseURL = 'https://twist.moe';

  final String apiURL = 'https://api.twist.moe/api';

  Fuzzy<TwistSearchInfo>? searcher;
  final Map<String, List<TwistEpisodeSource>> animeSourceCache =
      <String, List<TwistEpisodeSource>>{};
  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': HttpUtils.userAgent,
    'Referer': baseURL,
    'x-access-token': _twistAccessToken,
  };

  String searchApiURL() => '$apiURL/anime';
  String animeURL(final String slug) => '$baseURL/a/$slug';
  String animeApiURL(final String slug) => '$apiURL/anime/$slug';
  String animeSourcesURL(final String slug) => '${animeApiURL(slug)}/sources';

  String? extractSlugFromURL(final String url) =>
      RegExp(r'https?:\/\/twist\.moe\/a\/([^\/]+)').firstMatch(url)?[1];

  @override
  Future<List<SearchInfo>> search(
    final String terms, {
    required final LanguageCodes locale,
  }) async {
    if (searcher == null) {
      try {
        final http.Response res = await http
            .get(
              Uri.parse(HttpUtils.tryEncodeURL(searchApiURL())),
              headers: defaultHeaders,
            )
            .timeout(HttpUtils.timeout);

        final List<TwistSearchInfo> animes =
            (json.decode(res.body) as List<dynamic>)
                .map(
                  (final dynamic x) => TwistSearchInfo(
                    animeURL(x['slug']['slug'] as String),
                    x['title'] as String,
                    locale: locale,
                  ),
                )
                .whereType<TwistSearchInfo>()
                .toList();

        searcher = Fuzzy<TwistSearchInfo>(
          animes,
          options: FuzzyOptions<TwistSearchInfo>(
            keys: <WeightedKey<TwistSearchInfo>>[
              WeightedKey<TwistSearchInfo>(
                name: 'title',
                getter: (final TwistSearchInfo x) => x.title,
                weight: 2,
              ),
              WeightedKey<TwistSearchInfo>(
                name: 'altTitle',
                getter: (final TwistSearchInfo x) => x.altTitle ?? '',
                weight: 1,
              ),
            ],
          ),
        );
      } catch (e) {
        rethrow;
      }
    }

    return searcher!
        .search(terms, 10)
        .map((final Result<TwistSearchInfo> x) => x.item)
        .toList();
  }

  @override
  Future<AnimeInfo> getInfo(
    final String url, {
    final LanguageCodes locale = _defaultLocale,
  }) async {
    final String? slug = extractSlugFromURL(url);
    if (slug is! String) {
      throw AssertionError('Failed to parse slug from URL');
    }

    try {
      final http.Response res = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(animeApiURL(slug))),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final Map<dynamic, dynamic> parsed =
          json.decode(res.body) as Map<dynamic, dynamic>;
      final String animeURLP = animeURL(slug);
      final List<EpisodeInfo> episodes = (parsed['episodes'] as List<dynamic>)
          .cast<Map<dynamic, dynamic>>()
          .map(
            (final Map<dynamic, dynamic> x) => EpisodeInfo(
              episode: (x['number'] as int).toString(),
              url: '$animeURLP/${x['number']}',
              locale: locale,
            ),
          )
          .whereType<EpisodeInfo>()
          .toList();

      return AnimeInfo(
        url: animeURLP,
        title: parsed['title'] as String,
        episodes: episodes,
        locale: locale,
        availableLocales: <LanguageCodes>[
          defaultLocale,
        ],
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<EpisodeSource>> getSources(final EpisodeInfo episode) async {
    final String? slug = extractSlugFromURL(episode.url);
    if (slug is! String) {
      throw AssertionError('Failed to parse slug from URL');
    }

    final int? number =
        int.tryParse(RegExp(r'\d+$').stringMatch(episode.url) ?? '1');
    if (number is! int) {
      throw AssertionError('Failed to parse episode from URL');
    }

    if (animeSourceCache[slug] == null) {
      try {
        final http.Response res = await http
            .get(
              Uri.parse(HttpUtils.tryEncodeURL(animeSourcesURL(slug))),
              headers: defaultHeaders,
            )
            .timeout(HttpUtils.timeout);

        animeSourceCache[slug] = (json.decode(res.body) as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .map(
              (final Map<dynamic, dynamic> x) => TwistEpisodeSource(
                episode: x['number'] as int,
                source: x['source'] as String,
                headers: <String, String>{
                  'Referer': '$baseURL/a/$slug/${x['number']}',
                  'User-Agent': HttpUtils.userAgent
                },
                locale: episode.locale,
              ),
            )
            .whereType<TwistEpisodeSource>()
            .toList();
      } catch (e) {
        rethrow;
      }
    }

    final TwistEpisodeSource? source = animeSourceCache[slug]
        ?.firstWhereOrNull((final TwistEpisodeSource x) => x.episode == number);
    if (source is! TwistEpisodeSource) {
      throw AssertionError('Failed to find source for the episode');
    }

    return <EpisodeSource>[
      source.getSource(),
    ];
  }
}
