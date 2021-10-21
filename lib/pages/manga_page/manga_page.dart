import 'package:extensions/extensions.dart' as extensions;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utilx/utilities/languages.dart';
import './list_reader.dart';
import './page_reader.dart';
import '../../../config.dart';
import '../../components/toggleable_slide_widget.dart';
import '../../components/trackers/trackers_tile.dart';
import '../../core/extensions.dart';
import '../../core/models/page_args/manga_page.dart' as manga_page;
import '../../core/trackers/providers.dart';
import '../../plugins/database/database.dart' show DataBox;
import '../../plugins/database/schemas/cache/cache.dart' as cache_schema;
import '../../plugins/database/schemas/settings/settings.dart'
    show MangaMode, SettingsSchema;
import '../../plugins/helpers/assets.dart';
import '../../plugins/helpers/stateful_holder.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/helpers/utils/list.dart';
import '../../plugins/router.dart';
import '../../plugins/state.dart' show AppState;
import '../../plugins/translator/translator.dart';

extension on extensions.MangaInfo {
  List<extensions.ChapterInfo> get sortedChapters => ListUtils.tryArrange(
        chapters,
        (final extensions.ChapterInfo x) => x.chapter,
      );
}

enum Pages {
  home,
  reader,
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
  extensions.MangaInfo? info;

  extensions.ChapterInfo? chapter;
  int? currentChapterIndex;
  Map<extensions.ChapterInfo, List<extensions.PageInfo>> pages =
      <extensions.ChapterInfo, List<extensions.PageInfo>>{};

  late PageController controller;

  ScrollDirection? lastScrollDirection;
  final ValueNotifier<bool> showFloatingButton = ValueNotifier<bool>(true);
  late AnimationController floatingButtonController;

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  late extensions.MangaExtractor extractor;
  late manga_page.PageArguments args;

  LanguageCodes? locale;
  MangaMode mangaMode = AppState.settings.current.mangaReaderMode;

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

    AppState.settings.subscribe(_appStateChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doLoadStateIfHasnt();
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
      args = manga_page.PageArguments.fromJson(
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
    setState(() {
      mangaMode = AppState.settings.current.mangaReaderMode;
    });
  }

  Future<void> goToPage(final Pages page) async {
    await controller.animateToPage(
      page.index,
      duration: animationDuration,
      curve: Curves.easeInOut,
    );
  }

  Future<void> getInfo({
    final bool removeCache = false,
  }) async {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final String cacheKey = 'manga-${extractor.id}-${args.src}';

    if (removeCache) {
      await DataBox.cache.delete(cacheKey);
    }

    final cache_schema.CacheSchema? cachedManga =
        removeCache ? null : DataBox.cache.get(cacheKey);

    if (cachedManga != null &&
        nowMs - cachedManga.cachedTime <
            MiscSettings.cachedMangaInfoExpireTime.inMilliseconds) {
      try {
        if (mounted) {
          setState(() {
            info = extensions.MangaInfo.fromJson(
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
      cache_schema.CacheSchema(
        info!.toJson(),
        nowMs,
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void setChapter(
    final int? index,
  ) {
    setState(() {
      currentChapterIndex = index;
      chapter = index != null ? info!.sortedChapters[index] : null;
    });

    if (chapter != null && pages[chapter] == null) {
      extractor.getChapter(chapter!).then((final List<extensions.PageInfo> x) {
        setState(() {
          pages[chapter!] = x;
        });
      });
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
              dark: isDarkContext(context),
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

  List<Widget> getChapterCard(final extensions.ChapterInfo chapter) {
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
                        child: Container(
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
                              getHero(context),
                              SizedBox(
                                height: remToPx(1.5),
                              ),
                              TrackersTile(
                                title: info!.title,
                                plugin: extractor.id,
                                providers: mangaProviders,
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
                              ...info!.sortedChapters
                                  .asMap()
                                  .map(
                                    (
                                      final int k,
                                      final extensions.ChapterInfo x,
                                    ) =>
                                        MapEntry<int, Widget>(
                                      k,
                                      Card(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: remToPx(0.4),
                                              vertical: remToPx(0.2),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: getChapterCard(x),
                                            ),
                                          ),
                                          onTap: () {
                                            setChapter(k);
                                            goToPage(Pages.reader);
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                  .values
                                  .toList(),
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
}
