import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import '../../models/languages.dart' show LanguageCodes;
import '../../utils.dart' as utils;
import './model.dart';

const _defaultLocale = LanguageCodes.en;

class AnimePradiseOrg implements AnimeExtractor {
  @override
  final name = 'AnimeParadise.org';

  @override
  final defaultLocale = _defaultLocale;

  @override
  final baseURL = 'https://animeparadise.org';

  late final Map<String, String> defaultHeaders = {
    'User-Agent': utils.Http.userAgent,
    'Referer': baseURL,
  };

  String searchURL(String terms) => '$baseURL/search.php?query=$terms';

  @override
  search(
    terms, {
    required locale,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(searchURL(terms))),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);
      final document = html.parse(res.body);
      return document
          .querySelectorAll('.media')
          .map(
            (x) {
              final link = x.querySelector('a');
              final title = link?.text.trim();
              final url = link?.attributes['href']?.trim();
              final thumbnail =
                  x.querySelector('img')?.attributes['src']?.trim();
              final tags = x
                  .querySelectorAll('.tag')
                  .map((x) => '(${x.text.trim()})')
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
  getInfo(
    url, {
    locale = _defaultLocale,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(url)),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);

      final document = html.parse(res.body);
      final episodes = document
          .querySelectorAll('.container .columns a.box')
          .map(
            (x) {
              final episode = x.querySelector('.title')?.text.trim();
              final url = x.attributes['href']?.trim();
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

      final tags = document
          .querySelectorAll('.column > .tag')
          .map((x) => '(${x.text.trim()})')
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
    try {
      final res = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(episode.url)),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);
      final document = html.parse(res.body);
      return document
          .querySelectorAll('video source')
          .map(
            (x) {
              final src = x.attributes['src']?.trim();
              if (src != null) {
                return EpisodeSource(
                  url: src,
                  quality: getQuality(Qualities.unknown),
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
