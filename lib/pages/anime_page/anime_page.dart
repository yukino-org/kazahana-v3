import 'package:extensions/extensions.dart' as extensions;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './watch_page.dart';
import '../../components/toggleable_slide_widget.dart';
import '../../components/trackers/trackers_tile.dart';
import '../../config.dart';
import '../../core/extensions.dart';
import '../../core/models/languages.dart';
import '../../core/models/page_args/anime_page.dart' as anime_page;
import '../../core/trackers/providers.dart';
import '../../plugins/database/database.dart' show DataBox;
import '../../plugins/database/schemas/cache/cache.dart' as cache_schema;
import '../../plugins/helpers/assets.dart';
import '../../plugins/helpers/stateful_holder.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/helpers/utils/list.dart';
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';

extension on extensions.AnimeInfo {
  List<extensions.EpisodeInfo> get sortedEpisodes => ListUtils.tryArrange(
        episodes,
        (final extensions.EpisodeInfo x) => x.episode,
      );
}

enum Pages {
  home,
  player,
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page>
    with SingleTickerProviderStateMixin, DidLoadStater {
  extensions.AnimeInfo? info;

  extensions.EpisodeInfo? episode;
  int? currentEpisodeIndex;

  late PageController controller;

  ScrollDirection? lastScrollDirection;
  final ValueNotifier<bool> showFloatingButton = ValueNotifier<bool>(true);
  late AnimationController floatingButtonController;

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  late anime_page.PageArguments args;
  late extensions.AnimeExtractor extractor;

  LanguageCodes? locale;
  bool ignoreAutoFullscreen = false;

  final Duration animationDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();

    controller = PageController(
      initialPage: Pages.home.index,
    );

    floatingButtonController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
  }

  @override
  Future<void> load() async {
    args = anime_page.PageArguments.fromJson(
      ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
    );

    // TODO: Error handling
    extractor = ExtensionsManager.animes[args.plugin]!;
    getInfo();
  }

