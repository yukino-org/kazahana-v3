import 'dart:convert';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import './model.dart';
import '../../../plugins/helpers/querystring.dart';
import '../../../plugins/helpers/utils/http.dart';
import '../../models/languages.dart';

const LanguageCodes _defaultLocale = LanguageCodes.en;

class ReadMOrg extends MangaExtractor {
  @override
  final String name = 'ReadM.org';

  @override
  final LanguageCodes defaultLocale = _defaultLocale;

  @override
  final String baseURL = 'https://readm.org';

  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': HttpUtils.userAgent,
    'Referer': baseURL,
  };

  String searchURL() => '$baseURL/service/search';

  @override
  Future<List<SearchInfo>> search(
    final String terms, {
    required final LanguageCodes locale,
  }) async {
    try {
      final http.Response res = await http.post(
        Uri.parse(HttpUtils.tryEncodeURL(searchURL())),
        body: QueryString.stringify(<String, dynamic>{
          'dataType': 'json',
          'phrase': terms,
        }),
        headers: <String, String>{
          ...defaultHeaders,
          'Content-Type': HttpUtils.contentTypeURLEncoded,
          'x-requested-with': 'XMLHttpRequest',
        },
      ).timeout(HttpUtils.timeout);

      return (json.decode(res.body)['manga'] as List<dynamic>)
          .cast<Map<dynamic, dynamic>>()
          .map((final Map<dynamic, dynamic> x) {
            final String url = x['url'] as String;
            final String? image = x['image'] as String?;
            return SearchInfo(
              title: x['title'] as String,
              url: '$baseURL$url',
              thumbnail: image != null
                  ? ImageInfo(
                      url: '$baseURL$image',
                      headers: defaultHeaders,
                    )
                  : null,
              locale: locale,
            );
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
            '.episodes-list .table-episodes-title a',
          )
          .map((final dom.Element x) {
            final String title = x.text.trim();
            final String? url = x.attributes['href']?.trim();
            final List<String> chapvol =
                title.replaceFirst('Chapter', '').trim().split('v');

            if (url != null && chapvol.isNotEmpty) {
              return ChapterInfo(
                title: RegExp(r'^Chapter \d*\.?\d+(v\d+)?$').hasMatch(title)
                    ? null
                    : title,
                url: '$baseURL$url',
                volume: chapvol.length >= 2 ? chapvol[1] : null,
                chapter: chapvol.first,
                locale: locale,
              );
            }
          })
          .whereType<ChapterInfo>()
          .toList();

      final String? thumbnail = document
          .querySelector('.series-profile-thumb')
          ?.attributes['src']
          ?.trim();
      return MangaInfo(
        title: document.querySelector('.page-title')?.text.trim() ?? '',
        url: url,
        thumbnail: thumbnail != null
            ? ImageInfo(
                url: '$baseURL$thumbnail',
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
          .querySelectorAll('.ch-images img')
          .map(
            (final dom.Element x) {
              final String? url = x.attributes['src']?.trim();
              if (url != null) {
                return PageInfo(
                  url: '$baseURL$url',
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
