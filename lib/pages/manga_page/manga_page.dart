import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './list_reader.dart';
import './page_reader.dart';
import '../../components/full_screen.dart';
import '../../components/toggleable_slide_widget.dart';
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/manga/model.dart' as manga_model;
import '../../core/models/languages.dart';
import '../../core/models/manga_page.dart' as manga_page;
import '../../plugins/config.dart' as config;
import '../../plugins/database/database.dart' show DataBox;
import '../../plugins/database/schemas/cached_result/cached_result.dart'
    as cached_result;
import '../../plugins/database/schemas/settings/settings.dart'
    show MangaMode, SettingsSchema;
import '../../plugins/helpers/assets.dart';
import '../../plugins/helpers/ui.dart';
import '../../plugins/router.dart';
import '../../plugins/state.dart' show AppState;
import '../../plugins/translator/translator.dart';

enum Pages {
  home,
  reader,
}

class Page extends StatefulWidget {
  const Page({
    final Key? key,
  }) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> with SingleTickerProviderStateMixin {
  manga_model.MangaInfo? info;

  manga_model.ChapterInfo? chapter;
  int? currentChapterIndex;
  Map<manga_model.ChapterInfo, List<manga_model.PageInfo>> pages =
      <manga_model.ChapterInfo, List<manga_model.PageInfo>>{};

  late PageController controller;

  ScrollDirection? lastScrollDirection;
  final ValueNotifier<bool> showFloatingButton = ValueNotifier<bool>(true);
  late AnimationController floatingButtonController;

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

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

    Future<void>.delayed(Duration.zero, () async {
      args = manga_page.PageArguments.fromJson(
        RouteManager.parseRoute(ModalRoute.of(context)!.settings.name!).params,
      );

      getInfo();
    });

    AppState.settings.subscribe(_appStateChange);
  }

  @override
  void dispose() {
    showFloatingButton.dispose();

    controller.dispose();
    AppState.settings.unsubscribe(_appStateChange);

    super.dispose();
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
    final String cacheKey = '${args.plugin}-${args.src}';

    if (removeCache) {
      await DataBox.mangaInfo.delete(cacheKey);
    }

    final cached_result.CachedResultSchema? cachedAnime =
        removeCache ? null : DataBox.mangaInfo.get(cacheKey);

    if (cachedAnime != null &&
        nowMs - cachedAnime.cachedTime <
            config.cachedMangaInfoExpireTime.inMilliseconds) {
      try {
        info = manga_model.MangaInfo.fromJson(cachedAnime.info);
        setState(() {});
        return;
      } catch (_) {
        rethrow;
      }
    }

    info = await extractor.Extractors.manga[args.plugin]!.getInfo(
      args.src,
      locale: locale ?? extractor.Extractors.manga[args.plugin]!.defaultLocale,
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

  void setChapter(
    final int? index,
  ) {
    setState(() {
      currentChapterIndex = index;
      chapter = index != null ? info!.chapters[index] : null;
    });

    if (chapter != null && pages[chapter] == null) {
      extractor.Extractors.manga[args.plugin]!
          .getChapter(chapter!)
          .then((final List<manga_model.PageInfo> x) {
        setState(() {
          pages[chapter!] = x;
        });
      });
    }
  }

  Widget getHero() => LayoutBuilder(
        builder:
            (final BuildContext context, final BoxConstraints constraints) {
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
        },
      );

  List<Widget> getChapterCard(final manga_model.ChapterInfo chapter) {
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
      setChapter(null);
      goToPage(Pages.home);
    }
  }

  void _nextChapter() {
    if (currentChapterIndex != null &&
        currentChapterIndex! + 1 < info!.chapters.length) {
      setChapter(
        currentChapterIndex! + 1,
      );
    } else {
      setChapter(null);
      goToPage(Pages.home);
    }
  }

  void _onPop() {
    setChapter(null);
    goToPage(Pages.home);
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
                              getHero(),
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
                              ...info!.chapters
                                  .asMap()
                                  .map(
                                    (
                                      final int k,
                                      final manga_model.ChapterInfo x,
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
                  if (chapter != null)
                    pages[chapter] != null
                        ? pages[chapter]!.isNotEmpty
                            ? FullScreenWidget(
                                child: mangaMode == MangaMode.page
                                    ? PageReader(
                                        key: ValueKey<String>(
                                          'Pager-${chapter!.volume ?? '?'}-${chapter!.chapter}',
                                        ),
                                        plugin: extractor
                                            .Extractors.manga[args.plugin]!,
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
                                        plugin: extractor
                                            .Extractors.manga[args.plugin]!,
                                        info: info!,
                                        chapter: chapter!,
                                        pages: pages[chapter]!,
                                        previousChapter: _previousChapter,
                                        nextChapter: _nextChapter,
                                        onPop: _onPop,
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
              )
            : loader,
      ),
      onWillPop: () async {
        if (controller.page!.toInt() != Pages.home.index) {
          setState(() {
            setChapter(null);
          });

          goToPage(Pages.home);
          return false;
        }

        Navigator.of(context).pop();
        return true;
      },
    );
  }
}
