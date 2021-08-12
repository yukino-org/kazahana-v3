import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './watch_page.dart';
import '../../components/full_screen.dart';
import '../../components/toggleable_slide_widget.dart';
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/models/anime_page.dart' as anime_page;
import '../../core/models/languages.dart';
import '../../plugins/config.dart' as config;
import '../../plugins/database/database.dart' show DataBox;
import '../../plugins/database/schemas/cached_result/cached_result.dart'
    as cached_result;
import '../../plugins/helpers/assets.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/helpers/utils/list.dart';
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';

enum Pages {
  home,
  player,
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> with SingleTickerProviderStateMixin {
  anime_model.AnimeInfo? info;

  anime_model.EpisodeInfo? episode;
  int? currentEpisodeIndex;

  late PageController controller;
  Map<anime_model.EpisodeInfo, List<anime_model.EpisodeSource>> sources =
      <anime_model.EpisodeInfo, List<anime_model.EpisodeSource>>{};

  ScrollDirection? lastScrollDirection;
  final ValueNotifier<bool> showFloatingButton = ValueNotifier<bool>(true);
  late AnimationController floatingButtonController;

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  late anime_page.PageArguments args;
  LanguageCodes? locale;

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

    Future<void>.delayed(Duration.zero, () async {
      args = anime_page.PageArguments.fromJson(
        RouteManager.parseRoute(ModalRoute.of(context)!.settings.name!).params,
      );

      getInfo();
    });
  }

