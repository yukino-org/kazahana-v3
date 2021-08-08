import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import './model.dart';
import '../../models/languages.dart';
import '../../utils.dart' as utils;

enum DataQuality { original, compressed }

final Map<DataQuality, String> dataQualityValues = <DataQuality, String>{
  DataQuality.original: 'data',
  DataQuality.compressed: 'data-saver',
};

const LanguageCodes _defaultLocale = LanguageCodes.en;
const int _limit = 500;

class MangaDex extends MangaExtractor {
  @override
  final String name = 'Mangadex.org';

  @override
  final LanguageCodes defaultLocale = _defaultLocale;

  @override
  final String baseURL = 'https://mangadex.org';

  final String apiURL = 'https://api.mangadex.org';
  final String uploadsURL = 'https://uploads.mangadex.org';

  final Map<String, String> defaultHeaders = <String, String>{};

  String searchApiURL(final String terms) => '$apiURL/manga?title=$terms';
  String mangaApiURL(final String id) => '$apiURL/manga/$id';
  String mangaFeedApiURL(
    final String id, {
    required final String locale,
    final int limit = _limit,
    final int offset = 0,
  }) =>
      '$apiURL/manga/$id/feed?limit=$limit&offset=$offset&order[chapter]=asc&translatedLanguage[]=$locale';
  String mangaChapterOverviewURL(
    final String id, {
    final int chapter = 1,
    final int volume = 1,
    final int limit = 100,
  }) =>
      '$apiURL/chapter?manga=$id&chapter=$chapter&volume=$volume&limit=$limit&order[chapter]=asc';
  String mangaServerApiURL(final String id) => '$apiURL/at-home/server/$id';
  String chapterApiURL(
    final String serverURL,
    final DataQuality quality,
    final String hash,
  ) =>
      '$serverURL/${dataQualityValues[quality]}/$hash';
  String pageSourceURL(
    final String chapterApiURL,
    final String filename,
  ) =>
      '$chapterApiURL/$filename';
  String coverAPIURL(final String coverID) => '$apiURL/cover/$coverID';
  String coverURL(final String mangaID, final String coverFile) =>
      '$uploadsURL/covers/$mangaID/$coverFile';

  String? extractIdFromURL(final String url) =>
      RegExp(r'https?:\/\/api\.mangadex\.org\/manga\/([^\/]+)')
          .firstMatch(url)?[1];

  @override
  Future<List<SearchInfo>> search(
    final String terms, {
    required final LanguageCodes locale,
  }) async {
    try {
      final http.Response res = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(searchApiURL(terms))),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);

