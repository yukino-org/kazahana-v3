import 'package:utilx/utilities/locale.dart';

class ImageDescriber {
  const ImageDescriber({
    required final this.url,
    final this.headers = const <String, String>{},
  });

  factory ImageDescriber.fromJson(final Map<dynamic, dynamic> json) =>
      ImageDescriber(
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
  const SearchInfo({
    required final this.title,
    required final this.url,
    required final this.locale,
    final this.thumbnail,
  });

  factory SearchInfo.fromJson(final Map<dynamic, dynamic> json) => SearchInfo(
        title: json['title'] as String,
        url: json['url'] as String,
        thumbnail: json['thumbnail'] != null
            ? ImageDescriber.fromJson(
                json['thumbnail'] as Map<dynamic, dynamic>,
              )
            : null,
        locale: Locale.parse(json['locale'] as String),
      );

  final String title;
  final String url;
  final ImageDescriber? thumbnail;
  final Locale locale;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'url': url,
        'thumbnail': thumbnail?.toJson(),
        'locale': locale.toCodeString(),
      };
}

typedef SearchFn = Future<List<SearchInfo>> Function(
  String terms,
  Locale locale,
);

class BaseExtractor {
  const BaseExtractor({
    required final this.name,
    required final this.id,
    required final this.search,
    required final this.defaultLocale,
  });

  final String name;
  final String id;
  final Locale defaultLocale;
  final SearchFn search;
}
