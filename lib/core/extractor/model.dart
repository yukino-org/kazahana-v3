import '../models/languages.dart' show LanguageCodes;

Map<String, T> mapName<T extends BaseExtractor>(final List<T> items) =>
    items.asMap().map(
          (final int key, final T value) =>
              MapEntry<String, T>(value.name, value),
        );

abstract class BaseExtractor {
  String get name;
  String get baseURL;
}

abstract class BaseExtractorSearch<T> {
  Future<List<T>> search(
    final String terms, {
    required final LanguageCodes locale,
  });
}

abstract class BaseSearchInfo {
  BaseSearchInfo({
    required final this.title,
    required final this.url,
    final this.thumbnail,
  });

  final String title;
  final String? thumbnail;
  final String url;
}

abstract class BaseExtractorPlugin<T extends BaseSearchInfo>
    extends BaseExtractor implements BaseExtractorSearch<T> {}
