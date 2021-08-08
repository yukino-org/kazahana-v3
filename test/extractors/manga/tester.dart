import 'dart:convert';
import 'package:test/test.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/core/models/languages.dart';

void search(final MangaExtractor client, final String terms) {
  test('Search', () async {
    final List<SearchInfo> res = await client.search(
      terms,
      locale: LanguageCodes.en,
    );

    // ignore: avoid_print
    print(
      const JsonEncoder.withIndent('  ')
          .convert(res.map((final SearchInfo x) => x.toJson()).toList()),
    );

    expect(res.isEmpty, false);
  });
}

void getInfo(final MangaExtractor client, final String url) {
  test('Information', () async {
    final MangaInfo res = await client.getInfo(
      url,
      locale: LanguageCodes.en,
    );

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(res.toJson()));

    expect(res.url, url);
  });
}

void getSources(final MangaExtractor client, final ChapterInfo chapter) {
  test('Sources', () async {
    final List<PageInfo> res = await client.getChapter(chapter);

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(res));

    expect(res.isEmpty, false);
  });
}
