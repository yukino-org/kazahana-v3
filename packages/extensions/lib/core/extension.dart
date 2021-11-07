import 'package:hetu_script/hetu_script.dart';
import 'package:utilx/utilities/locale.dart';
import './resolved.dart';
import '../../models/anime.dart';
import '../../models/base.dart';
import '../../models/manga.dart';
import '../hetu/hetu.dart';
import '../utils/html_dom/html_dom.dart';

export './base.dart';
export './resolvable.dart';
export './resolved.dart';

abstract class ExtensionInternals {
  static Future<void> initialize() async {
    await HtmlDOMManager.initialize();
  }

  static Future<void> dispose() async {
    await HtmlDOMManager.dispose();
  }

  static Future<void> _cleanAfterMethod() async {
    await HtmlDOMManager.provider.clean();
  }

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

          await _cleanAfterMethod();
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

          await _cleanAfterMethod();
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

          await _cleanAfterMethod();
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

          await _cleanAfterMethod();
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

          await _cleanAfterMethod();
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

          await _cleanAfterMethod();
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

          await _cleanAfterMethod();
          return ImageDescriber.fromJson(result as Map<dynamic, dynamic>);
        } on HTError catch (err) {
          HetuManager.editError(err);
          rethrow;
        }
      },
    );
  }
}