  Future<void> getInfo({
    final bool removeCache = false,
  }) async {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final String cacheKey = 'anime-${extractor.id}-${args.src}';

    if (removeCache) {
      await DataBox.cache.delete(cacheKey);
    }

    final cache_schema.CacheSchema? cachedAnime =
        removeCache ? null : DataBox.cache.get(cacheKey);

    if (cachedAnime != null &&
        nowMs - cachedAnime.cachedTime <
            MiscSettings.cachedAnimeInfoExpireTime.inMilliseconds) {
      try {
        if (mounted) {
          setState(() {
            info = extensions.AnimeInfo.fromJson(
              cachedAnime.value as Map<dynamic, dynamic>,
            );
          });
        }

        return;
      } catch (_) {}
    }

    info = await extractor.getInfo(
      args.src,
      locale?.code ?? extractor.defaultLocale,
    );

    await DataBox.cache.put(
      cacheKey,
      cache_schema.CacheSchema(
        info!.toJson(),
        nowMs,
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> goToPage(final Pages page) async {
    await controller.animateToPage(
      page.index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void setEpisode(
    final int? index,
  ) {
    setState(() {
      currentEpisodeIndex = index;
      episode = index != null ? info!.sortedEpisodes[index] : null;
    });
  }

  Widget getHero(
    final BuildContext context,
  ) {
    final double width = MediaQuery.of(context).size.width;

    final Widget image = info!.thumbnail != null
        ? Image.network(
            info!.thumbnail!.url,
            headers: info!.thumbnail!.headers,
            width: width > ResponsiveSizes.md ? (15 / 100) * width : remToPx(7),
          )
        : Image.asset(
            Assets.placeholderImage(
              dark: isDarkContext(context),
            ),
            width: width > ResponsiveSizes.md ? (15 / 100) * width : remToPx(7),
          );

    final Widget left = ClipRRect(
      borderRadius: BorderRadius.circular(remToPx(0.5)),
      child: image,
    );

    final Widget right = Column(
      children: <Widget>[
        Text(
          info!.title,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.headline4?.fontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          extractor.name,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: Theme.of(context).textTheme.headline6?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    if (width > ResponsiveSizes.md) {
      return Row(
        children: <Widget>[
          left,
          SizedBox(
            width: remToPx(1),
          ),
          Expanded(child: right),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          left,
          SizedBox(
            height: remToPx(1),
          ),
          right,
        ],
      );
    }
  }

  Widget getGridLayout(final int count, final List<Widget> children) {
    const Widget filler = Expanded(
      child: SizedBox.shrink(),
    );

    return Column(
      children: ListUtils.chunk<Widget>(children, count, filler)
          .map(
            (final List<Widget> x) => Row(
              children: x,
            ),
          )
          .toList(),
    );
  }

  Future<void> showLanguageDialog() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (
        final BuildContext context,
        final Animation<double> a1,
        final Animation<double> a2,
      ) =>
          SafeArea(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: remToPx(0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: remToPx(1.1),
                  ),
                  child: Text(
                    Translator.t.chooseLanguage(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                SizedBox(
                  height: remToPx(0.3),
                ),
                ...info!.availableLocales.map(
                  (final String x) {
                    final LanguageCodes groupVal =
                        LanguageUtils.codeLangaugeMap[info!.locale] ??
                            LanguageCodes.en;

                    final LanguageCodes lang =
                        LanguageUtils.codeLangaugeMap[x] ?? LanguageCodes.en;

                    return Material(
                      type: MaterialType.transparency,
                      child: RadioListTile<LanguageCodes>(
                        title: Text(lang.language),
                        value: lang,
                        groupValue: groupVal,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (final LanguageCodes? val) {
                          if (val != null && val != groupVal) {
                            setState(() {
                              locale = val;
                              info = null;
                            });
                            getInfo(removeCache: true);
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ).toList(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: remToPx(0.7),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: remToPx(0.6),
                          vertical: remToPx(0.3),
                        ),
                        child: Text(
                          Translator.t.close(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final PreferredSizeWidget appBar = AppBar(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
      elevation: 0,
      iconTheme: IconTheme.of(context).copyWith(
        color: Theme.of(context).textTheme.headline6?.color,
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            setState(() {
              info = null;
            });
            getInfo(removeCache: true);
          },
          tooltip: Translator.t.refetch(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );

    final bool isLarge = MediaQuery.of(context).size.width > ResponsiveSizes.md;

    return WillPopScope(
      child: SafeArea(
        child: info != null
            ? PageView(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  NotificationListener<ScrollNotification>(
                    onNotification: (final ScrollNotification notification) {
                      if (notification is UserScrollNotification) {
                        showFloatingButton.value =
                            notification.direction != ScrollDirection.reverse &&
                                lastScrollDirection != ScrollDirection.reverse;

                        if (notification.direction == ScrollDirection.forward ||
                            notification.direction == ScrollDirection.reverse) {
                          lastScrollDirection = notification.direction;
                        }
                      }

                      return false;
                    },
                    child: Scaffold(
                      extendBodyBehindAppBar: true,
                      appBar: appBar,
                      body: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: remToPx(isLarge ? 3 : 1.25),
                            right: remToPx(isLarge ? 3 : 1.25),
                            top: remToPx(isLarge ? 1 : 0),
                            bottom: remToPx(isLarge ? 2 : 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SizedBox(
                                height: appBar.preferredSize.height,
                              ),
                              getHero(
                                context,
                              ),
                              SizedBox(
                                height: remToPx(1.5),
                              ),
                              TrackersTile(
                                title: info!.title,
                                plugin: extractor.id,
                                providers: animeProviders,
                              ),
                              SizedBox(
                                height: remToPx(1.5),
                              ),
                              Text(
                                Translator.t.episodes(),
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      ?.fontSize,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                              getGridLayout(
                                MediaQuery.of(context).size.width ~/ remToPx(8),
                                info!.sortedEpisodes
                                    .asMap()
                                    .map(
                                      (
                                        final int k,
                                        final extensions.EpisodeInfo x,
                                      ) =>
                                          MapEntry<int, Widget>(
                                        k,
                                        Expanded(
                                          child: Card(
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: remToPx(0.4),
                                                  vertical: remToPx(0.3),
                                                ),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        text:
                                                            '${Translator.t.episode()} ',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle2,
                                                      ),
                                                      TextSpan(
                                                        text: x.episode.padLeft(
                                                          2,
                                                          '0',
                                                        ),
                                                        style: Theme.of(
                                                          context,
                                                        )
                                                            .textTheme
                                                            .subtitle2
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              onTap: () {
                                                setEpisode(k);
                                                goToPage(Pages.player);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .values
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      floatingActionButton: ValueListenableBuilder<bool>(
                        valueListenable: showFloatingButton,
                        builder: (
                          final BuildContext context,
                          final bool showFloatingButton,
                          final Widget? child,
                        ) =>
                            ToggleableSlideWidget(
                          controller: floatingButtonController,
                          visible: showFloatingButton,
                          curve: Curves.easeInOut,
                          offsetBegin: Offset.zero,
                          offsetEnd: const Offset(0, 1.5),
                          child: child!,
                        ),
                        child: FloatingActionButton.extended(
                          icon: const Icon(Icons.language),
                          label: Text(Translator.t.language()),
                          onPressed: () {
                            showLanguageDialog();
                          },
                        ),
                      ),
                    ),
                  ),
                  if (episode != null)
                    WatchPage(
                      key: ValueKey<String>(
                        'Episode-$currentEpisodeIndex',
                      ),
                      title: info!.title,
                      extractor: extractor,
                      episode: episode!,
                      totalEpisodes: info!.episodes.length,
                      previousEpisodeEnabled: currentEpisodeIndex! - 1 >= 0,
                      previousEpisode: () {
                        if (currentEpisodeIndex! - 1 >= 0) {
                          setEpisode(currentEpisodeIndex! - 1);
                        }
                      },
                      nextEpisodeEnabled:
                          currentEpisodeIndex! + 1 < info!.episodes.length,
                      nextEpisode: () {
                        if (currentEpisodeIndex! + 1 < info!.episodes.length) {
                          setEpisode(currentEpisodeIndex! + 1);
                        }
                      },
                      ignoreAutoFullscreen: ignoreAutoFullscreen,
                      onIgnoreAutoFullscreenChange:
                          (final bool _ignoreAutoFullscreen) {
                        ignoreAutoFullscreen = _ignoreAutoFullscreen;
                      },
                      onPop: () {
                        setEpisode(null);
                        goToPage(Pages.home);
                      },
                    )
                  else
                    const SizedBox.shrink(),
                ],
              )
            : Scaffold(
                appBar: appBar,
                body: loader,
              ),
      ),
      onWillPop: () async {
        if (info != null && controller.page?.toInt() != Pages.home.index) {
          setEpisode(null);
          goToPage(Pages.home);
          return false;
        }

        Navigator.of(context).pop();
        return true;
      },
    );
  }
}
