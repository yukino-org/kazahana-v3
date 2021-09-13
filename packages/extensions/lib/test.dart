// ignore_for_file: avoid_print, avoid_private_typedef_functions

import 'dart:convert';
import './extensions.dart';

class TestTimer {
  late final int started;

  void start() {
    started = DateTime.now().millisecondsSinceEpoch;
  }

  void pass() {
    print('Passed in ${DateTime.now().millisecondsSinceEpoch - started}ms');
  }
}

const JsonEncoder encoder = JsonEncoder.withIndent('  ');

class AnimeExtractorTest {
  AnimeExtractorTest(this.extractor);

  final AnimeExtractor extractor;

  Future<void> search(final String terms, final String locale) async {
    final TestTimer timer = TestTimer()..start();

    final List<SearchInfo> result = await extractor.search(terms, locale);

    for (final SearchInfo x in result) {
      print(encoder.convert(x.toJson()));
    }

    print('\nTotal results: ${result.length}');
    timer.pass();
  }

  Future<void> getInfo(final String url, final String locale) async {
    final TestTimer timer = TestTimer()..start();

    final AnimeInfo result = await extractor.getInfo(url, locale);

    print(encoder.convert(result.toJson()));
    timer.pass();
  }

  Future<void> getSources(final EpisodeInfo episode) async {
    final TestTimer timer = TestTimer()..start();

    final List<EpisodeSource> result = await extractor.getSources(episode);

    for (final EpisodeSource x in result) {
      print(encoder.convert(x.toJson()));
    }

    print('\nTotal results: ${result.length}');
    timer.pass();
  }
}

class MangaExtractorTest {
  MangaExtractorTest(this.extractor);

  final MangaExtractor extractor;

  Future<void> search(final String terms, final String locale) async {
    final TestTimer timer = TestTimer()..start();

    final List<SearchInfo> result = await extractor.search(terms, locale);

    for (final SearchInfo x in result) {
      print(encoder.convert(x.toJson()));
    }

    print('\nTotal results: ${result.length}');
    timer.pass();
  }

  Future<void> getInfo(final String url, final String locale) async {
    final TestTimer timer = TestTimer()..start();

    final MangaInfo result = await extractor.getInfo(url, locale);

    print(result.toJson());
    timer.pass();
  }

  Future<void> getChapter(final ChapterInfo chapter) async {
    final TestTimer timer = TestTimer()..start();

    final List<PageInfo> result = await extractor.getChapter(chapter);

    for (final PageInfo x in result) {
      print(encoder.convert(x.toJson()));
    }

    print('\nTotal results: ${result.length}');
    timer.pass();
  }

  Future<void> getPage(final PageInfo page) async {
    final TestTimer timer = TestTimer()..start();

    final ImageInfo result = await extractor.getPage(page);

    print(encoder.convert(result.toJson()));
    timer.pass();
  }
}
