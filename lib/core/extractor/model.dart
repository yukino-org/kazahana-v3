import '../models/languages.dart' show LanguageCodes;

Map<String, T> mapName<T extends BaseExtractor>(final List<T> items) => (items
      ..sort((final T a, final T b) => a.name.compareTo(b.name)))
    .asMap()
    .map(
      (final int key, final T value) => MapEntry<String, T>(value.name, value),
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
  final String url;
  final ImageInfo? thumbnail;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'url': url,
        'thumbnail': thumbnail?.toJson(),
      };
}

abstract class BaseExtractorPlugin<T extends BaseSearchInfo>
    extends BaseExtractor implements BaseExtractorSearch<T> {}

class ImageInfo {
  ImageInfo({
    required final this.url,
    final this.headers = const <String, String>{},
  });

  factory ImageInfo.fromJson(final Map<dynamic, dynamic> json) => ImageInfo(
        url: json['url'] as String,
        headers:
            (json['headers'] as Map<dynamic, dynamic>).cast<String, String>(),
      );

  final String url;
  final Map<String, String> headers;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'url': url,
        'headers': headers,
      };
}
