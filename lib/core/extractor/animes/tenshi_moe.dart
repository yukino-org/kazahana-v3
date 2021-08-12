import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import './model.dart';
import '../../../plugins/helpers/utils/http.dart';
import '../../models/languages.dart' show LanguageCodes;

const LanguageCodes _defaultLocale = LanguageCodes.en;

class TenshiMoe implements AnimeExtractor {
  @override
  final String name = 'Tenshi.moe';

  @override
  final LanguageCodes defaultLocale = _defaultLocale;

  @override
  final String baseURL = 'https://tenshi.moe';

  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': HttpUtils.userAgent,
    'Referer': baseURL,
  };

  String searchURL(final String terms) => '$baseURL/anime?q=$terms';

  @override
  Future<List<SearchInfo>> search(
    final String terms, {
    required final LanguageCodes locale,
  }) async {
    try {
      final http.Response res = await http.get(
        Uri.parse(HttpUtils.tryEncodeURL(searchURL(terms))),
        headers: <String, String>{
          ...defaultHeaders,
          'cookie': 'loop-view=thumb;',
        },
      ).timeout(HttpUtils.timeout);

      final dom.Document document = html.parse(res.body);
      return document
          .querySelectorAll('.anime-loop li')
          .map(
            (final dom.Element x) {
              final dom.Element? link = x.querySelector('a');
              final String? title =
                  link?.querySelector('.thumb-title')?.text.trim();
              final String? url = link?.attributes['href']?.trim();
              final String? thumbnail =
                  link?.querySelector('.image')?.attributes['src']?.trim();

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
      final String? estimated = document
          .querySelector('.entry-episodes .badge.badge-secondary.align-top')
          ?.text
          .trim();

      if (estimated is! String) {
        throw AssertionError('Improper episodes information');
      }

      final String trimmedURL =
          url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      final List<EpisodeInfo> episodes = List<EpisodeInfo>.generate(
        int.parse(estimated),
        (final int i) {
          final String x = (i + 1).toString();
          return EpisodeInfo(
            episode: x,
            url: '$trimmedURL/$x',
            locale: locale,
          );
        },
      );

      final String? thumbnail =
          document.querySelector('img.cover-image')?.attributes['src']?.trim();
      return AnimeInfo(
        title: document.querySelector('.entry-header')?.text.trim() ?? '',
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

      final String? iframe =
          RegExp('<iframe src="(.*?)"').firstMatch(res.body)?[1];
      if (iframe is! String) {
        throw AssertionError('Improper episode information');
      }

      final Map<String, String> epHeaders = <String, String>{
        ...defaultHeaders,
        'Referer': episode.url,
      };
      final http.Response ifRes = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(iframe)),
            headers: epHeaders,
          )
          .timeout(HttpUtils.timeout);

      final dom.Document document = html.parse(ifRes.body);
      return document
          .querySelectorAll('#player source')
          .map((final dom.Element x) {
            final String? src = x.attributes['src'];
            final String? quality = x.attributes['title'];

            if (src != null) {
              return EpisodeSource(
                url: src,
                quality: resolveQuality(quality ?? ''),
                headers: epHeaders,
                locale: episode.locale,
              );
            }
          })
          .whereType<EpisodeSource>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
