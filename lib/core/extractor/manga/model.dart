import '../../models/languages.dart' show LanguageCodes, LanguageName;
import '../model.dart';

class SearchInfo extends BaseSearchInfo {
  SearchInfo({
    required final String url,
    required final String title,
    required final this.locale,
    final String? thumbnail,
  }) : super(
          title: title,
          thumbnail: thumbnail,
          url: url,
        );

  final LanguageCodes locale;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
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
    final this.other = const <String, dynamic>{},
  });

  final String? title;
  final String? volume;
  final String chapter;
  final String url;
  final LanguageCodes locale;
  final Map<String, dynamic> other;

  Map<String, dynamic> toJson() => <String, dynamic>{
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

  final String title;
  final String url;
  final List<ChapterInfo> chapters;
  final String? thumbnail;
  final LanguageCodes locale;
  final List<LanguageCodes> availableLocales;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'chapters': chapters.map((final ChapterInfo x) => x.toJson()).toList(),
        'locale': locale.code,
        'availableLocales': availableLocales
            .map((final LanguageCodes x) => x.code)
            .cast<String>()
            .toList()
            .toString(),
      };
}

class PageInfo {
  PageInfo({
    required final this.url,
    required final this.locale,
    final this.headers = const <String, String>{},
  });

  final String url;
  final Map<String, String> headers;
  final LanguageCodes locale;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': url,
        'headers': headers,
        'locale': locale.code,
      };
}

abstract class MangaExtractor extends BaseExtractorPlugin<SearchInfo> {
  LanguageCodes get defaultLocale;

  Future<MangaInfo> getInfo(
    final String url, {
    required final LanguageCodes locale,
  });

  Future<List<PageInfo>> getChapter(final ChapterInfo chapter);
}
