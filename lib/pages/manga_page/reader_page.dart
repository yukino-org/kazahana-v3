import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/manga/model.dart' as manga_model;
import '../../plugins/translator/translator.dart';
import '../../plugins/state.dart' show AppState;
import '../../plugins/database/schemas/settings/settings.dart'
    show MangaDirections, MangaSwipeDirections;
import '../../components/toggleable_appbar.dart';
import '../../components/toggleable_slide_widget.dart';
import '../settings_page/setting_radio.dart';

class MangaReader extends StatefulWidget {
  final manga_model.MangaInfo info;
  final manga_model.ChapterInfo chapter;
  final List<manga_model.PageInfo> pages;

  final void Function() onPop;
  final void Function() previousChapter;
  final void Function() nextChapter;

  const MangaReader({
    Key? key,
    required this.info,
    required this.chapter,
    required this.pages,
    required this.onPop,
    required this.previousChapter,
    required this.nextChapter,
  }) : super(key: key);

  @override
  MangaReaderState createState() => MangaReaderState();
}

class MangaReaderState extends State<MangaReader>
    with SingleTickerProviderStateMixin {
  final animationDuration = const Duration(milliseconds: 300);

  late AnimationController overlayController;
  bool showOverlay = true;

  late TransformationController interactiveController;
  bool interactionOnProgress = false;

  late PageController pageController;
  late int currentPage;
  late int currentIndex;

  bool isHorizontal = AppState.settings.current.mangaReaderSwipeDirection ==
      MangaSwipeDirections.horizontal;
  bool isReversed = AppState.settings.current.mangaReaderDirection ==
      MangaDirections.rightToLeft;

  @override
  void initState() {
    super.initState();

    overlayController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );

    interactiveController = TransformationController();

    currentPage = 0;
    currentIndex =
        isReversed ? widget.pages.length - currentPage - 1 : currentPage;
    pageController = PageController(
      initialPage: currentIndex,
    );
  }

  @override
  void dispose() {
    overlayController.dispose();
    interactiveController.dispose();
    pageController.dispose();

    super.dispose();
  }

  Future<void> goToPage(int page) async {
    await pageController.animateToPage(
      isReversed ? widget.pages.length - page - 1 : page,
      duration: animationDuration,
      curve: Curves.easeInOut,
    );
  }

  void showOptions() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(utils.remToPx(0.5)),
          topRight: Radius.circular(utils.remToPx(0.5)),
        ),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: utils.remToPx(0.25)),
              child: Wrap(
                children: [
                  Column(
                    children: [
                      SettingRadio(
                        title: Translator.t.mangaReaderDirection(),
                        icon: Icons.auto_stories,
                        value: AppState.settings.current.mangaReaderDirection,
                        labels: {
                          MangaDirections.leftToRight:
                              Translator.t.leftToRight(),
                          MangaDirections.rightToLeft:
                              Translator.t.rightToLeft(),
                        },
                        onChanged: (val) async {
                          if (val is MangaDirections) {
                            AppState.settings.current.mangaReaderDirection =
                                val;
                            await AppState.settings.current.save();
                            setState(() {
                              isReversed = val == MangaDirections.rightToLeft;
                            });
                          }
                        },
                      ),
                      SettingRadio(
                        title: Translator.t.mangaReaderSwipeDirection(),
                        icon: Icons.swipe,
                        value:
                            AppState.settings.current.mangaReaderSwipeDirection,
                        labels: {
                          MangaSwipeDirections.horizontal:
                              Translator.t.horizontal(),
                          MangaSwipeDirections.vertical:
                              Translator.t.vertical(),
                        },
                        onChanged: (val) async {
                          if (val is MangaSwipeDirections) {
                            AppState.settings.current
                                .mangaReaderSwipeDirection = val;
                            await AppState.settings.current.save();
                            setState(() {
                              isHorizontal =
                                  val == MangaSwipeDirections.horizontal;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: ToggleableAppBar(
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onPop,
          ),
          actions: [
            IconButton(
              onPressed: () {
                showOptions();
              },
              icon: const Icon(Icons.opacity_outlined),
            ),
          ],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.info.title,
              ),
              Text(
                '${widget.chapter.volume != null ? '${Translator.t.vol()} ${widget.chapter.volume} ' : ''}${Translator.t.ch()} ${widget.chapter.chapter} ${widget.chapter.title != null ? '- ${widget.chapter.title}' : ''}',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.subtitle2?.fontSize,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).cardColor,
        ),
        controller: overlayController,
        visible: showOverlay,
      ),
      bottomNavigationBar: ToggleableSlideWidget(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: utils.remToPx(0.5),
            vertical: utils.remToPx(1) +
                Theme.of(context).textTheme.subtitle2!.fontSize!,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(utils.remToPx(0.25)),
              ),
              color: Theme.of(context).cardColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: utils.remToPx(0.5),
              ),
              child: Row(
                children: [
                  Material(
                    type: MaterialType.transparency,
                    shape: const CircleBorder(),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        Theme.of(context).textTheme.headline4!.fontSize!,
                      ),
                      child: Icon(
                        Icons.first_page,
                        size: Theme.of(context).textTheme.headline4?.fontSize,
                      ),
                      onTap: widget.previousChapter,
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: utils.remToPx(0.3),
                            ),
                            trackHeight: utils.remToPx(0.15),
                            showValueIndicator: ShowValueIndicator.always,
                          ),
                          child: Slider(
                            value: currentPage + 1,
                            min: 1,
                            max: widget.pages.length.toDouble(),
                            label: (currentPage + 1).toString(),
                            onChanged: (value) {
                              setState(() {
                                currentPage = value.toInt() - 1;
                              });
                            },
                            onChangeEnd: (value) async {
                              goToPage(value.toInt() - 1);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    type: MaterialType.transparency,
                    shape: const CircleBorder(),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        Theme.of(context).textTheme.headline4!.fontSize!,
                      ),
                      child: Icon(
                        Icons.last_page,
                        size: Theme.of(context).textTheme.headline4?.fontSize,
                      ),
                      onTap: widget.nextChapter,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        offsetBegin: Offset.zero,
        offsetEnd: const Offset(0, 1),
        visible: showOverlay,
        controller: overlayController,
      ),
      body: widget.pages.isEmpty
          ? Center(
              child: Text(Translator.t.noPagesFound()),
            )
          : GestureDetector(
              onTapUp: (details) async {
                final position = details.localPosition.dx /
                    MediaQuery.of(context).size.width;

                void _prevPage() {
                  if (currentPage > 0) {
                    goToPage(currentPage - 1);
                  } else {
                    widget.previousChapter();
                  }
                }

                void _nextPage() {
                  if (currentPage + 1 < widget.pages.length) {
                    goToPage(currentPage + 1);
                  } else {
                    widget.nextChapter();
                  }
                }

                if (position <= 0.3) {
                  isReversed ? _nextPage() : _prevPage();
                } else if (position >= 0.7) {
                  isReversed ? _prevPage() : _nextPage();
                } else {
                  setState(() {
                    showOverlay = !showOverlay;
                  });
                }
              },
              child: PageView(
                scrollDirection:
                    AppState.settings.current.mangaReaderSwipeDirection ==
                            MangaSwipeDirections.horizontal
                        ? Axis.horizontal
                        : Axis.vertical,
                onPageChanged: (page) {
                  setState(() {
                    currentPage =
                        isReversed ? widget.pages.length - page - 1 : page;
                    currentIndex = page;
                  });

                  interactiveController.value = Matrix4.identity();
                },
                physics: interactionOnProgress
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                controller: pageController,
                children:
                    (isReversed ? widget.pages.reversed.toList() : widget.pages)
                        .asMap()
                        .map(
                          (k, x) => MapEntry(
                            k,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    x.url,
                                    headers: x.headers,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return InteractiveViewer(
                                          transformationController:
                                              interactiveController,
                                          child: child,
                                          onInteractionEnd: (details) {
                                            setState(() {
                                              interactionOnProgress =
                                                  interactiveController.value
                                                          .getMaxScaleOnAxis() !=
                                                      1;
                                            });
                                          },
                                        );
                                      }

                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: utils.remToPx(0.5),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${isReversed ? widget.pages.length - k : k + 1}/${widget.pages.length}',
                                  ),
                                ),
                                SizedBox(
                                  height: utils.remToPx(0.3),
                                ),
                              ],
                            ),
                          ),
                        )
                        .values
                        .toList(),
              ),
            ),
    );
  }
}
