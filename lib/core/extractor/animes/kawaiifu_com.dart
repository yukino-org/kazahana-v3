import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:collection/collection.dart';
import '../../models/languages.dart' show LanguageCodes;
import '../../utils.dart' as utils;
import './model.dart';

const _defaultLocale = LanguageCodes.en;

class KawaiifuCom implements AnimeExtractor {
  @override
  final name = 'Kawaiifu.com';

  @override
  final defaultLocale = _defaultLocale;

  @override
  final baseURL = 'https://kawaiifu.com';

  late final Map<String, String> defaultHeaders = {
    'User-Agent': utils.Http.userAgent,
    'Referer': baseURL,
  };

  String searchURL(String terms) => '$baseURL/search-movie?keyword=$terms';

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
          .querySelectorAll('.today-update .item')
          .map(
            (x) {
              final thumb = x.querySelector('.thumb');
              final url = thumb?.attributes['href']?.trim();
              final thumbnail =
                  x.querySelector('img')?.attributes['src']?.trim();
              final title = x.querySelectorAll('.info h4 a').lastOrNull;

              if (title != null && url != null) {
                return SearchInfo(
                  title: title.text.trim(),
                  url: url,
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
      final server = document
          .querySelectorAll('.list-server')
          .firstWhereOrNull((x) =>
              (x.attributes['style'] ?? '').contains('display: none') == false)
          ?.querySelector('a')
          ?.attributes['href']
          ?.trim();

      if (server is! String) {
        throw AssertionError('Improper server information');
      }

      final sevRes = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(server)),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);

      final episodes = html
          .parse(sevRes.body)
          .querySelectorAll('.list-ep')
          .firstWhere((x) =>
              (x.attributes['style'] ?? '').contains('display: none') == false)
          .querySelectorAll('a')
          .map(
            (x) {
              final url = x.attributes['href']?.trim();
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

      return AnimeInfo(
        title: document.querySelector('.desc h2.title')?.text.trim() ??
            document.querySelector('.desc .sub-title')?.text.trim() ??
            '',
        url: url,
        thumbnail: document
            .querySelector('.row .thumb img')
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
      List<EpisodeSource> sources = [];

      final source = document.querySelector('.player source');
      final src = source?.attributes['src'];
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
