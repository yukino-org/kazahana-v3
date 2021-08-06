import '../models/languages.dart' show LanguageCodes;

Map<String, T> mapName<T extends BaseExtractor>(final List<T> items) =>
    items.asMap().map((key, value) => MapEntry(value.name, value));

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
  final String title;
  final String? thumbnail;
  final String url;

  BaseSearchInfo({
    required this.title,
    this.thumbnail,
    required this.url,
  });
}

abstract class BaseExtractorPlugin<T extends BaseSearchInfo>
    extends BaseExtractor implements BaseExtractorSearch<T> {}
