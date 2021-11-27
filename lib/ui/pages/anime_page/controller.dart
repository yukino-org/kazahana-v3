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
  player,
}

extension AnimeInfoUtils on AnimeInfo {
  List<EpisodeInfo> get sortedEpisodes => ListUtils.tryArrange(
        episodes,
        (final EpisodeInfo x) => x.episode,
      );
}

class AnimePageArguments {
  AnimePageArguments({
    required final this.src,
    required final this.plugin,
  });

  factory AnimePageArguments.fromJson(final Map<String, String> json) {
    if (json['src'] == null) {
      throw ArgumentError("Got null value for 'src'");
    }

    if (json['plugin'] == null) {
      throw ArgumentError("Got null value for 'plugin'");
    }

    return AnimePageArguments(src: json['src']!, plugin: json['plugin']!);
  }

  String src;
  String plugin;

  Map<String, String> toJson() => <String, String>{
        'src': src,
        'plugin': plugin,
      };
}

class AnimePageController extends Controller<AnimePageController> {
  AnimePageController({
    required final this.pageController,
  });

  final PageController pageController;

  bool initialized = false;
  AnimePageArguments? args;
  AnimeExtractor? extractor;
  Locale? locale;
  int? currentEpisodeIndex;

  final StatefulValueHolderWithError<AnimeInfo?> info =
      StatefulValueHolderWithError<AnimeInfo?>(null);

  Future<void> onInitState(final BuildContext context) async {
    args = AnimePageArguments.fromJson(
      ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
    );

    extractor = ExtensionsManager.animes[args!.plugin];
    if (extractor != null) {
      await getInfo();
    }

    initialized = true;
    reassemble();
  }

  void setCurrentEpisodeIndex(final int? index) {
    currentEpisodeIndex = index;
    reassemble();
  }

  Future<void> goHome() async {
    await goToPage(SubPages.home);
    setCurrentEpisodeIndex(null);
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
      final String cacheKey = 'anime-${extractor!.id}-${args!.src}';

      if (removeCache) {
        CacheBox.delete(cacheKey);
      }

      final CacheSchema? cachedAnime =
          removeCache ? null : CacheBox.get(cacheKey);

      if (cachedAnime != null &&
          nowMs - cachedAnime.cachedTime <
              Defaults.cachedAnimeInfoExpireTime.inMilliseconds) {
        try {
          info.resolve(
            AnimeInfo.fromJson(
              cachedAnime.value as Map<dynamic, dynamic>,
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

  SubPages get currentPage => SubPages.values.firstWhere(
        (final SubPages x) => x.index == pageController.page!.toInt(),
      );

  EpisodeInfo? get currentEpisode =>
      currentEpisodeIndex != null && info.state.hasResolved
          ? info.value!.sortedEpisodes[currentEpisodeIndex!]
          : null;
}
