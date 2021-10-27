import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utilx/utilities/languages.dart';
import './list_reader.dart';
import './page_reader.dart';
import '../../../config/defaults.dart';
import '../../../modules/app/state.dart';
import '../../../modules/database/database.dart';
import '../../../modules/database/schemas/cache/cache.dart';
import '../../../modules/database/schemas/settings/settings.dart';
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

extension on MangaInfo {
  List<ChapterInfo> get sortedChapters => ListUtils.tryArrange(
        chapters,
        (final ChapterInfo x) => x.chapter,
      );
}

enum Pages {
  home,
  reader,
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
    with SingleTickerProviderStateMixin, InitialStateLoader {
  MangaInfo? info;

  ChapterInfo? chapter;
  int? currentChapterIndex;
  Map<ChapterInfo, List<PageInfo>> pages = <ChapterInfo, List<PageInfo>>{};

  late PageController controller;

  ScrollDirection? lastScrollDirection;
  final ValueNotifier<bool> showFloatingButton = ValueNotifier<bool>(true);
  late AnimationController floatingButtonController;

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  late MangaExtractor extractor;
  late PageArguments args;

  LanguageCodes? locale;
  MangaMode mangaMode = AppState.settings.value.mangaReaderMode;

  final int maxChunkLength = AppState.isDesktop ? 25 : 15;

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

    AppState.settings.subscribe(_appStateChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    maybeLoad();
  }

  @override
  void dispose() {
    showFloatingButton.dispose();

    controller.dispose();
    AppState.settings.unsubscribe(_appStateChange);

    super.dispose();
  }

  @override
  Future<void> load() async {
    if (mounted) {
      args = PageArguments.fromJson(
        ParsedRouteInfo.fromSettings(ModalRoute.of(context)!.settings).params,
      );

      extractor = ExtensionsManager.mangas[args.plugin]!;
    }

    getInfo();
  }

  void _appStateChange(
    final SettingsSchema current,
    final SettingsSchema previous,
  ) {
    if (mounted) {
      setState(() {
        mangaMode = AppState.settings.value.mangaReaderMode;
      });
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

  Future<void> getInfo({
    final bool removeCache = false,
  }) async {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final String cacheKey = 'manga-${extractor.id}-${args.src}';

    if (removeCache) {
      await DataBox.cache.delete(cacheKey);
    }

    final CacheSchema? cachedManga =
        removeCache ? null : DataBox.cache.get(cacheKey);

    if (cachedManga != null &&
        nowMs - cachedManga.cachedTime <
            Defaults.cachedMangaInfoExpireTime.inMilliseconds) {
      try {
        if (mounted) {
          setState(() {
            info = MangaInfo.fromJson(
              cachedManga.value as Map<dynamic, dynamic>,
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

  Future<void> setChapter(
    final int? index,
  ) async {
    if (mounted) {
      setState(() {
        currentChapterIndex = index;
        chapter = index != null ? info!.sortedChapters[index] : null;
      });

      if (chapter != null && pages[chapter] == null) {
        final List<PageInfo> chapterPages =
            await extractor.getChapter(chapter!);

        if (mounted) {
          setState(() {
            pages[chapter!] = chapterPages;
          });
        }
      }
    }
  }

  Widget getHero(final BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    final Widget image = info!.thumbnail != null
        ? Image.network(
            info!.thumbnail!.url,
            headers: info!.thumbnail!.headers,
            width: remToPx(7),
          )
        : Image.asset(
            Assets.placeholderImage(
              dark: UiUtils.isDarkContext(context),
            ),
            width: remToPx(7),
          );

    final Widget left = ClipRRect(
      borderRadius: BorderRadius.circular(remToPx(0.5)),
      child: SizedBox(
        width: width > ResponsiveSizes.md ? (15 / 100) * width : remToPx(8),
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

  List<Widget> getChapterCard(final ChapterInfo chapter) {
    final List<String> first = <String>[];
    final List<String> second = <String>[];

    if (chapter.title != null) {
      if (chapter.volume != null) {
        first.add('${Translator.t.volume()} ${chapter.volume}');
      }

      first.add('${Translator.t.chapter()} ${chapter.chapter}');
      second.add(chapter.title!);
    } else {
      if (first.isEmpty) {
        first.add('${Translator.t.volume()} ${chapter.volume ?? '?'}');
      }

      second.add('${Translator.t.chapter()} ${chapter.chapter}');
    }

    return <Widget>[
      Text(
        first.join(' & '),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        second.join(' '),
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.headline6?.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  void _previousChapter() {
    if (currentChapterIndex != null && currentChapterIndex! - 1 >= 0) {
      setChapter(
        currentChapterIndex! - 1,
      );
    } else {
      goToPage(Pages.home);
      setChapter(null);
    }
  }

  void _nextChapter() {
    if (currentChapterIndex != null &&
        currentChapterIndex! + 1 < info!.chapters.length) {
      setChapter(
        currentChapterIndex! + 1,
      );
    } else {
      goToPage(Pages.home);
      setChapter(null);
    }
  }

  void _onPop() {
    goToPage(Pages.home);
    setChapter(null);
  }

  Widget getChapters(
    final int start,
    final int end,
    final EdgeInsets padding,
  ) =>
      MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView(
          padding: padding,
          children: info!.sortedChapters
              .sublist(start, end)
              .asMap()
              .map(
                (
                  final int k,
                  final ChapterInfo x,
                ) =>
                    MapEntry<int, Widget>(
                  k,
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: remToPx(0.4),
                          vertical: remToPx(0.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: getChapterCard(x),
                        ),
                      ),
                      onTap: () {
                        setChapter(start + k);
                        goToPage(Pages.reader);
                      },
                    ),
                  ),
                ),
              )
              .values
              .toList(),
        ),
      );

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
                                    getHero(context),
                                    SizedBox(
                                      height: remToPx(1.5),
                                    ),
                                    TrackersTile(
                                      title: info!.title,
                                      plugin: extractor.id,
                                      providers: Trackers.manga,
                                    ),
                                    SizedBox(
                                      height: remToPx(1.5),
                                    ),
                                    Text(
                                      Translator.t.chapters(),
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
                                    info!.sortedChapters.length;
                                final int end = start + maxChunkLength;
                                final int extra =
                                    end > totalLength ? end - totalLength : 0;

                                return Builder(
                                  builder: (final BuildContext context) =>
                                      getChapters(
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
                  if (chapter != null)
                    pages[chapter] != null
                        ? pages[chapter]!.isNotEmpty
                            ? mangaMode == MangaMode.page
                                ? PageReader(
                                    key: ValueKey<String>(
                                      'Pager-${chapter!.volume ?? '?'}-${chapter!.chapter}',
                                    ),
                                    extractor: extractor,
                                    info: info!,
                                    chapter: chapter!,
                                    pages: pages[chapter]!,
                                    previousChapter: _previousChapter,
                                    nextChapter: _nextChapter,
                                    onPop: _onPop,
                                  )
                                : ListReader(
                                    key: ValueKey<String>(
                                      'Listu-${chapter!.volume ?? '?'}-${chapter!.chapter}',
                                    ),
                                    extractor: extractor,
                                    info: info!,
                                    chapter: chapter!,
                                    pages: pages[chapter]!,
                                    previousChapter: _previousChapter,
                                    nextChapter: _nextChapter,
                                    onPop: _onPop,
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
              )
            : Scaffold(
                appBar: appBar,
                body: loader,
              ),
      ),
      onWillPop: () async {
        if (info != null && controller.page?.toInt() != Pages.home.index) {
          goToPage(Pages.home);
          setChapter(null);

          return false;
        }

        Navigator.of(context).pop();
        return true;
      },
    );
  }

  int get tabCount => (info!.sortedChapters.length / maxChunkLength).ceil();
}
