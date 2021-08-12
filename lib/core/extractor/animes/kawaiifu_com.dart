import 'package:collection/collection.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import './model.dart';
import '../../../plugins/helpers/utils/http.dart';
import '../../models/languages.dart' show LanguageCodes;

const LanguageCodes _defaultLocale = LanguageCodes.en;

class KawaiifuCom implements AnimeExtractor {
  @override
  final String name = 'Kawaiifu.com';

  @override
  final LanguageCodes defaultLocale = _defaultLocale;

  @override
  final String baseURL = 'https://kawaiifu.com';

  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': HttpUtils.userAgent,
    'Referer': baseURL,
  };

  String searchURL(final String terms) =>
      '$baseURL/search-movie?keyword=$terms';

  @override
  Future<List<SearchInfo>> search(
    final String terms, {
    required final LanguageCodes locale,
  }) async {
    try {
      final http.Response res = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(searchURL(terms))),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final dom.Document document = html.parse(res.body);
      return document
          .querySelectorAll('.today-update .item')
          .map(
            (final dom.Element x) {
              final String? title =
                  x.querySelectorAll('.info h4 a').lastOrNull?.text.trim();
              final String? url =
                  x.querySelector('.thumb')?.attributes['href']?.trim();
              final String? thumbnail =
                  x.querySelector('img')?.attributes['src']?.trim();

              if (title != null && url != null) {
                return SearchInfo(
                  title: title,
                  url: url,
                  thumbnail: thumbnail != null
                      ? ImageInfo(
                          url: thumbnail,
                          headers: defaultHeaders,
                        )
                      : null,
                  locale: locale,
                );
              }
            },
          )
          .whereType<SearchInfo>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AnimeInfo> getInfo(
    final String url, {
    final LanguageCodes locale = _defaultLocale,
  }) async {
    try {
      final http.Response res = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(url)),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final dom.Document document = html.parse(res.body);
      final String? server = document
          .querySelectorAll('.list-server')
          .firstWhereOrNull(
            (final dom.Element x) =>
                (x.attributes['style'] ?? '').contains('display: none') ==
                false,
          )
          ?.querySelector('a')
          ?.attributes['href']
          ?.trim();

      if (server is! String) {
        throw AssertionError('Improper server information');
      }

      final http.Response sevRes = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(server)),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final List<EpisodeInfo> episodes = html
          .parse(sevRes.body)
          .querySelectorAll('.list-ep')
          .firstWhere(
            (final dom.Element x) =>
                (x.attributes['style'] ?? '').contains('display: none') ==
                false,
          )
          .querySelectorAll('a')
          .map(
            (final dom.Element x) {
              final String? url = x.attributes['href']?.trim();
              if (url != null) {
                return EpisodeInfo(
                  episode: x.text.replaceFirst('Ep', '').trim(),
                  url: url,
                  locale: locale,
                );
              }
            },
          )
          .whereType<EpisodeInfo>()
          .toList();

      final String? thumbnail =
          document.querySelector('.row .thumb img')?.attributes['src']?.trim();
      return AnimeInfo(
        title: document.querySelector('.desc h2.title')?.text.trim() ??
            document.querySelector('.desc .sub-title')?.text.trim() ??
            '',
        url: url,
        thumbnail: thumbnail != null
            ? ImageInfo(
                url: thumbnail,
                headers: defaultHeaders,
              )
            : null,
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
    try {
      final http.Response res = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(episode.url)),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final dom.Document document = html.parse(res.body);
      final List<EpisodeSource> sources = <EpisodeSource>[];

      final dom.Element? source = document.querySelector('.player source');
      final String? src = source?.attributes['src'];
      if (source != null && src != null) {
        sources.add(
          EpisodeSource(
            url: src,
            quality: resolveQuality(source.attributes['data-quality'] ?? ''),
            headers: defaultHeaders,
            locale: episode.locale,
          ),
        );
      }

      return sources;
    } catch (e) {
      rethrow;
    }
  }
}
