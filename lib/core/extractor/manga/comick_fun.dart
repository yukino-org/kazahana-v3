import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import './model.dart';
import '../../../plugins/helpers/utils/http.dart';
import '../../models/languages.dart';

const LanguageCodes _defaultLocale = LanguageCodes.en;
const int _limit = 100;

class ComicKFunChapterMeta {
  ComicKFunChapterMeta({
    required final this.hid,
  });

  factory ComicKFunChapterMeta.fromJson(final Map<dynamic, dynamic> json) =>
      ComicKFunChapterMeta(
        hid: json['hid'] as String,
      );

  final String hid;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'hid': hid,
      };
}

class ComicKFun extends MangaExtractor {
  @override
  final String name = 'Comick.fun';

  @override
  final LanguageCodes defaultLocale = _defaultLocale;

  @override
  final String baseURL = 'https://comick.fun';

  late final String apiURL = '$baseURL/api';

  late final Map<String, String> defaultHeaders = <String, String>{
    'User-Agent': HttpUtils.userAgent,
    'Referer': baseURL,
  };

  String searchApiURL(final String terms) =>
      '$apiURL/search_title?t=1&q=$terms';
  String mangaChaptersApiURL(
    final String id, {
    required final String locale,
    final int limit = _limit,
    final int page = 1,
  }) =>
      '$apiURL/get_chapters?comicid=$id&page=$page&limit=$_limit';
  String pagesApiURL(final String hid) => '$apiURL/get_chapter?hid=$hid';

  @override
  Future<List<SearchInfo>> search(
    final String terms, {
    required final LanguageCodes locale,
  }) async {
    try {
      final http.Response res = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(searchApiURL(terms))),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final List<SearchInfo> searches = <SearchInfo>[];
      for (final Map<dynamic, dynamic> x
          in (json.decode(res.body) as List<dynamic>)
              .cast<Map<dynamic, dynamic>>()
              .sublist(0, 10)) {
        final String? coverArt = ((x['md_covers'] as List<dynamic>).firstOrNull
            as Map<dynamic, dynamic>?)?['gpurl'] as String?;

        searches.add(
          SearchInfo(
            url: '$baseURL/comic/${x['slug']}',
            title: x['title'] as String,
            thumbnail: coverArt != null
                ? ImageInfo(
                    url: coverArt,
                    headers: defaultHeaders,
                  )
                : null,
            locale: locale,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      return searches;
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
      final String _url = url.split('?').first;
      final http.Response res = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(_url)),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final String? id = RegExp(r'"id":(\d*\.?\d+)').firstMatch(res.body)?[1];
      if (id is! String) {
        throw AssertionError('Failed to parse id');
      }

      final List<ChapterInfo> chapters = <ChapterInfo>[];
      final String currentLocale = locale.code;
      final List<LanguageCodes> availableLocales = <LanguageCodes>[];

      int page = 1;
      bool finished = false;
      while (!finished) {
        final http.Response res = await http
            .get(
              Uri.parse(
                HttpUtils.tryEncodeURL(
                  mangaChaptersApiURL(
                    id,
                    page: page,
                    locale: locale.code,
                  ),
                ),
              ),
              headers: defaultHeaders,
            )
            .timeout(HttpUtils.timeout);

        final List<Map<dynamic, dynamic>> results =
            (json.decode(res.body)['data']['chapters'] as List<dynamic>)
                .cast<Map<dynamic, dynamic>>();
        for (final Map<dynamic, dynamic> x in results) {
          final String? title = x['title'] as String?;
          final String? chap = x['chap'] as String?;
          final String? vol = x['vol'] as String?;
          final String lang = x['iso639_1'] as String;
          final String hid = x['hid'] as String;
          final String url = '$_url/$hid-chapter-$chap-$lang';

          if (chap is String && LanguageUtils.codeLangaugeMap[lang] != null) {
            if (!availableLocales
                .any((final LanguageCodes x) => x.code == lang)) {
              availableLocales.add(LanguageUtils.codeLangaugeMap[lang]!);
            }

            if (lang == currentLocale) {
              chapters.add(
                ChapterInfo(
                  title: title,
                  volume: vol,
                  chapter: chap,
                  url: url,
                  locale: locale,
                  other: ComicKFunChapterMeta(
                    hid: hid,
                  ).toJson(),
                ),
              );
            }
          }
        }

        page += 1;
        await Future<void>.delayed(const Duration(milliseconds: 100));

        if (results.length != _limit) {
          finished = true;
        }
      }

      final String? thumbnail =
          RegExp('"coverURL":"(.*?)"').firstMatch(res.body)?[1]?.trim();
      return MangaInfo(
        title: RegExp('"title":"(.*?)"').firstMatch(res.body)?[1]?.trim() ?? '',
        url: _url,
        thumbnail: thumbnail != null
            ? ImageInfo(
                url: thumbnail,
                headers: defaultHeaders,
              )
            : null,
        chapters: chapters,
        locale: locale,
        availableLocales: availableLocales,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PageInfo>> getChapter(final ChapterInfo chapter) async {
    try {
      final ComicKFunChapterMeta meta =
          ComicKFunChapterMeta.fromJson(chapter.other);

      final http.Response res = await http
          .get(
            Uri.parse(
              HttpUtils.tryEncodeURL(
                pagesApiURL(meta.hid),
              ),
            ),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      return (json.decode(res.body)['data']['chapter']['images']
              as List<dynamic>)
          .cast<String>()
          .map(
            (final String x) => PageInfo(
              url: x,
              locale: chapter.locale,
            ),
          )
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
