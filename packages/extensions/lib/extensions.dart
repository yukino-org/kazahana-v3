library extensions;

import 'dart:async';
import 'package:hetu_script/hetu_script.dart';
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

class Extension {
  Extension({
    required final this.name,
    required final this.id,
    required final this.version,
    required final this.type,
    required final this.code,
  });

  factory Extension.fromJson(final Map<dynamic, dynamic> json) => Extension(
        name: json['name'] as String,
        id: json['id'] as String,
        version: json['version'] as int,
        type: ExtensionType.values.firstWhere(
          (final ExtensionType type) => type.type == (json['type'] as String),
        ),
        code: json['code'] as String,
      );

  final String name;
  final String id;
  final int version;
  final ExtensionType type;
  final String code;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'name': name,
        'id': id,
        'version': version,
        'type': type.type,
        'code': code,
      };
}

abstract class ExtensionUtils {
  static Future<AnimeExtractor> transpileToAnimeExtractor(
    final Extension ext,
  ) async {
    final Hetu runner = await createHetu();

    await runner.eval(ext.code);

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
    final Extension ext,
  ) async {
    final Hetu runner = await createHetu();

    await runner.eval(ext.code);

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
