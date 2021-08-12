import '../../models/languages.dart';
import '../model.dart';

export '../model.dart' show ImageInfo;

class SearchInfo extends BaseSearchInfo {
  SearchInfo({
    required final String url,
    required final String title,
    required final this.locale,
    final ImageInfo? thumbnail,
  }) : super(
          title: title,
          thumbnail: thumbnail,
          url: url,
        );

  final LanguageCodes locale;

  @override
  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        ...super.toJson(),
        'locale': locale.code,
      };
}

class ChapterInfo {
  ChapterInfo({
    required final this.chapter,
    required final this.url,
    required final this.locale,
    final this.title,
    final this.volume,
    final this.other = const <dynamic, dynamic>{},
  });

  factory ChapterInfo.fromJson(final Map<dynamic, dynamic> json) => ChapterInfo(
        title: json['title'] as String?,
        url: json['url'] as String,
        volume: json['volume'] as String?,
        chapter: json['chapter'] as String,
        locale: LanguageUtils.codeLangaugeMap[json['locale'] as String]!,
        other: json['other'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{},
      );

  final String? title;
  final String? volume;
  final String chapter;
  final String url;
  final LanguageCodes locale;
  final Map<dynamic, dynamic> other;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'volume': volume,
        'chapter': chapter,
        'url': url,
        'locale': locale.code,
        'other': other,
      };
}

class MangaInfo {
  MangaInfo({
    required final this.url,
    required final this.title,
    required final this.chapters,
    required final this.locale,
    final this.thumbnail,
    final this.availableLocales = const <LanguageCodes>[],
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
        locale: LanguageUtils.codeLangaugeMap[json['locale'] as String]!,
        availableLocales: (json['availableLocales'] as List<String>)
            .map((final String x) => LanguageUtils.codeLangaugeMap[x]!)
            .toList(),
      );

  final String title;
  final String url;
  final List<ChapterInfo> chapters;
  final ImageInfo? thumbnail;
  final LanguageCodes locale;
  final List<LanguageCodes> availableLocales;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'url': url,
        'thumbnail': thumbnail?.toJson(),
        'chapters': chapters.map((final ChapterInfo x) => x.toJson()).toList(),
        'locale': locale.code,
        'availableLocales': availableLocales
            .map((final LanguageCodes x) => x.code)
            .cast<String>()
            .toList(),
      };
}

class PageInfo {
  PageInfo({
    required final this.url,
    required final this.locale,
    final this.other = const <dynamic, dynamic>{},
  });

  final String url;
  final LanguageCodes locale;
  final Map<dynamic, dynamic> other;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'url': url,
        'locale': locale.code,
        'other': other,
      };
}

abstract class MangaExtractor extends BaseExtractorPlugin<SearchInfo> {
  LanguageCodes get defaultLocale;

  Future<MangaInfo> getInfo(
    final String url, {
    required final LanguageCodes locale,
  });

  Future<List<PageInfo>> getChapter(final ChapterInfo chapter);

  Future<ImageInfo> getPage(final PageInfo page);
}
