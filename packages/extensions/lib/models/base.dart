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

class SearchInfo {
  SearchInfo({
    required final this.title,
    required final this.url,
    required final this.locale,
    final this.thumbnail,
  });

  factory SearchInfo.fromJson(final Map<dynamic, dynamic> json) => SearchInfo(
        title: json['title'] as String,
        url: json['url'] as String,
        thumbnail: json['thumbnail'] != null
            ? ImageInfo.fromJson(json['thumbnail'] as Map<dynamic, dynamic>)
            : null,
        locale: json['locale'] as String,
      );

  final String title;
  final String url;
  final ImageInfo? thumbnail;
  final String locale;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'url': url,
        'thumbnail': thumbnail?.toJson(),
        'locale': locale,
      };
}

typedef SearchFn = Future<List<SearchInfo>> Function(
  String terms,
  String locale,
);

class BaseExtractor {
  BaseExtractor({
    required final this.name,
    required final this.id,
    required final this.search,
    required final this.defaultLocale,
  });

  final String name;
  final String id;
  final String defaultLocale;
  final SearchFn search;
}

class ExtensionVersion {
  ExtensionVersion(this.year, this.month, this.revision);

  factory ExtensionVersion.parse(final String version) {
    final RegExpMatch? match =
        RegExp(r'(\d{4})\.(\d{2})-r(\d+)').firstMatch(version);
    if (match == null) {
      throw Exception('Invalid format');
    }

    final int year = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int revision = int.parse(match.group(3)!);
    if (month < 1 || month > 12) {
      throw Exception('Invalid month');
    }

    return ExtensionVersion(year, month, revision);
  }

  final int year;
  final int month;
  final int revision;

  @override
  String toString() => '$year.${month.toString().padLeft(2, '0')}-r$revision';

  bool operator >(final ExtensionVersion version) =>
      year > version.year ||
      (year == version.year && month > version.month) ||
      year == version.year &&
          month == version.month &&
          revision > version.revision;

  bool operator <(final ExtensionVersion version) =>
      year < version.year ||
      (year == version.year && month < version.month) ||
      year == version.year &&
          month == version.month &&
          revision < version.revision;

  @override
  bool operator ==(final Object other) =>
      other is ExtensionVersion &&
      year == other.year &&
      month == other.month &&
      revision == other.revision;

  @override
  int get hashCode => Object.hash(year, month, revision);
}
