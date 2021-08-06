import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import '../../models/languages.dart' show LanguageCodes;
import '../../utils.dart' as utils;
import './sources/sources.dart';
import './model.dart';

const _defaultLocale = LanguageCodes.en;

class GogoAnimePe implements AnimeExtractor {
  @override
  final name = 'GogoAnime.pe';

  @override
  final defaultLocale = _defaultLocale;

  @override
  final baseURL = 'https://gogoanime.pe';

  late final Map<String, String> defaultHeaders = {
    'User-Agent': utils.Http.userAgent,
    'Referer': baseURL,
  };

  String searchURL(String terms) => '$baseURL/search.html?keyword=$terms';
  String episodeApiURL({
    required String start,
    required String end,
    required String id,
  }) {
    final reverse = (int.tryParse(start) ?? 0) > (int.tryParse(end) ?? 0);
    final s = reverse ? end : start;
    final e = reverse ? start : end;
    return 'https://ajax.gogo-load.com/ajax/load-list-episode?ep_start=$s&ep_end=$e&id=$id';
  }

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
          .querySelectorAll('.items li')
          .map(
            (x) {
              final title = x.querySelector('.name a');
              final url = title?.attributes['href']?.trim();
              final thumbnail =
                  x.querySelector('.img img')?.attributes['src']?.trim();

              if (title != null && url != null) {
                return SearchInfo(
                  title: title.text.trim(),
                  url: '$baseURL$url',
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

      final epPages = document.querySelectorAll('#episode_page a');
      final epStart = epPages.first.attributes['ep_start']?.trim();
      final epEnd = epPages.last.attributes['ep_end']?.trim();
      final epId =
          document.querySelector('input#movie_id')?.attributes['value']?.trim();

      if (epStart is! String || epEnd is! String || epId is! String) {
        throw AssertionError('Improper episode information');
      }

      final epRes = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(episodeApiURL(
              start: epStart,
              end: epEnd,
              id: epId,
            ))),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);

      final episodes = html
          .parse(epRes.body)
          .querySelectorAll('#episode_related a')
          .map(
            (x) {
              final episode = x.querySelector('.name');
              final url = x.attributes['href']?.trim();
              if (episode != null && url != null) {
                return EpisodeInfo(
                  episode: episode.text.replaceFirst('EP', '').trim(),
                  url: '$baseURL$url',
                  locale: locale,
                );
              }
            },
          )
          .whereType<EpisodeInfo>()
          .toList();

      return AnimeInfo(
        title:
            document.querySelector('.anime_info_body_bg h1')?.text.trim() ?? '',
        url: url,
        thumbnail: document
            .querySelector('.anime_info_body_bg img')
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

      final links = document
          .querySelectorAll('.anime_muti_link a')
          .map((x) => x.attributes['data-video'])
          .whereType<String>();

      final List<EpisodeSource> sources = [];
      for (var src in links) {
        src = utils.Fns.ensureProtocol(src);
        final retriever = SourceRetrievers.match(src);
        if (retriever != null) {
          try {
            final retrieved = await retriever.fetch(src);
            sources.addAll(
              retrieved.map(
                (x) => EpisodeSource.fromRetrievedSource(
                  retrieved: x,
                  locale: episode.locale,
                ),
              ),
            );
          } catch (_) {}
        }
      }

      return sources;
    } catch (e) {
      rethrow;
    }
  }
}
