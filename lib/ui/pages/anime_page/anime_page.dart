import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utilx/utilities/languages.dart';
import './watch_page.dart';
import '../../../config/defaults.dart';
import '../../../modules/app/state.dart';
import '../../../modules/database/database.dart';
import '../../../modules/database/schemas/cache/cache.dart';
import '../../../modules/extensions/extensions.dart';
import '../../../modules/helpers/assets.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/state/loader.dart';
import '../../../modules/trackers/trackers.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/utils/utils.dart';
import '../../components/toggleable_slide_widget.dart';
import '../../components/trackers/trackers_tile.dart';
import '../../router.dart';

extension on AnimeInfo {
  List<EpisodeInfo> get sortedEpisodes => ListUtils.tryArrange(
        episodes,
        (final EpisodeInfo x) => x.episode,
      );
}

enum Pages {
  home,
  player,
}

class PageArguments {
  PageArguments({
    required final this.src,
    required final this.plugin,
  });

  factory PageArguments.fromJson(final Map<String, String> json) {
    if (json['src'] == null) {
      throw ArgumentError("Got null value for 'src'");
    }
    if (json['plugin'] == null) {
      throw ArgumentError("Got null value for 'plugin'");
    }

    return PageArguments(src: json['src']!, plugin: json['plugin']!);
  }

  String src;
  String plugin;

  Map<String, String> toJson() => <String, String>{
        'src': src,
        'plugin': plugin,
      };
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page>
    with TickerProviderStateMixin, InitialStateLoader {
  AnimeInfo? info;

  EpisodeInfo? episode;
  int? currentEpisodeIndex;

  late PageController controller;

  ScrollDirection? lastScrollDirection;
  final ValueNotifier<bool> showFloatingButton = ValueNotifier<bool>(true);
  late AnimationController floatingButtonController;

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  late PageArguments args;
  late AnimeExtractor extractor;

  LanguageCodes? locale;

  final int maxChunkLength = AppState.isDesktop ? 100 : 30;

  @override
  void initState() {
    super.initState();

    controller = PageController(
      initialPage: Pages.home.index,
    );

    floatingButtonController = AnimationController(
      vsync: this,
      duration: Defaults.animationsNormal,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    maybeLoad();
  }

  @override
  void dispose() {
    controller.dispose();
    showFloatingButton.dispose();
    floatingButtonController.dispose();

    super.dispose();
  }

  @override
  Future<void> load() async {
    args = PageArguments.fromJson(
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

    final CacheSchema? cachedAnime =
        removeCache ? null : DataBox.cache.get(cacheKey);

    if (cachedAnime != null &&
        nowMs - cachedAnime.cachedTime <
            Defaults.cachedAnimeInfoExpireTime.inMilliseconds) {
      try {
        if (mounted) {
          setState(() {
            info = AnimeInfo.fromJson(
              cachedAnime.value as Map<dynamic, dynamic>,
            );
          });
        }

        return;
      } catch (_) {}
    }

    info = await extractor.getInfo(
      args.src,
      locale?.name ?? extractor.defaultLocale,
    );

    await DataBox.cache.put(
      cacheKey,
      CacheSchema(info!.toJson(), nowMs),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> goToPage(final Pages page) async {
    if (controller.hasClients) {
      await controller.animateToPage(
        page.index,
        duration: Defaults.animationsNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  void setEpisode(
    final int? index,
  ) {
    if (mounted) {
      setState(() {
        currentEpisodeIndex = index;
        episode = index != null ? info!.sortedEpisodes[index] : null;
      });
    }
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
              dark: UiUtils.isDarkContext(context),
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

  Widget getEpisodes(
    final int start,
    final int end,
    final EdgeInsets padding,
  ) {
    const Widget filler = Expanded(
      child: SizedBox.shrink(),
    );

    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView(
        padding: padding,
        children: ListUtils.chunk<Widget>(
          info!.sortedEpisodes
              .sublist(
                start,
                end,
              )
              .asMap()
              .map(
                (
                  final int k,
                  final EpisodeInfo x,
                ) =>
                    MapEntry<int, Widget>(
                  k,
                  Expanded(
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: remToPx(0.4),
                            vertical: remToPx(0.3),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: <InlineSpan>[
                                TextSpan(
                                  text: '${Translator.t.episode()} ',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.subtitle2,
                                ),
                                TextSpan(
                                  text: x.episode.padLeft(
                                    2,
                                    '0',
                                  ),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.subtitle2?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () {
                          setEpisode(start + k);
                          goToPage(Pages.player);
                        },
                      ),
                    ),
                  ),
                ),
              )
              .values
              .toList(),
          MediaQuery.of(context).size.width ~/ remToPx(8),
          filler,
        )
            .map(
              (final List<Widget> x) => Row(
                children: x,
              ),
            )
            .toList(),
      ),
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
                        LanguageUtils.languageCodeMap[info!.locale] ??
                            LanguageCodes.en;

                    final LanguageCodes lang =
                        LanguageUtils.languageCodeMap[x] ?? LanguageCodes.en;

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
    final double paddingHorizontal = remToPx(isLarge ? 3 : 1.25);

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
                      appBar: PreferredSize(
                        preferredSize: appBar.preferredSize,
                        child: ValueListenableBuilder<bool>(
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
                            offsetEnd: const Offset(0, -1),
                            child: child!,
                          ),
                          child: appBar,
                        ),
                      ),
                      body: DefaultTabController(
                        length: tabCount,
                        child: NestedScrollView(
                          headerSliverBuilder: (
                            final BuildContext context,
                            final bool innerBoxIsScrolled,
                          ) =>
                              <Widget>[
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: paddingHorizontal,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate.fixed(
                                  <Widget>[
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
                                      providers: Trackers.anime,
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
                                  ],
                                ),
                              ),
                            ),
                            if (tabCount > 1)
                              SliverPadding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: paddingHorizontal,
                                ),
                                sliver: SliverAppBar(
                                  primary: false,
                                  pinned: true,
                                  floating: true,
                                  automaticallyImplyLeading: false,
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  titleSpacing: 0,
                                  centerTitle: true,
                                  title: ScrollConfiguration(
                                    behavior: MiceScrollBehavior(),
                                    child: TabBar(
                                      isScrollable: true,
                                      tabs: List<Widget>.generate(
                                        tabCount,
                                        (final int i) {
                                          final int start = i * maxChunkLength;
                                          return Tab(
                                            text:
                                                '$start - ${start + maxChunkLength}',
                                          );
                                        },
                                      ),
                                      labelColor: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.color,
                                      indicatorColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          body: TabBarView(
                            children: List<Widget>.generate(
                              tabCount,
                              (final int i) {
                                final int start = i * maxChunkLength;
                                final int totalLength =
                                    info!.sortedEpisodes.length;
                                final int end = start + maxChunkLength;
                                final int extra =
                                    end > totalLength ? end - totalLength : 0;

                                return Builder(
                                  builder: (final BuildContext context) =>
                                      getEpisodes(
                                    start,
                                    end - extra,
                                    EdgeInsets.symmetric(
                                      horizontal: paddingHorizontal,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // ),
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
          await goToPage(Pages.home);
          setEpisode(null);
          return false;
        }

        Navigator.of(context).pop();
        return true;
      },
    );
  }

  int get tabCount => (info!.sortedEpisodes.length / maxChunkLength).ceil();
}
