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
        final Completer<List<SearchInfo>> future =
            Completer<List<SearchInfo>>();

        runner.invoke(
          'search',
          positionalArgs: <dynamic>[
            terms,
            locale,
            (final String? err, final List<dynamic>? results) {
              if (err != null) {
                return future.completeError(err);
              }

              return future.complete(
                results!
                    .map(
                      (final dynamic x) =>
                          SearchInfo.fromJson(x as Map<dynamic, dynamic>),
                    )
                    .toList(),
              );
            },
          ],
        );

        return future.future;
      },
      getInfo: (final String url, final String locale) async {
        final Completer<AnimeInfo> future = Completer<AnimeInfo>();

        runner.invoke(
          'getInfo',
          positionalArgs: <dynamic>[
            url,
            locale,
            (final String? err, final dynamic result) {
              if (err != null) {
                return future.completeError(err);
              }

              return future.complete(
                AnimeInfo.fromJson(result as Map<dynamic, dynamic>),
              );
            },
          ],
        );

        return future.future;
      },
      getSources: (final EpisodeInfo episode) async {
        final Completer<List<EpisodeSource>> future =
            Completer<List<EpisodeSource>>();

        runner.invoke(
          'getSources',
          positionalArgs: <dynamic>[
            episode.toJson(),
            (final String? err, final List<dynamic>? results) {
              if (err != null) {
                return future.completeError(err);
              }

              return future.complete(
                results!
                    .map(
                      (final dynamic x) =>
                          EpisodeSource.fromJson(x as Map<dynamic, dynamic>),
                    )
                    .toList(),
              );
            },
          ],
        );

        return future.future;
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
        final Completer<List<SearchInfo>> future =
            Completer<List<SearchInfo>>();

        runner.invoke(
          'search',
          positionalArgs: <dynamic>[
            terms,
            locale,
            (final String? err, final List<dynamic>? results) {
              if (err != null) {
                return future.completeError(err);
              }

              return future.complete(
                results!
                    .map(
                      (final dynamic x) =>
                          SearchInfo.fromJson(x as Map<dynamic, dynamic>),
                    )
                    .toList(),
              );
            },
          ],
        );

        return future.future;
      },
      getInfo: (final String url, final String locale) async {
        final Completer<MangaInfo> future = Completer<MangaInfo>();

        runner.invoke(
          'getInfo',
          positionalArgs: <dynamic>[
            url,
            locale,
            (final String? err, final dynamic result) {
              if (err != null) {
                return future.completeError(err);
              }

              return future.complete(
                MangaInfo.fromJson(result as Map<dynamic, dynamic>),
              );
            },
          ],
        );

        return future.future;
      },
      getChapter: (final ChapterInfo chapter) async {
        final Completer<List<PageInfo>> future = Completer<List<PageInfo>>();

        runner.invoke(
          'getChapter',
          positionalArgs: <dynamic>[
            chapter.toJson(),
            (final String? err, final List<dynamic>? results) {
              if (err != null) {
                return future.completeError(err);
              }

              return future.complete(
                results!
                    .map(
                      (final dynamic x) =>
                          PageInfo.fromJson(x as Map<dynamic, dynamic>),
                    )
                    .toList(),
              );
            },
          ],
        );

        return future.future;
      },
      getPage: (final PageInfo page) async {
        final Completer<ImageInfo> future = Completer<ImageInfo>();

        runner.invoke(
          'getPage',
          positionalArgs: <dynamic>[
            page.toJson(),
            (final String? err, final dynamic result) {
              if (err != null) {
                return future.completeError(err);
              }

              return future.complete(
                ImageInfo.fromJson(result as Map<dynamic, dynamic>),
              );
            },
          ],
        );

        return future.future;
      },
    );
  }
}
