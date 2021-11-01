library extensions;

import 'dart:async';
import 'package:hetu_script/hetu_script.dart';
import 'package:http/http.dart' as http;
import 'package:utilx/utilities/locale.dart';
import './hetu/hetu.dart';
import './models/anime.dart';
import './models/base.dart';
import './models/manga.dart';

export './models/anime.dart';
export './models/base.dart';
export './models/manga.dart';
export './utils/http.dart';

enum ExtensionType {
  anime,
  manga,
}

extension ExtensionTypeUtils on ExtensionType {
  String get type => toString().split('.').last;
}

class BaseExtension {
  BaseExtension({
    required final this.name,
    required final this.id,
    required final this.author,
    required final this.version,
    required final this.type,
    required final this.image,
    required final this.nsfw,
    required final this.defaultLocale,
  });

  factory BaseExtension.fromJson(final Map<dynamic, dynamic> json) =>
      BaseExtension(
        name: json['name'] as String,
        id: json['id'] as String,
        author: json['author'] as String,
        version: ExtensionVersion.parse(json['version'] as String),
        type: ExtensionType.values.firstWhere(
          (final ExtensionType type) => type.type == (json['type'] as String),
        ),
        image: json['image'] as String,
        nsfw: json['nsfw'] as bool,
        defaultLocale: Locale.parse(json['defaultLocale'] as String),
      );

  final String name;
  final String id;
  final String author;
  final ExtensionVersion version;
  final ExtensionType type;
  final String image;
  final bool nsfw;
  final Locale defaultLocale;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'name': name,
        'id': id,
        'version': version.toString(),
        'type': type.type,
        'image': image,
        'nsfw': nsfw,
      };
}

class ResolvableExtension extends BaseExtension {
  ResolvableExtension({
    required final String name,
    required final String id,
    required final String author,
    required final ExtensionVersion version,
    required final ExtensionType type,
    required final String image,
    required final bool nsfw,
    required final Locale defaultLocale,
    required final this.source,
  }) : super(
          name: name,
          id: id,
          author: author,
          version: version,
          type: type,
          image: image,
          nsfw: nsfw,
          defaultLocale: defaultLocale,
        );

  factory ResolvableExtension.fromJson(final Map<dynamic, dynamic> json) {
    final BaseExtension base = BaseExtension.fromJson(json);

    return ResolvableExtension(
      name: base.name,
      id: base.id,
      author: base.author,
      version: base.version,
      type: base.type,
      image: base.image,
      source: json['source'] as String,
      nsfw: base.nsfw,
      defaultLocale: base.defaultLocale,
    );
  }

  final String source;

  Future<ResolvedExtension> resolve() async {
    final http.Response res = await http.get(Uri.parse(source));

    return ResolvedExtension(
      name: name,
      id: id,
      author: author,
      version: version,
      type: type,
      image: image,
      code: res.body,
      nsfw: nsfw,
      defaultLocale: defaultLocale,
    );
  }

  @override
  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        ...super.toJson(),
        'source': source,
      };
}

class ResolvedExtension extends BaseExtension {
  ResolvedExtension({
    required final String name,
    required final String id,
    required final String author,
    required final ExtensionVersion version,
    required final ExtensionType type,
    required final String image,
    required final bool nsfw,
    required final Locale defaultLocale,
    required final this.code,
  }) : super(
          name: name,
          id: id,
          author: author,
          version: version,
          type: type,
          image: image,
          nsfw: nsfw,
          defaultLocale: defaultLocale,
        );

  factory ResolvedExtension.fromJson(final Map<dynamic, dynamic> json) {
    final BaseExtension base = BaseExtension.fromJson(json);

    return ResolvedExtension(
      name: base.name,
      id: base.id,
      author: base.author,
      version: base.version,
      type: base.type,
      image: base.image,
      code: json['code'] as String,
      nsfw: base.nsfw,
      defaultLocale: base.defaultLocale,
    );
  }

  final String code;

  @override
  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        ...super.toJson(),
        'code': code,
      };
}

abstract class ExtensionUtils {
  static String _getDefaultLocale(final Hetu runner) {
    try {
      return runner.invoke('defaultLocale') as String;
    } on HTError catch (err) {
      HetuManager.editError(err);
      rethrow;
    }
  }

