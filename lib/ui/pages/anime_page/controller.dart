import 'package:flutter/material.dart';
import 'package:extensions/extensions.dart';
import 'package:utilx/utilities/locale.dart';
import 'package:yukino_app/config/defaults.dart';
import 'package:yukino_app/modules/database/database.dart';
import 'package:yukino_app/modules/extensions/extensions.dart';
import 'package:yukino_app/modules/state/stateful_holder.dart';
import 'package:yukino_app/ui/router.dart';
import '../../../modules/utils/utils.dart';
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

class AnimeViewController extends Controller {
  AnimePageArguments? args;
  AnimeExtractor? extractor;
  EpisodeInfo? episode;
  Locale? locale;

  final StatefulValueHolderWithError<AnimeInfo?> info =
      StatefulValueHolderWithError<AnimeInfo?>(null);

  final PageController pageController = PageController(
    initialPage: SubPages.home.index,
  );

  @override
  Future<void> ready(final BuildContext context) async {
    super.ready(context);

    args = AnimePageArguments.fromJson(
      ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
    );

    extractor = ExtensionsManager.animes[args!.plugin];
    if (extractor != null) {
      await getInfo();
    }
  }

  int? _currentEpisodeIndex;
  int? get currentEpisodeIndex => _currentEpisodeIndex;
  set currentEpisodeIndex(final int? index) {
    _currentEpisodeIndex = index;
    episode = index != null ? info.value!.sortedEpisodes[index] : null;
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
    try {
      info.resolving(null);
      rebuild();

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
          rebuild();

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

      rebuild();
    } catch (err, stack) {
      info.fail(null, ErrorInfo(err, stack));
    }
  }
}
