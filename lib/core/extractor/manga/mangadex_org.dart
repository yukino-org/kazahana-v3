import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import '../../../plugins/translator/model.dart' show LanguageName;
import './model.dart';

enum DataQuality { original, compressed }

final Map<DataQuality, String> dataQualityValues = {
  DataQuality.original: 'data',
  DataQuality.compressed: 'data-saver',
};

class MangaDex implements MangaExtractor {
  @override
  get name => 'Mangadex.org';

  final apiURL = 'https://api.mangadex.org';
  final uploadsURL = 'https://uploads.mangadex.org';

  final Map<String, String> defaultHeaders = {};

  String searchApiURL(final String terms) => '$apiURL/manga?title=$terms';
  String mangaApiURL(final String id) => '$apiURL/manga/$id';
  String mangaFeedApiURL(
    final String id, {
    final int limit = 500,
    final int offset = 0,
    required final String locale,
  }) =>
      '$apiURL/manga/$id/feed?limit=$limit&offset=$offset&order[chapter]=asc&translatedLanguage[]=$locale';
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
      RegExp(r'https:\/\/api\.mangadex\.org\/manga\/([^\/]+)')
          .firstMatch(url)?[1];

  @override
  search(
    final terms, {
    required final locale,
  }) async {
    try {
      final res = await http.get(
        Uri.parse(Uri.encodeFull(searchApiURL(terms))),
        headers: defaultHeaders,
      );

      final List<SearchInfo> searches = [];
      for (final x in (json.decode(res.body)['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>()) {
        final String? coverArt = (x['relationships'] as List<dynamic>)
            .firstWhereOrNull((x) => x['type'] == 'cover_art')['id'];

        searches.add(SearchInfo(
          url: mangaApiURL(x['data']['id']),
          title: x['data']['attributes']['title']['en'],
          thumbnail: coverArt != null
              ? await getCoverImageURL(x['data']['id'], coverArt)
              : null,
          locale: locale,
        ));

        await Future.delayed(const Duration(milliseconds: 50));
      }

      return searches;
    } catch (e) {
      rethrow;
    }
  }

  @override
  getInfo(
    final url, {
    required final locale,
  }) async {
    final id = extractIdFromURL(url);
    if (id == null) throw ('Failed to parse id from URL');

    try {
      final List<ChapterInfo> chapters = [];

      const limit = 500;
      int offset = 0;
      bool finished = false;
      while (!finished) {
        final res = await http.get(
          Uri.parse(Uri.encodeFull(mangaFeedApiURL(
            id,
            limit: limit,
            offset: offset,
            locale: locale.code,
          ))),
          headers: defaultHeaders,
        );

        final results = (json.decode(res.body)['results'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        for (final x in results) {
          final String? title = x['data']['attributes']['title'];
          chapters.add(
            ChapterInfo(
              title: title != null && title.isNotEmpty ? title : null,
              volume: x['data']['attributes']['volume'],
              chapter: x['data']['attributes']['chapter'],
              url: chapterApiURL(
                '<serverURL>',
                DataQuality.original,
                x['data']['attributes']['hash'],
              ),
              locale: locale,
              other: {
                'id': x['data']['id'],
                'files': x['data']['attributes']['data'],
              },
            ),
          );
        }

        offset += limit;
        await Future.delayed(const Duration(milliseconds: 50));

        if (results.length != limit) {
          finished = true;
        }
      }

      final String mangaURL = mangaApiURL(id);
      final res = await http.get(
        Uri.parse(Uri.encodeFull(mangaURL)),
        headers: defaultHeaders,
      );
      final parsed = json.decode(res.body);
      final String? coverArt = (parsed['relationships'] as List<dynamic>)
          .firstWhereOrNull((x) => x['type'] == 'cover_art')['id'];

      return MangaInfo(
        url: mangaURL,
        title: (parsed['data']['attributes']['title']['en'] as String),
        thumbnail:
            coverArt != null ? await getCoverImageURL(id, coverArt) : null,
        chapters: chapters,
        locale: locale,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  getChapter(final chapter) async {
    final serverRes = await http.get(
      Uri.parse(Uri.encodeFull(mangaServerApiURL(chapter.other['id']))),
      headers: defaultHeaders,
    );
    final chapterURL = chapter.url
        .replaceFirst('<serverURL>', json.decode(serverRes.body)['baseUrl']);

    final List<PageInfo> pages = [];
    for (final x in (chapter.other['files'] as List<dynamic>).cast<String>()) {
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
      final String mangaID, final String coverID) async {
    try {
      final res = await http.get(
        Uri.parse(Uri.encodeFull(coverAPIURL(coverID))),
        headers: defaultHeaders,
      );
      final parsed = json.decode(res.body);
      return coverURL(mangaID, parsed['data']['attributes']['fileName']);
    } catch (e) {
      return null;
    }
  }
}
