import '../../models/languages.dart' show LanguageCodes, LanguageName;
import '../model.dart';

class SearchInfo extends BaseSearchInfo {
  final LanguageCodes locale;

  SearchInfo({
    required url,
    required title,
    thumbnail,
    required this.locale,
  }) : super(
          title: title,
          thumbnail: thumbnail,
          url: url,
        );

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'locale': locale.code,
      };
}

class ChapterInfo {
  final String? title;
  final String? volume;
  final String chapter;
  final String url;
  final LanguageCodes locale;
  final Map<String, dynamic> other;

  ChapterInfo({
    this.title,
    this.volume,
    required this.chapter,
    required this.url,
    required this.locale,
    this.other = const {},
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'volume': volume,
        'chapter': chapter,
        'url': url,
        'locale': locale.code,
        'other': other,
      };
}

class MangaInfo {
  final String title;
  final String url;
  final List<ChapterInfo> chapters;
  final String? thumbnail;
  final LanguageCodes locale;
  final List<LanguageCodes> availableLocales;

  MangaInfo({
    required this.url,
    required this.title,
    required this.chapters,
    this.thumbnail,
    required this.locale,
    this.availableLocales = const [],
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'chapters': chapters.map((x) => x.toJson()).toList(),
        'locale': locale.code,
        'availableLocales': availableLocales
            .map((x) => x.code)
            .cast<String>()
            .toList()
            .toString(),
      };
}

class PageInfo {
  final String url;
  final Map<String, String> headers;
  final LanguageCodes locale;

  PageInfo({
    required this.url,
    this.headers = const {},
    required this.locale,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'headers': headers,
        'locale': locale.code,
      };
}

abstract class MangaExtractor extends BaseExtractorPlugin<SearchInfo> {
  LanguageCodes get defaultLocale;

  Future<MangaInfo> getInfo(
    String url, {
    required LanguageCodes locale,
  });

  Future<List<PageInfo>> getChapter(
    ChapterInfo chapter,
  );
}
