import './base.dart';

class ChapterInfo {
  ChapterInfo({
    required final this.chapter,
    required final this.url,
    required final this.locale,
    final this.title,
    final this.volume,
  });

  factory ChapterInfo.fromJson(final Map<dynamic, dynamic> json) => ChapterInfo(
        title: json['title'] as String?,
        url: json['url'] as String,
        volume: json['volume'] as String?,
        chapter: json['chapter'] as String,
        locale: json['locale'] as String,
      );

  final String? title;
  final String? volume;
  final String chapter;
  final String url;
  final String locale;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'volume': volume,
        'chapter': chapter,
        'url': url,
        'locale': locale,
      };
}

class MangaInfo {
  MangaInfo({
    required final this.url,
    required final this.title,
    required final this.chapters,
    required final this.locale,
    final this.thumbnail,
    final this.availableLocales = const <String>[],
  });

  factory MangaInfo.fromJson(final Map<dynamic, dynamic> json) => MangaInfo(
        title: json['title'] as String,
        url: json['url'] as String,
        chapters: (json['chapters'] as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .map((final Map<dynamic, dynamic> x) => ChapterInfo.fromJson(x))
            .toList(),
        thumbnail: json['thumbnail'] != null
            ? ImageInfo.fromJson(json['thumbnail'] as Map<dynamic, dynamic>)
            : null,
        locale: json['locale'] as String,
        availableLocales:
            (json['availableLocales'] as List<dynamic>).cast<String>(),
      );

  final String title;
  final String url;
  final List<ChapterInfo> chapters;
  final ImageInfo? thumbnail;
  final String locale;
  final List<String> availableLocales;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'url': url,
        'thumbnail': thumbnail?.toJson(),
        'chapters': chapters.map((final ChapterInfo x) => x.toJson()).toList(),
        'locale': locale,
        'availableLocales': availableLocales,
      };
}

class PageInfo {
  PageInfo({
    required final this.url,
    required final this.locale,
  });

  factory PageInfo.fromJson(final Map<dynamic, dynamic> json) => PageInfo(
        url: json['url'] as String,
        locale: json['locale'] as String,
      );

  final String url;
  final String locale;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'url': url,
        'locale': locale,
      };
}

typedef GetMangaInfoFn = Future<MangaInfo> Function(String, String);

typedef GetChapterFn = Future<List<PageInfo>> Function(ChapterInfo);

typedef GetPageFn = Future<ImageInfo> Function(PageInfo);

class MangaExtractor extends BaseExtractor {
  MangaExtractor({
    required final String name,
    required final String id,
    required final SearchFn search,
    required final String defaultLocale,
    required final this.getInfo,
    required final this.getChapter,
    required final this.getPage,
  }) : super(
          name: name,
          id: id,
          search: search,
          defaultLocale: defaultLocale,
        );

  final GetMangaInfoFn getInfo;
  final GetChapterFn getChapter;
  final GetPageFn getPage;
}
