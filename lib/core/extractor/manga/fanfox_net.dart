import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import './model.dart';
import '../../../plugins/helpers/utils/http.dart';
import '../../models/languages.dart';

const LanguageCodes _defaultLocale = LanguageCodes.en;

class FanFoxNet extends MangaExtractor {
  @override
  final String name = 'Fanfox.net';

  @override
  final LanguageCodes defaultLocale = _defaultLocale;

  @override
  final String baseURL = 'https://fanfox.net';

  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': HttpUtils.userAgent,
    'Referer': baseURL,
    'Cookie': 'isAdult=1;',
  };

  String searchURL(final String terms) => '$baseURL/search?title=$terms';

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
          .querySelectorAll('.line-list li')
          .map((final dom.Element x) {
            final dom.Element? link =
                x.querySelector('.manga-list-4-item-title a');
            final String? title = link?.text.trim();
            final String? url = link?.attributes['href']?.trim();
            final String? image =
                x.querySelector('img')?.attributes['src']?.trim();

            if (title != null && url != null) {
              return SearchInfo(
                title: title,
                url: '$baseURL$url',
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
          .querySelectorAll('#chapterlist li a')
          .map((final dom.Element x) {
            final String? title = x.querySelector('.title3')?.text.trim();
            final String? url = x.attributes['href']?.trim();

            if (title != null && url != null) {
              final String? shortTitle =
                  RegExp('-(.*)').firstMatch(title)?[1]?.trim();
              final String? vol =
                  RegExp(r'Vol.(\d+)').firstMatch(title)?[1]?.trim();
              final String? chap =
                  RegExp(r'Ch.([\d.]+)').firstMatch(title)?[1]?.trim();

              if (chap != null) {
                return ChapterInfo(
                  title: shortTitle ?? title,
                  url: '$baseURL$url',
                  chapter: chap,
                  volume: vol,
                  locale: locale,
                );
              }
            }
          })
          .whereType<ChapterInfo>()
          .toList();

      final String? thumbnail = document
          .querySelector('img.detail-info-cover-img')
          ?.attributes['src']
          ?.trim();
      return MangaInfo(
        title: document
                .querySelector('.detail-info-right-title-font')
                ?.text
                .trim() ??
            '',
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
      final String _url = replaceWithMobileURL(chapter.url);
      final http.Response res = await http
          .get(
            Uri.parse(
              HttpUtils.tryEncodeURL(_url),
            ),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final dom.Document document = html.parse(res.body);
      return document
              .querySelector('select.mangaread-page')
              ?.querySelectorAll('option')
              .map(
                (final dom.Element x) {
                  final String? url = x.attributes['value']?.trim();
                  if (url != null) {
                    return PageInfo(
                      url: HttpUtils.ensureProtocol(url),
                      locale: chapter.locale,
                    );
                  }
                },
              )
              .whereType<PageInfo>()
              .toList() ??
          <PageInfo>[];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ImageInfo> getPage(final PageInfo page) async {
    try {
      final String _url = replaceWithMobileURL(page.url);
      final http.Response res = await http
          .get(
            Uri.parse(
              HttpUtils.tryEncodeURL(_url),
            ),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final String? image = RegExp('<img src="(.*?)".*id="image".*>')
          .firstMatch(res.body)?[1]
          ?.trim();
      if (image is! String) {
        throw AssertionError('Failed to parse image');
      }

      return ImageInfo(
        url: HttpUtils.ensureProtocol(image),
        headers: defaultHeaders,
      );
    } catch (e) {
      rethrow;
    }
  }

  String replaceWithMobileURL(final String url) =>
      url.replaceFirst(RegExp(r'https?:\/\/fanfox'), 'https://m.fanfox');
}
