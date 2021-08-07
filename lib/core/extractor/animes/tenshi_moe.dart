import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import '../../models/languages.dart' show LanguageCodes;
import '../../utils.dart' as utils;
import './model.dart';

const _defaultLocale = LanguageCodes.en;

class TenshiMoe implements AnimeExtractor {
  @override
  final name = 'Tenshi.moe';

  @override
  final defaultLocale = _defaultLocale;

  @override
  final baseURL = 'https://tenshi.moe';

  late final Map<String, String> defaultHeaders = {
    'User-Agent': utils.Http.userAgent,
    'Referer': baseURL,
  };

  String searchURL(String terms) => '$baseURL/anime?q=$terms';

  @override
  search(
    terms, {
    required locale,
  }) async {
    try {
      final res = await http.get(
        Uri.parse(utils.Fns.tryEncodeURL(searchURL(terms))),
        headers: {
          ...defaultHeaders,
          'cookie': 'loop-view=thumb;',
        },
      ).timeout(utils.Http.timeout);
      final document = html.parse(res.body);
      return document
          .querySelectorAll('.anime-loop li')
          .map(
            (x) {
              final link = x.querySelector('a');
              final title = link?.querySelector('.thumb-title')?.text.trim();
              final url = link?.attributes['href']?.trim();
              final thumbnail =
                  link?.querySelector('.image')?.attributes['src']?.trim();
              if (title != null && url != null) {
                return SearchInfo(
                  title: title,
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
      final estimated = document
          .querySelector('.entry-episodes .badge.badge-secondary.align-top')
          ?.text
          .trim();

      if (estimated is! String) {
        throw AssertionError('Improper episodes information');
      }

      final trimmedURL =
          url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      final episodes = List.generate(int.parse(estimated), (i) {
        final x = (i + 1).toString();
        return EpisodeInfo(
          episode: x,
          url: '$trimmedURL/$x',
          locale: locale,
        );
      });

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

      final iframe = RegExp(r'<iframe src="(.*?)"').firstMatch(res.body)?[1];
      if (iframe is! String) {
        throw AssertionError('Improper episode information');
      }

      final epHeaders = {
        ...defaultHeaders,
        'Referer': episode.url,
      };
      final ifRes = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(iframe)),
            headers: epHeaders,
          )
          .timeout(utils.Http.timeout);
      final document = html.parse(ifRes.body);
      return document
          .querySelectorAll('#player source')
          .map((x) {
            final src = x.attributes['src'];
            final quality = x.attributes['title'];
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