  static Future<AnimeExtractor> transpileToAnimeExtractor(
    final ResolvedExtension ext,
  ) async {
    final Hetu runner = await HetuManager.create();

    try {
      await runner.eval(HetuManager.appendDefinitions(ext.code));
    } on HTError catch (err) {
      HetuManager.editError(err);
      rethrow;
    }

    final Locale defaultLocale = Locale.parse(_getDefaultLocale(runner));

    return AnimeExtractor(
      name: ext.name,
      id: ext.id,
      defaultLocale: defaultLocale,
      search: (final String terms, final Locale locale) async {
        try {
          final dynamic result = await runner.invoke(
            'search',
            positionalArgs: <dynamic>[
              terms,
              locale.toString(),
            ],
          );

          return (result as List<dynamic>)
              .cast<Map<dynamic, dynamic>>()
              .map(
                (final Map<dynamic, dynamic> x) => SearchInfo.fromJson(x),
              )
              .toList();
        } on HTError catch (err) {
          HetuManager.editError(err);
          rethrow;
        }
      },
      getInfo: (final String url, final Locale locale) async {
        try {
          final dynamic result = await runner.invoke(
            'getInfo',
            positionalArgs: <dynamic>[
              url,
              locale.toString(),
            ],
          );

          return AnimeInfo.fromJson(result as Map<dynamic, dynamic>);
        } on HTError catch (err) {
          HetuManager.editError(err);
          rethrow;
        }
      },
      getSources: (final EpisodeInfo episode) async {
        try {
          final dynamic result = await runner.invoke(
            'getSources',
            positionalArgs: <dynamic>[
              episode.toJson(),
            ],
          );

          return (result as List<dynamic>)
              .cast<Map<dynamic, dynamic>>()
              .map(
                (final Map<dynamic, dynamic> x) => EpisodeSource.fromJson(x),
              )
              .toList();
        } on HTError catch (err) {
          HetuManager.editError(err);
          rethrow;
        }
      },
    );
  }

  static Future<MangaExtractor> transpileToMangaExtractor(
    final ResolvedExtension ext,
  ) async {
    final Hetu runner = await HetuManager.create();

    try {
      await runner.eval(HetuManager.appendDefinitions(ext.code));
    } on HTError catch (err) {
      HetuManager.editError(err);
      rethrow;
    }

    final Locale defaultLocale = Locale.parse(_getDefaultLocale(runner));

    return MangaExtractor(
      name: ext.name,
      id: ext.id,
      defaultLocale: defaultLocale,
      search: (final String terms, final Locale locale) async {
        try {
          final dynamic result = await runner.invoke(
            'search',
            positionalArgs: <dynamic>[
              terms,
              locale.toString(),
            ],
          );

          return (result as List<dynamic>)
              .cast<Map<dynamic, dynamic>>()
              .map(
                (final Map<dynamic, dynamic> x) => SearchInfo.fromJson(x),
              )
              .toList();
        } on HTError catch (err) {
          HetuManager.editError(err);
          rethrow;
        }
      },
      getInfo: (final String url, final Locale locale) async {
        try {
          final dynamic result = await runner.invoke(
            'getInfo',
            positionalArgs: <dynamic>[
              url,
              locale.toString(),
            ],
          );

          return MangaInfo.fromJson(result as Map<dynamic, dynamic>);
        } on HTError catch (err) {
          HetuManager.editError(err);
          rethrow;
        }
      },
      getChapter: (final ChapterInfo chapter) async {
        try {
          final dynamic result = await runner.invoke(
            'getChapter',
            positionalArgs: <dynamic>[
              chapter.toJson(),
            ],
          );

          return (result as List<dynamic>)
              .cast<Map<dynamic, dynamic>>()
              .map(
                (final Map<dynamic, dynamic> x) => PageInfo.fromJson(x),
              )
              .toList();
        } on HTError catch (err) {
          HetuManager.editError(err);
          rethrow;
        }
      },
      getPage: (final PageInfo page) async {
        try {
          final dynamic result = await runner.invoke(
            'getPage',
            positionalArgs: <dynamic>[
              page.toJson(),
            ],
          );

          return ImageDescriber.fromJson(result as Map<dynamic, dynamic>);
        } on HTError catch (err) {
          HetuManager.editError(err);
          rethrow;
        }
      },
    );
  }
}