  Future<void> goToPage(final Pages page) async {
    await controller.animateToPage(
      page.index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Future<void> getInfo({
    final bool removeCache = false,
  }) async {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final String cacheKey = '${args.plugin}-${args.src}';

    if (removeCache) {
      await DataBox.animeInfo.delete(cacheKey);
    }

    final cached_result.CachedResultSchema? cachedAnime =
        removeCache ? null : DataBox.animeInfo.get(cacheKey);

    if (cachedAnime != null &&
        nowMs - cachedAnime.cachedTime <
            config.cachedAnimeInfoExpireTime.inMilliseconds) {
      try {
        info = anime_model.AnimeInfo.fromJson(cachedAnime.info);
        setState(() {});
        return;
      } catch (_) {
        rethrow;
      }
    }

    info = await extractor.Extractors.anime[args.plugin]!.getInfo(
      args.src,
      locale: locale ?? extractor.Extractors.anime[args.plugin]!.defaultLocale,
    );
    await DataBox.animeInfo.put(
      cacheKey,
      cached_result.CachedResultSchema(
        info: info!.toJson(),
        cachedTime: nowMs,
      ),
    );
    setState(() {});
  }

  void setEpisode(
    final int? index,
  ) {
    setState(() {
      currentEpisodeIndex = index;
      episode = index != null ? info!.episodes[index] : null;
    });

    if (episode != null && sources[episode] == null) {
      extractor.Extractors.anime[args.plugin]!
          .getSources(episode!)
          .then((final List<anime_model.EpisodeSource> x) {
        setState(() {
          sources[episode!] = x;
        });
      });
    }
  }

  Widget getHero(
    final BuildContext context,
    final BoxConstraints constraints,
  ) {
    final Widget image = info!.thumbnail != null
        ? Image.network(
            info!.thumbnail!.url,
            headers: info!.thumbnail!.headers,
            width: remToPx(7),
          )
        : Image.asset(
            Assets.placeholderImage(
              dark: isDarkContext(context),
            ),
            width: remToPx(7),
          );

    final Widget left = ClipRRect(
      borderRadius: BorderRadius.circular(remToPx(0.5)),
      child: SizedBox(
        width: constraints.maxWidth > ResponsiveSizes.md
            ? (30 / 100) * constraints.maxWidth
            : remToPx(8),
        child: image,
      ),
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
          args.plugin,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: Theme.of(context).textTheme.headline6?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    if (constraints.maxWidth > ResponsiveSizes.md) {
      return Row(
        children: <Widget>[
          left,
          right,
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

  void showLanguageDialog() {
    showDialog(
      context: context,
      builder: (final BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                ),
                child: Text(
                  Translator.t.chooseLanguage(),
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              ...info!.availableLocales
                  .map(
                    (final LanguageCodes x) => Material(
                      type: MaterialType.transparency,
                      child: RadioListTile<LanguageCodes>(
                        title: Text(x.language),
                        value: x,
                        groupValue: info!.locale,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (final LanguageCodes? val) {
                          if (val != null && val != info!.locale) {
                            setState(() {
                              locale = val;
                              info = null;
                            });
                            getInfo(removeCache: true);
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  )
                  .toList(),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
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
    );
  }

  @override
  Widget build(final BuildContext context) {
    final PreferredSizeWidget appBar = AppBar(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
      elevation: 0,
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

    return WillPopScope(
      child: SafeArea(
        child: info != null
            ? LayoutBuilder(
                builder: (
                  final BuildContext context,
                  final BoxConstraints constraints,
                ) =>
                    PageView(
                  controller: controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    NotificationListener<ScrollNotification>(
                      onNotification: (final ScrollNotification notification) {
                        if (notification is UserScrollNotification) {
                          showFloatingButton.value = notification.direction !=
                                  ScrollDirection.reverse &&
                              lastScrollDirection != ScrollDirection.reverse;

                          if (notification.direction ==
                                  ScrollDirection.forward ||
                              notification.direction ==
                                  ScrollDirection.reverse) {
                            lastScrollDirection = notification.direction;
                          }
                        }

                        return false;
                      },
                      child: Scaffold(
                        extendBodyBehindAppBar: true,
                        appBar: appBar,
                        body: SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.only(
                              left: remToPx(1.25),
                              right: remToPx(1.25),
                              bottom: remToPx(1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                SizedBox(
                                  height: appBar.preferredSize.height,
                                ),
                                getHero(
                                  context,
                                  constraints,
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
                                  constraints.maxWidth ~/ remToPx(8),
                                  info!.episodes
                                      .asMap()
                                      .map(
                                        (
                                          final int k,
                                          final anime_model.EpisodeInfo x,
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
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .subtitle2,
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              x.episode.padLeft(
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
                            offsetBegin: const Offset(0, 0),
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
                      sources[episode] != null
                          ? sources[episode]!.isNotEmpty
                              ? FullScreenWidget(
                                  child: WatchPage(
                                    key: ValueKey<String>(
                                      'Episode-$currentEpisodeIndex',
                                    ),
                                    sources: sources[episode]!,
                                    title: Flexible(
                                      fit: FlexFit.tight,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            info!.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                                          Text(
                                            '${Translator.t.episode()} ${episode!.episode} of ${info!.episodes.length}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    previousEpisodeEnabled:
                                        currentEpisodeIndex! - 1 >= 0,
                                    previousEpisode: () {
                                      if (currentEpisodeIndex! - 1 >= 0) {
                                        setEpisode(currentEpisodeIndex! - 1);
                                      }
                                    },
                                    nextEpisodeEnabled:
                                        currentEpisodeIndex! + 1 <
                                            info!.episodes.length,
                                    nextEpisode: () {
                                      if (currentEpisodeIndex! + 1 <
                                          info!.episodes.length) {
                                        setEpisode(currentEpisodeIndex! + 1);
                                      }
                                    },
                                    onPop: () {
                                      setEpisode(null);
                                      goToPage(Pages.home);
                                    },
                                  ),
                                )
                              : Material(
                                  type: MaterialType.transparency,
                                  child: Center(
                                    child: Text(
                                      Translator.t.noValidSources(),
                                    ),
                                  ),
                                )
                          : loader
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              )
            : loader,
      ),
      onWillPop: () async {
        if (controller.page!.toInt() != Pages.home.index) {
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
