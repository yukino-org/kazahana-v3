import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import './model.dart';
import '../../models/languages.dart' show LanguageCodes;
import '../../utils.dart' as utils;

const LanguageCodes _defaultLocale = LanguageCodes.en;

class AnimePradiseOrg implements AnimeExtractor {
  @override
  final String name = 'AnimeParadise.org';

  @override
  final LanguageCodes defaultLocale = _defaultLocale;

  @override
  final String baseURL = 'https://animeparadise.org';

  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': utils.Http.userAgent,
    'Referer': baseURL,
  };

  String searchURL(final String terms) => '$baseURL/search.php?query=$terms';

  @override
  Future<List<SearchInfo>> search(
    final String terms, {
    required final LanguageCodes locale,
  }) async {
    try {
      final http.Response res = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(searchURL(terms))),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);
      final dom.Document document = html.parse(res.body);
      return document
          .querySelectorAll('.media')
          .map(
            (final dom.Element x) {
              final dom.Element? link = x.querySelector('a');
              final String? title = link?.text.trim();
              final String? url = link?.attributes['href']?.trim();
              final String? thumbnail =
                  x.querySelector('img')?.attributes['src']?.trim();
              final List<String> tags = x
                  .querySelectorAll('.tag')
                  .map((final dom.Element x) => '(${x.text.trim()})')
                  .toList();

              if (title != null && url != null) {
                return SearchInfo(
                  title: '$title ${tags.join(' ')}'.trim(),
                  url: '$baseURL/$url',
                  thumbnail: thumbnail,
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
            Uri.parse(utils.Fns.tryEncodeURL(url)),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);

      final dom.Document document = html.parse(res.body);
      final List<EpisodeInfo> episodes = document
          .querySelectorAll('.container .columns a.box')
          .map(
            (final dom.Element x) {
              final String? episode = x.querySelector('.title')?.text.trim();
              final String? url = x.attributes['href']?.trim();
              if (episode != null && url != null) {
                return EpisodeInfo(
                  episode: episode,
                  url: '$baseURL/$url',
                  locale: locale,
                );
              }
            },
          )
          .whereType<EpisodeInfo>()
          .toList();

      final List<String> tags = document
          .querySelectorAll('.column > .tag')
          .map((final dom.Element x) => '(${x.text.trim()})')
          .toList();

      return AnimeInfo(
        title:
            '${document.querySelector('.column strong')?.text.trim()} ${tags.join(' ')}'
                .trim(),
        url: url,
        thumbnail: document
            .querySelector('.column.is-one-fifth img')
            ?.attributes['src']
            ?.trim(),
        episodes: episodes,
        locale: locale,
        availableLocales: <LanguageCodes>[
          _defaultLocale,
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
            Uri.parse(utils.Fns.tryEncodeURL(episode.url)),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);

      final dom.Document document = html.parse(res.body);
      return document
          .querySelectorAll('video source')
          .map(
            (final dom.Element x) {
              final String? src = x.attributes['src']?.trim();
              if (src != null) {
                return EpisodeSource(
                  url: src,
                  quality: getQuality(Qualities.unknown),
                  headers: defaultHeaders,
                  locale: episode.locale,
                );
              }
            },
          )
          .whereType<EpisodeSource>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
