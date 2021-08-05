import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../core/models/anime_page.dart' as anime_page;
import '../../core/models/languages.dart';
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';
import '../../components/full_screen.dart';
import '../../components/toggleable_slide_widget.dart';
import './watch_page.dart';

enum Pages { home, player }

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
  Map<anime_model.EpisodeInfo, List<anime_model.EpisodeSource>> sources = {};

  ScrollDirection? lastScrollDirection;
  final showFloatingButton = ValueNotifier(true);
  late AnimationController floatingButtonController;

  final loader = const Center(
    child: CircularProgressIndicator(),
  );

  late anime_page.PageArguments args;
  LanguageCodes? locale;

  final animationDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();

    controller = PageController(
      initialPage: Pages.home.index,
      keepPage: true,
    );

    floatingButtonController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );

    Future.delayed(Duration.zero, () async {
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

  void getInfo() => extractor.Extractors.anime[args.plugin]!
      .getInfo(
        args.src,
        locale:
            locale ?? extractor.Extractors.anime[args.plugin]!.defaultLocale,
      )
      .then((x) => setState(() {
            info = x;
          }));

  void setEpisode(
    int? index,
  ) {
    setState(() {
      currentEpisodeIndex = index;
      episode = index != null ? info!.episodes[index] : null;
    });

    if (episode != null && sources[episode] == null) {
      extractor.Extractors.anime[args.plugin]!.getSources(episode!).then((x) {
        setState(() {
          sources[episode!] = x;
        });
      });
    }
  }

  Widget getHero(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final image = info!.thumbnail != null
        ? Image.network(
            info!.thumbnail!,
            width: utils.remToPx(7),
          )
        : Image.asset(
            utils.Assets.placeholderImage(
              utils.Fns.isDarkContext(context),
            ),
            width: utils.remToPx(7),
          );

    final left = ClipRRect(
      borderRadius: BorderRadius.circular(utils.remToPx(0.5)),
      child: SizedBox(
        width: constraints.maxWidth > utils.ResponsiveSizes.md
            ? (30 / 100) * constraints.maxWidth
            : utils.remToPx(8),
        child: image,
      ),
    );

    final right = Column(
      children: [
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

    if (constraints.maxWidth > utils.ResponsiveSizes.md) {
      return Row(
        children: [
          left,
          right,
        ],
      );
    } else {
      return Column(
        children: [
          left,
          SizedBox(
            height: utils.remToPx(1),
          ),
          right,
        ],
      );
    }
  }

  Widget getGridLayout(int count, List<Widget> children) {
    // List<Widget> rows = [];
    // final size = children.length;
    const filler = Expanded(
      child: SizedBox.shrink(),
    );

    // for (var i = 0; i < children.length; i += count) {
    //   final end = i + count;
    //   final extra = end > size ? end - size : 0;

    //   rows.add(
    //     Row(
    //       children: [
    //         ...children.sublist(
    //           i,
    //           end - extra,
    //         ),
    //         ...List.generate(
    //           extra,
    //           (_) => filler,
    //         ),
    //       ],
    //     ),
    //   );
    // }

    return Column(
      children: utils.Fns.chunkList<Widget>(children, count, filler)
          .map(
            (x) => Row(
              children: x,
            ),
          )
          .toList(),
    );
  }

  void showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      (x) => Material(
                        type: MaterialType.transparency,
                        child: RadioListTile(
                          title: Text(x.language),
                          value: x,
                          groupValue: info!.locale,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (LanguageCodes? val) {
                            if (val != null && val != info!.locale) {
                              setState(() {
                                locale = val;
                                info = null;
                              });
                              getInfo();
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
                          horizontal: utils.remToPx(0.6),
                          vertical: utils.remToPx(0.3),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
      elevation: 0,
    );

    return WillPopScope(
        child: SafeArea(
          child: info != null
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return PageView(
                      controller: controller,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            if (notification is UserScrollNotification) {
                              showFloatingButton.value =
                                  notification.direction !=
                                          ScrollDirection.reverse &&
                                      lastScrollDirection !=
                                          ScrollDirection.reverse;

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
                                  left: utils.remToPx(1.25),
                                  right: utils.remToPx(1.25),
                                  bottom: utils.remToPx(1),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      height: appBar.preferredSize.height,
                                    ),
                                    getHero(
                                      context,
                                      constraints,
                                    ),
                                    SizedBox(
                                      height: utils.remToPx(1.5),
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
                                      constraints.maxWidth ~/ utils.remToPx(8),
                                      info!.episodes
                                          .asMap()
                                          .map(
                                            (k, x) => MapEntry(
                                              k,
                                              Expanded(
                                                child: Card(
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            utils.remToPx(0.4),
                                                        vertical:
                                                            utils.remToPx(0.3),
                                                      ),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  '${Translator.t.episode()} ',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .subtitle2,
                                                            ),
                                                            TextSpan(
                                                              text: x.episode
                                                                  .padLeft(
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
                                                        textAlign:
                                                            TextAlign.center,
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
                            floatingActionButton: ValueListenableBuilder(
                              valueListenable: showFloatingButton,
                              builder:
                                  (context, bool showFloatingButton, child) {
                                return ToggleableSlideWidget(
                                  controller: floatingButtonController,
                                  visible: showFloatingButton,
                                  child: child!,
                                  curve: Curves.easeInOut,
                                  offsetBegin: const Offset(0, 0),
                                  offsetEnd: const Offset(0, 1.5),
                                );
                              },
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
                        episode != null
                            ? sources[episode] != null
                                ? sources[episode]!.isNotEmpty
                                    ? FullScreenWidget(
                                        child: WatchPage(
                                          key: ValueKey(
                                            'Episode-$currentEpisodeIndex',
                                          ),
                                          sources: sources[episode]!,
                                          title: Flexible(
                                            fit: FlexFit.tight,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  info!.title,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                              setEpisode(
                                                  currentEpisodeIndex! - 1);
                                            }
                                          },
                                          nextEpisodeEnabled:
                                              currentEpisodeIndex! + 1 <
                                                  info!.episodes.length,
                                          nextEpisode: () {
                                            if (currentEpisodeIndex! + 1 <
                                                info!.episodes.length) {
                                              setEpisode(
                                                  currentEpisodeIndex! + 1);
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
                            : const SizedBox.shrink(),
                      ],
                    );
                  },
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
        });
  }
}
