import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import './model.dart';
import '../../../plugins/helpers/utils/http.dart';
import '../../models/languages.dart';

enum DataQuality {
  original,
  compressed,
}

final Map<DataQuality, String> dataQualityValues = <DataQuality, String>{
  DataQuality.original: 'data',
  DataQuality.compressed: 'data-saver',
};

class MangaDexOrgChapterMeta {
  MangaDexOrgChapterMeta({
    required final this.id,
    required final this.files,
  });

  factory MangaDexOrgChapterMeta.fromJson(final Map<dynamic, dynamic> json) =>
      MangaDexOrgChapterMeta(
        id: json['id'] as String,
        files: (jsonDecode(json['files'] as String) as List<dynamic>)
            .cast<String>(),
      );

  final String id;
  final List<String> files;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'id': id,
        'files': jsonEncode(files),
      };
}

const LanguageCodes _defaultLocale = LanguageCodes.en;
const int _limit = 500;

class MangaDexOrg extends MangaExtractor {
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
            Uri.parse(HttpUtils.tryEncodeURL(searchApiURL(terms))),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);

      final List<SearchInfo> searches = <SearchInfo>[];
      for (final Map<dynamic, dynamic> x
          in (json.decode(res.body)['results'] as List<dynamic>)
              .cast<Map<dynamic, dynamic>>()) {
        final String? coverArt = (x['relationships'] as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .firstWhereOrNull(
              (final Map<dynamic, dynamic> x) => x['type'] == 'cover_art',
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
    if (id is! String) {
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
                HttpUtils.tryEncodeURL(
                  mangaFeedApiURL(
                    id,
                    offset: offset,
                    locale: locale.code,
                  ),
                ),
              ),
              headers: defaultHeaders,
            )
            .timeout(HttpUtils.timeout);

        final List<Map<dynamic, dynamic>> results =
            (json.decode(res.body)['results'] as List<dynamic>)
                .cast<Map<dynamic, dynamic>>();
        for (final Map<dynamic, dynamic> x in results) {
          final String? title = x['data']['attributes']['title'] as String?;
          chapters.add(
            ChapterInfo(
              title: title?.isNotEmpty ?? false ? title : null,
              volume: x['data']['attributes']['volume'] as String,
              chapter: x['data']['attributes']['chapter'] as String,
              url: chapterApiURL(
                '<serverURL>',
                DataQuality.original,
                x['data']['attributes']['hash'] as String,
              ),
              locale: locale,
              other: MangaDexOrgChapterMeta(
                id: x['data']['id'] as String,
                files: (x['data']['attributes']['data'] as List<dynamic>)
                    .cast<String>(),
              ).toJson(),
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
            Uri.parse(HttpUtils.tryEncodeURL(mangaURL)),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);
      final Map<dynamic, dynamic> parsed =
          json.decode(res.body) as Map<dynamic, dynamic>;
      final String? coverArt = (parsed['relationships'] as List<dynamic>)
          .cast<Map<dynamic, dynamic>>()
          .firstWhereOrNull(
            (final Map<dynamic, dynamic> x) => x['type'] == 'cover_art',
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
    final MangaDexOrgChapterMeta meta =
        MangaDexOrgChapterMeta.fromJson(chapter.other);

    final http.Response serverRes = await http
        .get(
          Uri.parse(HttpUtils.tryEncodeURL(mangaServerApiURL(meta.id))),
          headers: defaultHeaders,
        )
        .timeout(HttpUtils.timeout);

    final String chapterURL = chapter.url.replaceFirst(
      '<serverURL>',
      json.decode(serverRes.body)['baseUrl'] as String,
    );

    final List<PageInfo> pages = <PageInfo>[];
    for (final String x in meta.files) {
      pages.add(
        PageInfo(
          url: pageSourceURL(chapterURL, x),
          locale: chapter.locale,
        ),
      );
    }

    return pages;
  }

  @override
  Future<ImageInfo> getPage(final PageInfo page) async => ImageInfo(
        url: page.url,
        headers: defaultHeaders,
      );

  Future<ImageInfo?> getCoverImageURL(
    final String mangaID,
    final String coverID,
  ) async {
    try {
      final http.Response res = await http
          .get(
            Uri.parse(HttpUtils.tryEncodeURL(coverAPIURL(coverID))),
            headers: defaultHeaders,
          )
          .timeout(HttpUtils.timeout);
      final Map<dynamic, dynamic> parsed =
          json.decode(res.body) as Map<dynamic, dynamic>;
      return ImageInfo(
        url: coverURL(
          mangaID,
          parsed['data']['attributes']['fileName'] as String,
        ),
        headers: defaultHeaders,
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
          Uri.parse(HttpUtils.tryEncodeURL(mangaChapterOverviewURL(mangaID))),
          headers: defaultHeaders,
        )
        .timeout(HttpUtils.timeout);

    final List<LanguageCodes> locales = <LanguageCodes>[];

    for (final Map<dynamic, dynamic> x
        in (json.decode(res.body)['results'] as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()) {
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
