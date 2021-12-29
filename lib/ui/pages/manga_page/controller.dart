import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/locale.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../config/defaults.dart';
import '../../../modules/database/database.dart';
import '../../../modules/extensions/extensions.dart';
import '../../../modules/state/stateful_holder.dart';
import '../../../modules/state/states.dart';
import '../../../ui/router.dart';
import '../../models/controller.dart';

enum SubPages {
  home,
  reader,
}

extension MangaInfoUtils on MangaInfo {
  List<ChapterInfo> get sortedChapters => ListUtils.tryArrange(
        chapters,
        (final ChapterInfo x) => x.chapter,
      );
}

class MangaPageArguments {
  MangaPageArguments({
    required final this.src,
    required final this.plugin,
  });

  factory MangaPageArguments.fromJson(final Map<String, String> json) {
    if (json['src'] == null) {
      throw ArgumentError("Got null value for 'src'");
    }
    if (json['plugin'] == null) {
      throw ArgumentError("Got null value for 'plugin'");
    }

    return MangaPageArguments(src: json['src']!, plugin: json['plugin']!);
  }

  String src;
  String plugin;

  Map<String, String> toJson() => <String, String>{
        'src': src,
        'plugin': plugin,
      };
}

class MangaPageController extends Controller<MangaPageController> {
  MangaPageController({
    required final this.pageController,
  });

  final PageController pageController;

  bool initialized = false;
  MangaPageArguments? args;
  MangaExtractor? extractor;
  int? currentChapterIndex;
  Locale? locale;

  final StatefulValueHolderWithError<MangaInfo?> info =
      StatefulValueHolderWithError<MangaInfo?>(null);

  Future<void> onInitState(final BuildContext context) async {
    args = MangaPageArguments.fromJson(
      ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
    );

    extractor = ExtensionsManager.mangas[args!.plugin];
    if (extractor != null) {
      await getInfo();
    }

    initialized = true;
    reassemble();
  }

  Future<void> setCurrentChapterIndex(final int? index) async {
    currentChapterIndex = index;
    reassemble();
  }

  Future<void> goToPage(final SubPages page) async {
    if (pageController.hasClients) {
      await pageController.animateToPage(
        page.index,
        duration: Defaults.animationsNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> getInfo({
    final bool removeCache = false,
  }) async {
    info.resolving(null);
    reassemble();

    try {
      final int nowMs = DateTime.now().millisecondsSinceEpoch;
      final String cacheKey = 'manga-${extractor!.id}-${args!.src}';

      if (removeCache) {
        CacheBox.delete(cacheKey);
      }

      final CacheSchema? cachedManga =
          removeCache ? null : CacheBox.get(cacheKey);

      if (cachedManga != null &&
          nowMs - cachedManga.cachedTime <
              Defaults.cachedMangaInfoExpireTime.inMilliseconds) {
        try {
          info.resolve(
            MangaInfo.fromJson(
              cachedManga.value as Map<dynamic, dynamic>,
            ),
          );
          reassemble();
          return;
        } catch (_) {}
      }

      info.resolve(
        await extractor!.getInfo(
          args!.src,
          locale ?? extractor!.defaultLocale,
        ),
      );

      await CacheBox.saveKV(cacheKey, info.value!.toJson(), nowMs);
    } catch (err, stack) {
      info.fail(null, ErrorInfo(err, stack));
    }

    reassemble();
  }

  Future<void> goHome() async {
    goToPage(SubPages.home);
    await setCurrentChapterIndex(null);
  }

  ChapterInfo? get currentChapter =>
      currentChapterIndex != null && info.state.hasResolved
          ? info.value!.sortedChapters[currentChapterIndex!]
          : null;

  SubPages get currentPage => SubPages.values.firstWhere(
        (final SubPages x) => x.index == pageController.page!.toInt(),
      );
}
