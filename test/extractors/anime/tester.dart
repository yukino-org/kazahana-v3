import 'dart:convert';
import 'package:test/test.dart';
import 'package:yukino_app/core/extractor/animes/model.dart';
import 'package:yukino_app/core/models/languages.dart';

void search(final AnimeExtractor client, final String terms) {
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

void getInfo(final AnimeExtractor client, final String url) {
  test('Information', () async {
    final AnimeInfo res = await client.getInfo(
      url,
      locale: LanguageCodes.en,
    );

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(res.toJson()));

    expect(res.url, url);
  });
}

void getSources(final AnimeExtractor client, final EpisodeInfo episode) {
  test('Sources', () async {
    final List<EpisodeSource> res = await client.getSources(episode);

    // ignore: avoid_print
    print(
      const JsonEncoder.withIndent('  ')
          .convert(res.map((final EpisodeSource x) => x.toJson()).toList()),
    );

    expect(res.isEmpty, false);
  });
}
