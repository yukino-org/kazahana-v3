import 'dart:convert';
import 'package:test/test.dart';
import 'package:yukino_app/core/extractor/animes/model.dart';
import 'package:yukino_app/plugins/translator/model.dart';

void search(AnimeExtractor client, String terms) {
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

void getInfo(AnimeExtractor client, String url) {
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

void getSources(AnimeExtractor client, String url) {
  test('Sources', () async {
    final res = await client.getSources(
      url,
      locale: LanguageCodes.en,
    );

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(res));

    expect(res.isEmpty, false);
  });
}
