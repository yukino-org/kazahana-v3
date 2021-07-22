import '../../../plugins/translator/model.dart'
    show LanguageCodes, LanguageName;

class SearchInfo {
  final String title;
  final String url;
  final String? thumbnail;
  final LanguageCodes locale;

  SearchInfo({
    required final this.url,
    required final this.title,
    final this.thumbnail,
    required final this.locale,
  });

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
    final this.title,
    final this.volume,
    required final this.chapter,
    required final this.url,
    required final this.locale,
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

  MangaInfo({
    required final this.url,
    required final this.title,
    required final this.chapters,
    final this.thumbnail,
    required final this.locale,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'chapters': chapters.map((x) => x.toJson()).toList(),
        'locale': locale.code,
      };
}

class PageInfo {
  final String url;
  final Map<String, String> headers;
  final LanguageCodes locale;

  PageInfo({
    required final this.url,
    final this.headers = const {},
    required final this.locale,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'headers': headers,
        'locale': locale.code,
      };
}

abstract class MangaExtractor {
  Future<List<SearchInfo>> search(
    final String terms, {
    required final LanguageCodes locale,
  });

  Future<MangaInfo> getInfo(
    final String url, {
    required final LanguageCodes locale,
  });

  Future<List<PageInfo>> getChapter(final ChapterInfo chapter);
}
