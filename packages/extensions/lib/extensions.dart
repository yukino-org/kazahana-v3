library extensions;

import 'dart:async';
import 'package:hetu_script/hetu_script.dart';
import 'package:http/http.dart' as http;
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
    required final this.version,
    required final this.type,
    required final this.image,
  });

  factory BaseExtension.fromJson(final Map<dynamic, dynamic> json) =>
      BaseExtension(
        name: json['name'] as String,
        id: json['id'] as String,
        version: json['version'] as int,
        type: ExtensionType.values.firstWhere(
          (final ExtensionType type) => type.type == (json['type'] as String),
        ),
        image: json['image'] as String,
      );

  final String name;
  final String id;
  final int version;
  final ExtensionType type;
  final String image;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'name': name,
        'id': id,
        'version': version,
        'type': type.type,
        'image': image,
      };
}

class ResolvableExtension extends BaseExtension {
  ResolvableExtension({
    required final String name,
    required final String id,
    required final int version,
    required final ExtensionType type,
    required final String image,
    required final this.source,
  }) : super(
          name: name,
          id: id,
          version: version,
          type: type,
          image: image,
        );

  factory ResolvableExtension.fromJson(final Map<dynamic, dynamic> json) {
    final BaseExtension base = BaseExtension.fromJson(json);

    return ResolvableExtension(
      name: base.name,
      id: base.id,
      version: base.version,
      type: base.type,
      image: base.image,
      source: json['source'] as String,
    );
  }

  final String source;

  Future<ResolvedExtension> resolve() async {
    final http.Response res = await http.get(Uri.parse(source));

    return ResolvedExtension(
      name: name,
      id: id,
      version: version,
      type: type,
      image: image,
      code: res.body,
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
    required final int version,
    required final ExtensionType type,
    required final String image,
    required final this.code,
  }) : super(
          name: name,
          id: id,
          version: version,
          type: type,
          image: image,
        );

  factory ResolvedExtension.fromJson(final Map<dynamic, dynamic> json) {
    final BaseExtension base = BaseExtension.fromJson(json);

    return ResolvedExtension(
      name: base.name,
      id: base.id,
      version: base.version,
      type: base.type,
      image: base.image,
      code: json['code'] as String,
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
  static Future<AnimeExtractor> transpileToAnimeExtractor(
    final ResolvedExtension ext,
  ) async {
    final Hetu runner = await createHetu();

    await runner.eval(appendHetuExternals(ext.code));

    final String defaultLocale = runner.invoke('defaultLocale') as String;

    return AnimeExtractor(
      name: ext.name,
      id: ext.id,
      defaultLocale: defaultLocale,
      search: (final String terms, final String locale) async {
        final dynamic result = await runner.invoke(
          'search',
          positionalArgs: <dynamic>[
            terms,
            locale,
          ],
        );

        return (result as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .map(
              (final Map<dynamic, dynamic> x) => SearchInfo.fromJson(x),
            )
            .toList();
      },
      getInfo: (final String url, final String locale) async {
        final dynamic result = await runner.invoke(
          'getInfo',
          positionalArgs: <dynamic>[
            url,
            locale,
          ],
        );

        return AnimeInfo.fromJson(result as Map<dynamic, dynamic>);
      },
      getSources: (final EpisodeInfo episode) async {
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
      },
    );
  }

  static Future<MangaExtractor> transpileToMangaExtractor(
    final ResolvedExtension ext,
  ) async {
    final Hetu runner = await createHetu();

    await runner.eval(appendHetuExternals(ext.code));

    final String defaultLocale = runner.invoke('defaultLocale') as String;

    return MangaExtractor(
      name: ext.name,
      id: ext.id,
      defaultLocale: defaultLocale,
      search: (final String terms, final String locale) async {
        final dynamic result = await runner.invoke(
          'search',
          positionalArgs: <dynamic>[
            terms,
            locale,
          ],
        );

        return (result as List<dynamic>)
            .cast<Map<dynamic, dynamic>>()
            .map(
              (final Map<dynamic, dynamic> x) => SearchInfo.fromJson(x),
            )
            .toList();
      },
      getInfo: (final String url, final String locale) async {
        final dynamic result = await runner.invoke(
          'getInfo',
          positionalArgs: <dynamic>[
            url,
            locale,
          ],
        );

        return MangaInfo.fromJson(result as Map<dynamic, dynamic>);
      },
      getChapter: (final ChapterInfo chapter) async {
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
      },
      getPage: (final PageInfo page) async {
        final dynamic result = await runner.invoke(
          'getPage',
          positionalArgs: <dynamic>[
            page.toJson(),
          ],
        );

        return ImageInfo.fromJson(result as Map<dynamic, dynamic>);
      },
    );
  }
}
