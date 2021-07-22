import 'dart:convert';
import 'package:test/test.dart';
import 'package:yukino_app/core/extractor/manga/model.dart';
import 'package:yukino_app/plugins/translator/model.dart';

void search(MangaExtractor client, String terms) {
  test('Search', () async {
    final res = await client.search(
      terms,
      locale: LanguageCodes.en,
    );

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ')
        .convert(res.map((x) => x.toJson()).toList()));

    expect(res.isEmpty, false);
  });
}

void getInfo(MangaExtractor client, String url) {
  test('Information', () async {
    final res = await client.getInfo(
      url,
      locale: LanguageCodes.en,
    );

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(res.toJson()));

    expect(res.url, url);
  });
}

void getSources(MangaExtractor client, ChapterInfo chapter) {
  test('Sources', () async {
    final res = await client.getChapter(chapter);

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(res));

    expect(res.isEmpty, false);
  });
}
