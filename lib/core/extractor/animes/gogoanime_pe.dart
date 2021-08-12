import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import './model.dart';
import './sources/model.dart';
import './sources/sources.dart';
import '../../../plugins/helpers/utils/http.dart';
import '../../models/languages.dart' show LanguageCodes;

const LanguageCodes _defaultLocale = LanguageCodes.en;

class GogoAnimePe implements AnimeExtractor {
  @override
  final String name = 'GogoAnime.pe';

  @override
  final LanguageCodes defaultLocale = _defaultLocale;

  @override
  final String baseURL = 'https://gogoanime.pe';

  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': HttpUtils.userAgent,
    'Referer': baseURL,
  };

  String searchURL(final String terms) => '$baseURL/search.html?keyword=$terms';
  String episodeApiURL({
    required final String start,
    required final String end,
    required final String id,
  }) {
    final bool reverse = (int.tryParse(start) ?? 0) > (int.tryParse(end) ?? 0);
    final String s = reverse ? end : start;
    final String e = reverse ? start : end;
    return 'https://ajax.gogo-load.com/ajax/load-list-episode?ep_start=$s&ep_end=$e&id=$id';
  }

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
          .querySelectorAll('.items li')
          .map(
            (final dom.Element x) {
              final dom.Element? title = x.querySelector('.name a');
              final String? url = title?.attributes['href']?.trim();
              final String? thumbnail =
                  x.querySelector('.img img')?.attributes['src']?.trim();

              if (title != null && url != null) {
                return SearchInfo(
                  title: title.text.trim(),
                  url: '$baseURL$url',
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

      final List<dom.Element> epPages =
          document.querySelectorAll('#episode_page a');
      final String? epStart = epPages.first.attributes['ep_start']?.trim();
      final String? epEnd = epPages.last.attributes['ep_end']?.trim();
      final String? epId =
          document.querySelector('input#movie_id')?.attributes['value']?.trim();

      if (epStart is! String || epEnd is! String || epId is! String) {
        throw AssertionError('Improper episode information');
      }

      final http.Response epRes = await http
          .get(
            Uri.parse(
              HttpUtils.tryEncodeURL(
                episodeApiURL(
                  start: epStart,
                  end: epEnd,
                  id: epId,
                ),
              ),
            ),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final List<EpisodeInfo> episodes = html
          .parse(epRes.body)
          .querySelectorAll('#episode_related a')
          .map(
            (final dom.Element x) {
              final String? episode =
                  x.querySelector('.name')?.text.replaceFirst('EP', '').trim();
              final String? url = x.attributes['href']?.trim();
              if (episode != null && url != null) {
                return EpisodeInfo(
                  episode: episode,
                  url: '$baseURL$url',
                  locale: locale,
                );
              }
            },
          )
          .whereType<EpisodeInfo>()
          .toList();

      final String? thumbnail = document
          .querySelector('.anime_info_body_bg img')
          ?.attributes['src']
          ?.trim();
      return AnimeInfo(
        title:
            document.querySelector('.anime_info_body_bg h1')?.text.trim() ?? '',
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
      final Iterable<String> links = document
          .querySelectorAll('.anime_muti_link a')
          .map((final dom.Element x) => x.attributes['data-video'])
          .whereType<String>();

      final List<EpisodeSource> sources = <EpisodeSource>[];
      for (final String _src in links) {
        final String src = HttpUtils.ensureProtocol(_src);
        final SourceRetriever? retriever = SourceRetrievers.match(src);
        if (retriever != null) {
          try {
            final List<RetrievedSource> retrieved = await retriever.fetch(src);
            sources.addAll(
              retrieved.map(
                (final RetrievedSource x) => EpisodeSource.fromRetrievedSource(
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
