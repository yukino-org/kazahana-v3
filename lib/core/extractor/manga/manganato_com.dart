import 'dart:convert';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import './model.dart';
import '../../../plugins/helpers/querystring.dart';
import '../../../plugins/helpers/utils/http.dart';
import '../../models/languages.dart';

const LanguageCodes _defaultLocale = LanguageCodes.en;

class MangaNatoCom extends MangaExtractor {
  @override
  final String name = 'MangaNato.com';

  @override
  final LanguageCodes defaultLocale = _defaultLocale;

  @override
  final String baseURL = 'https://manganato.com';

  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': HttpUtils.userAgent,
    'Referer': baseURL,
  };

  String searchURL() => '$baseURL/getstorysearchjson';

  @override
  Future<List<SearchInfo>> search(
    final String terms, {
    required final LanguageCodes locale,
  }) async {
    try {
      final http.Response res = await http.post(
        Uri.parse(HttpUtils.tryEncodeURL(searchURL())),
        body: QueryString.stringify(<String, dynamic>{
          'searchword': terms,
        }),
        headers: <String, String>{
          ...defaultHeaders,
          'Content-Type': HttpUtils.contentTypeURLEncoded,
        },
      ).timeout(HttpUtils.timeout);

      // NOTE: temporary workaround as it responds with invalid 'Content-Type' header
      // Refer: https://github.com/dart-lang/http/issues/180
      final String body = utf8.decode(res.bodyBytes);
      return (json.decode(body) as List<dynamic>)
          .cast<Map<dynamic, dynamic>>()
          .map((final Map<dynamic, dynamic> x) {
            final String? title =
                html.parseFragment(x['name'] as String).text?.trim();
            final String? url = x['link_story'] as String?;
            final String? image = x['image'] as String?;

            if (title != null && url != null) {
              return SearchInfo(
                title: title,
                url: url,
                thumbnail: image != null
                    ? ImageInfo(
                        url: image,
                        headers: defaultHeaders,
                      )
                    : null,
                locale: locale,
              );
            }
          })
          .whereType<SearchInfo>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MangaInfo> getInfo(
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

      final List<ChapterInfo> chapters = document
          .querySelectorAll(
            '.panel-story-chapter-list .row-content-chapter li a',
          )
          .map((final dom.Element x) {
            final String title = x.text.trim();
            final String? url = x.attributes['href']?.trim();

            if (url != null) {
              final String? chap =
                  RegExp(r'Chapter (\d*\.?\d+)').firstMatch(title)?[1]?.trim();
              final String? vol =
                  RegExp(r'Vol\.(\d+)').firstMatch(title)?[1]?.trim();
              String shortTitle = title
                  .replaceAll(RegExp(r'(Vol\.\d+|Chapter \d*\.?\d+)'), '')
                  .trim();
              if (shortTitle.startsWith(':')) {
                shortTitle = shortTitle.substring(1, shortTitle.length);
              }

              if (chap != null) {
                return ChapterInfo(
                  title: shortTitle.isNotEmpty ? shortTitle : null,
                  url: url,
                  volume: vol,
                  chapter: chap,
                  locale: locale,
                );
              }
            }
          })
          .whereType<ChapterInfo>()
          .toList();

      final String? thumbnail =
          document.querySelector('.info-image img')?.attributes['src']?.trim();
      return MangaInfo(
        title:
            document.querySelector('.story-info-right h1')?.text.trim() ?? '',
        url: url,
        thumbnail: thumbnail != null
            ? ImageInfo(
                url: thumbnail,
                headers: defaultHeaders,
              )
            : null,
        chapters: chapters,
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
  Future<List<PageInfo>> getChapter(final ChapterInfo chapter) async {
    try {
      final http.Response res = await http
          .get(
            Uri.parse(
              HttpUtils.tryEncodeURL(chapter.url),
            ),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final dom.Document document = html.parse(res.body);
      return document
          .querySelectorAll('.container-chapter-reader img')
          .map(
            (final dom.Element x) {
              final String? url = x.attributes['src']?.trim();
              if (url != null) {
                return PageInfo(
                  url: url,
                  locale: chapter.locale,
                );
              }
            },
          )
          .whereType<PageInfo>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ImageInfo> getPage(final PageInfo page) async => ImageInfo(
        url: page.url,
        headers: defaultHeaders,
      );
}
