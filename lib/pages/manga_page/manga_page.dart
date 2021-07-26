import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/extractors.dart' as extractor;
import '../../core/extractor/manga/model.dart' as manga_model;
import '../../core/models/manga_page.dart' as manga_page;
import '../../plugins/router.dart';
import '../../plugins/translator/translator.dart';
import '../../components/full_screen.dart';
import '../../components/toggleable_appbar.dart';

enum Pages { home, reader }

class Page extends StatefulWidget {
  const Page({final Key? key}) : super(key: key);

  @override
  State<Page> createState() => PageState();
}

class PageState extends State<Page> with SingleTickerProviderStateMixin {
  manga_model.MangaInfo? info;

  manga_model.ChapterInfo? chapter;
  int? currentChapterIndex;
  Map<manga_model.ChapterInfo, List<manga_model.PageInfo>> pages = {};

  late PageController controller;

  late PageController pagerController;
  int currentPageIndex = 0;

  late AnimationController pagerAppBarController;
  bool showPagerAppBar = true;

  Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  late manga_page.PageArguments args;

  @override
  void initState() {
    super.initState();

    controller = PageController(
      initialPage: Pages.home.index,
    );

    pagerController = PageController(
      initialPage: currentPageIndex,
      keepPage: true,
    );

    pagerAppBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    Future.delayed(Duration.zero, () async {
      args = manga_page.PageArguments.fromJson(
        RouteManager.parseRoute(ModalRoute.of(context)!.settings.name!).params,
      );

      getInfo();
    });
  }

  void goToPage(final Pages page) {
    controller.animateToPage(
      page.index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void getInfo() async => extractor.Extractors.manga[args.plugin]!
      .getInfo(
        args.src,
        locale: Translator.t.code,
      )
      .then((x) => setState(() {
            info = x;
          }));

  void setChapter(
    int? index,
  ) {
    setState(() {
      currentChapterIndex = index;
      chapter = index != null ? info!.chapters[index] : null;
    });

    if (chapter != null && pages[chapter] == null) {
      extractor.Extractors.manga[args.plugin]!.getChapter(chapter!).then((x) {
        setState(() {
          pages[chapter!] = x;
        });
      });
    }
  }

  Widget heroBuilder(
    final manga_page.PageArguments args,
    final manga_model.MangaInfo info,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      final image = info.thumbnail != null
          ? Image.network(
              info.thumbnail!,
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
        child: image,
      );

      final right = Column(
        children: [
          Text(
            info.title,
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
    });
  }

  void setPage(int page) => setState(() => currentPageIndex = page);

  void toggleAppBar() => setState(() => showPagerAppBar = !showPagerAppBar);

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
              ? PageView(
                  controller: controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Scaffold(
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: appBar.preferredSize.height,
                              ),
                              heroBuilder(args, info!),
                              SizedBox(
                                height: utils.remToPx(1.5),
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
                                    (k, x) => MapEntry(
                                      k,
                                      Card(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: utils.remToPx(0.4),
                                              vertical: utils.remToPx(0.2),
                                            ),
                                            child: x.title != null
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${x.volume != null ? '${Translator.t.volume()} ${x.volume} & ' : ''}${Translator.t.chapter()} ${x.chapter}',
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        x.title!,
                                                        style: TextStyle(
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline6
                                                                  ?.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    '${x.volume != null ? '${Translator.t.volume()} ${x.volume} & ' : ''}${Translator.t.chapter()} ${x.chapter}',
                                                    style: TextStyle(
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .headline6
                                                              ?.fontSize,
                                                    ),
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
                    ),
                    chapter != null
                        ? FullScreenWidget(
                            child: Scaffold(
                                extendBodyBehindAppBar: true,
                                appBar: ToggleableAppBar(
                                  child: AppBar(
                                    leading: IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () => goToPage(Pages.home),
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          info!.title,
                                        ),
                                        Text(
                                          '${chapter!.volume != null ? '${Translator.t.vol()} ${chapter!.volume} ' : ''}${Translator.t.ch()} ${chapter!.chapter} ${chapter!.title ?? ''}',
                                          style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                ?.fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor:
                                        Theme.of(context).cardColor,
                                  ),
                                  controller: pagerAppBarController,
                                  visible: showPagerAppBar,
                                ),
                                body: pages[chapter] != null
                                    ? pages[chapter]!.isEmpty
                                        ? Center(
                                            child: Text(
                                                Translator.t.noPagesFound()),
                                          )
                                        : GestureDetector(
                                            onTapUp: (details) async {
                                              final position =
                                                  details.localPosition.dx /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width;

                                              if (position <= 0.3) {
                                                if (currentPageIndex > 0) {
                                                  await pagerController
                                                      .previousPage(
                                                    duration: const Duration(
                                                      microseconds: 200,
                                                    ),
                                                    curve: Curves.easeInOut,
                                                  );
                                                  setPage(currentPageIndex - 1);
                                                } else {
                                                  setChapter(
                                                      currentChapterIndex! -
                                                                  1 >=
                                                              0
                                                          ? currentChapterIndex! -
                                                              1
                                                          : null);
                                                  setPage(0);
                                                }
                                              } else if (position >= 0.7) {
                                                if (currentPageIndex + 1 <
                                                    pages[chapter]!.length) {
                                                  pagerController.nextPage(
                                                    duration: const Duration(
                                                        microseconds: 200),
                                                    curve: Curves.easeInOut,
                                                  );
                                                  setPage(currentPageIndex + 1);
                                                } else {
                                                  setChapter(
                                                      currentChapterIndex! + 1 <
                                                              info!.chapters
                                                                  .length
                                                          ? currentChapterIndex! +
                                                              1
                                                          : null);
                                                  setPage(0);
                                                }
                                              } else {
                                                toggleAppBar();
                                              }

                                              if (chapter == null) {
                                                goToPage(Pages.home);
                                              }
                                            },
                                            child: PageView(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              controller: pagerController,
                                              children: pages[chapter]!
                                                  .asMap()
                                                  .map(
                                                    (k, x) => MapEntry(
                                                      k,
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                Image.network(
                                                              x.url,
                                                              headers:
                                                                  x.headers,
                                                              loadingBuilder:
                                                                  (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null) {
                                                                  return InteractiveViewer(
                                                                    child:
                                                                        child,
                                                                  );
                                                                }

                                                                return Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    value: loadingProgress.expectedTotalBytes !=
                                                                            null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                            loadingProgress.expectedTotalBytes!
                                                                        : null,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: utils
                                                                .remToPx(0.5),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              '${k + 1}/${pages[chapter]!.length}',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: utils
                                                                .remToPx(0.3),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                  .values
                                                  .toList(),
                                            ),
                                          )
                                    : loader),
                          )
                        : const SizedBox.shrink(),
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
        });
  }
}