      final List<SearchInfo> searches = <SearchInfo>[];
      for (final Map<String, dynamic> x
          in (json.decode(res.body)['results'] as List<dynamic>)
              .cast<Map<String, dynamic>>()) {
        final String? coverArt = (x['relationships'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .firstWhereOrNull(
              (final Map<String, dynamic> x) => x['type'] == 'cover_art',
            )?['id'] as String?;

        searches.add(
          SearchInfo(
            url: mangaApiURL(x['data']['id'] as String),
            title: x['data']['attributes']['title']['en'] as String,
            thumbnail: coverArt != null
                ? await getCoverImageURL(x['data']['id'] as String, coverArt)
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
    final String? id = extractIdFromURL(url);
    if (id == null) {
      throw AssertionError('Failed to parse id from URL');
    }

    try {
      final List<ChapterInfo> chapters = <ChapterInfo>[];

      int offset = 0;
      bool finished = false;
      while (!finished) {
        final http.Response res = await http
            .get(
              Uri.parse(
                utils.Fns.tryEncodeURL(
                  mangaFeedApiURL(
                    id,
                    offset: offset,
                    locale: locale.code,
                  ),
                ),
              ),
              headers: defaultHeaders,
            )
            .timeout(utils.Http.timeout);

        final List<Map<String, dynamic>> results =
            (json.decode(res.body)['results'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
        for (final Map<String, dynamic> x in results) {
          final String? title = x['data']['attributes']['title'] as String?;
          chapters.add(
            ChapterInfo(
              title: title != null && title.isNotEmpty ? title : null,
              volume: x['data']['attributes']['volume'] as String,
              chapter: x['data']['attributes']['chapter'] as String,
              url: chapterApiURL(
                '<serverURL>',
                DataQuality.original,
                x['data']['attributes']['hash'] as String,
              ),
              locale: locale,
              other: <String, dynamic>{
                'id': x['data']['id'],
                'files': x['data']['attributes']['data'],
              },
            ),
          );
        }

        offset += _limit;
        await Future<void>.delayed(const Duration(milliseconds: 50));

        if (results.length != _limit) {
          finished = true;
        }
      }

      final String mangaURL = mangaApiURL(id);
      final http.Response res = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(mangaURL)),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);
      final Map<String, dynamic> parsed =
          json.decode(res.body) as Map<String, dynamic>;
      final String? coverArt = (parsed['relationships'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .firstWhereOrNull(
            (final Map<String, dynamic> x) => x['type'] == 'cover_art',
          )?['id'] as String?;

      return MangaInfo(
        url: mangaURL,
        title: (parsed['data']['attributes']['title'][locale.code] ??
                parsed['data']['attributes']['title'][_defaultLocale.code])
            as String,
        thumbnail:
            coverArt != null ? await getCoverImageURL(id, coverArt) : null,
        chapters: chapters,
        locale: locale,
        availableLocales: await getAvailableLanguages(id),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PageInfo>> getChapter(final ChapterInfo chapter) async {
    final http.Response serverRes = await http
        .get(
          Uri.parse(
            utils.Fns.tryEncodeURL(
              mangaServerApiURL(
                chapter.other['id'] as String,
              ),
            ),
          ),
          headers: defaultHeaders,
        )
        .timeout(utils.Http.timeout);
    final String chapterURL = chapter.url.replaceFirst(
      '<serverURL>',
      json.decode(serverRes.body)['baseUrl'] as String,
    );

    final List<PageInfo> pages = <PageInfo>[];
    for (final String x
        in (chapter.other['files'] as List<dynamic>).cast<String>()) {
      pages.add(
        PageInfo(
          url: pageSourceURL(chapterURL, x),
          locale: chapter.locale,
        ),
      );
    }

    return pages;
  }

  Future<String?> getCoverImageURL(
    final String mangaID,
    final String coverID,
  ) async {
    try {
      final http.Response res = await http
          .get(
            Uri.parse(utils.Fns.tryEncodeURL(coverAPIURL(coverID))),
            headers: defaultHeaders,
          )
          .timeout(utils.Http.timeout);
      final Map<String, dynamic> parsed =
          json.decode(res.body) as Map<String, dynamic>;
      return coverURL(
        mangaID,
        parsed['data']['attributes']['fileName'] as String,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<LanguageCodes>> getAvailableLanguages(
    final String mangaID,
  ) async {
    final http.Response res = await http
        .get(
          Uri.parse(utils.Fns.tryEncodeURL(mangaChapterOverviewURL(mangaID))),
          headers: defaultHeaders,
        )
        .timeout(utils.Http.timeout);

    final List<LanguageCodes> locales = <LanguageCodes>[];

    for (final Map<String, dynamic> x
        in (json.decode(res.body)['results'] as List<dynamic>)
            .cast<Map<String, dynamic>>()) {
      final String? code = RegExp(r'\w+').firstMatch(
        x['data']['attributes']['translatedLanguage'] as String,
      )?[0];
      if (code != null) {
        final LanguageCodes? lang = LanguageUtils.codeLangaugeMap[code];
        if (lang != null) {
          locales.add(lang);
        }
      }
    }

    return locales;
  }
}
