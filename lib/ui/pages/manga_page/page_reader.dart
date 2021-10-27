import 'dart:async';
import 'package:extensions/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './update_tracker.dart';
import '../../../config/defaults.dart';
import '../../../modules/app/state.dart';
import '../../../modules/database/schemas/settings/settings.dart';
import '../../../modules/helpers/screen.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/state/holder.dart';
import '../../../modules/state/loader.dart';
import '../../../modules/state/states.dart';
import '../../../modules/translator/translator.dart';
import '../../components/toggleable_appbar.dart';
import '../../components/toggleable_slide_widget.dart';
import '../settings_page/setting_labels/manga.dart';

enum TapSpace {
  left,
  middle,
  right,
}

TapSpace _spaceFromPosition(final double position) {
  if (position <= 0.3) return TapSpace.left;
  if (position >= 0.7) return TapSpace.right;
  return TapSpace.middle;
}

class LastTapDetail {
  LastTapDetail(this.space, this.time);

  final TapSpace space;
  final DateTime time;
}

class PageReader extends StatefulWidget {
  const PageReader({
    required final this.extractor,
    required final this.info,
    required final this.chapter,
    required final this.pages,
    required final this.onPop,
    required final this.previousChapter,
    required final this.nextChapter,
    final Key? key,
  }) : super(key: key);

  final MangaExtractor extractor;
  final MangaInfo info;
  final ChapterInfo chapter;
  final List<PageInfo> pages;

  final void Function() onPop;
  final void Function() previousChapter;
  final void Function() nextChapter;

  @override
  _PageReaderState createState() => _PageReaderState();
}

class _PageReaderState extends State<PageReader>
    with SingleTickerProviderStateMixin, FullscreenMixin, InitialStateLoader {
  late AnimationController overlayController;
  bool showOverlay = true;

  final ValueNotifier<Widget?> footerNotificationContent =
      ValueNotifier<Widget?>(null);
  Timer? footerNotificationTimer;
  final Duration footerNotificationDuration = const Duration(seconds: 3);

  late TransformationController interactiveController;
  bool interactionOnProgress = false;
  LastTapDetail? lastTapDetail;
  TapDownDetails? doubleTapDetails;
  int lastKbEvent = DateTime.now().millisecondsSinceEpoch;

  late PageController pageController;
  late int currentPage;
  late int currentIndex;

  bool isHorizontal = AppState.settings.value.mangaReaderSwipeDirection ==
      MangaSwipeDirections.horizontal;
  bool isReversed = AppState.settings.value.mangaReaderDirection ==
      MangaDirections.rightToLeft;

  late final Map<PageInfo, StatefulValueHolder<ImageDescriber?>> images =
      <PageInfo, StatefulValueHolder<ImageDescriber?>>{};

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  final FocusNode focusNode = FocusNode();

  bool hasSynced = false;
  bool ignoreScreenChanges = false;

  @override
  void initState() {
    super.initState();

    initFullscreen();

    overlayController = AnimationController(
      vsync: this,
      duration: Defaults.animationsNormal,
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    maybeLoad();
  }

  @override
  void dispose() {
    if (!ignoreScreenChanges) {
      exitFullscreen();
    }

    footerNotificationTimer?.cancel();
    footerNotificationContent.dispose();

    overlayController.dispose();
    interactiveController.dispose();
    pageController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  @override
  Future<void> load() async {
    if (mounted && AppState.settings.value.mangaAutoFullscreen) {
      enterFullscreen();
    }
  }

  void handleKeyEvent(final RawKeyEvent event) {
    final int currentKbEvent = DateTime.now().millisecondsSinceEpoch;
    final bool allowKbEvent =
        (currentKbEvent - lastKbEvent) > kDoubleTapTimeout.inMilliseconds;

    if (allowKbEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        isReversed ? _prevPage(true) : _nextPage(true);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        isReversed ? _nextPage(true) : _prevPage(true);
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        exitFullscreen();
        setState(() {
          showOverlay = true;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.f11) {
        enterFullscreen();
        setState(() {
          showOverlay = false;
        });
      }
    }

    lastKbEvent = currentKbEvent;
  }

  // ignore: use_setters_to_change_properties
  void handleDoubleTapDown(final TapDownDetails details) {
    doubleTapDetails = details;
  }

  void handleDoubleTap() {
    if (interactiveController.value != Matrix4.identity()) {
      interactiveController.value = Matrix4.identity();
    } else {
      final Offset position = doubleTapDetails!.localPosition;

      interactiveController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
    setState(() {
      interactionOnProgress = !interactionOnProgress;
    });
  }

  Future<void> goToPage(final int page) async {
    if (pageController.hasClients) {
      await pageController.animateToPage(
        isReversed ? widget.pages.length - page - 1 : page,
        duration: Defaults.animationsSlower,
        curve: Curves.easeInOut,
      );

      if (page == widget.pages.length - 1) {
        hasSynced = true;

        await updateTrackers(
          widget.info.title,
          widget.extractor.id,
          widget.chapter.chapter,
          widget.chapter.volume,
        );
      }
    }
  }

  Future<void> getPage(final PageInfo page) async {
    images[page]!.state = ReactiveStates.resolving;

    final ImageDescriber image = await widget.extractor.getPage(page);

    if (mounted) {
      setState(() {
        images[page]!.value = image;
        images[page]!.state = ReactiveStates.resolved;
      });
    }
  }

  void showOptions() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(remToPx(0.5)),
          topRight: Radius.circular(remToPx(0.5)),
        ),
      ),
      context: context,
      builder: (final BuildContext context) => SafeArea(
        child: StatefulBuilder(
          builder: (
            final BuildContext context,
            final StateSetter setState,
          ) =>
              Padding(
            padding: EdgeInsets.symmetric(vertical: remToPx(0.25)),
            child: Wrap(
              children: <Widget>[
                Column(
                  children: getManga(AppState.settings.value, () async {
                    await AppState.settings.value.save();

                    if (AppState.settings.value.mangaReaderMode !=
                        MangaMode.page) {
                      AppState.settings.value = AppState.settings.value;
                    }

                    if (mounted) {
                      setState(() {
                        isReversed =
                            AppState.settings.value.mangaReaderDirection ==
                                MangaDirections.rightToLeft;
                        isHorizontal =
                            AppState.settings.value.mangaReaderSwipeDirection ==
                                MangaSwipeDirections.horizontal;
                      });
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _prevPage(final bool satisfied) {
    if (currentPage > 0) {
      goToPage(currentPage - 1);
      return true;
    } else {
      if (satisfied) {
        ignoreScreenChanges = true;
        widget.previousChapter();
        return true;
      }
    }
    return false;
  }

  bool _nextPage(final bool satisfied) {
    if (currentPage + 1 < widget.pages.length) {
      goToPage(currentPage + 1);
      return true;
    } else {
      if (satisfied) {
        ignoreScreenChanges = true;
        widget.nextChapter();
        return true;
      }
    }
    return false;
  }

  void showFooterNotification(final Widget? child) {
    footerNotificationContent.value = child;
    footerNotificationTimer?.cancel();

    if (footerNotificationContent.value != null) {
      footerNotificationTimer = Timer(footerNotificationDuration, () {
        showFooterNotification(null);
      });
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: ToggleableAppBar(
          controller: overlayController,
          visible: showOverlay,
          child: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: Translator.t.back(),
              onPressed: widget.onPop,
            ),
            actions: <Widget>[
              ValueListenableBuilder<bool>(
                valueListenable: isFullscreened,
                builder: (
                  final BuildContext builder,
                  final bool isFullscreened,
                  final Widget? child,
                ) =>
                    IconButton(
                  onPressed: () async {
                    focusNode.requestFocus();
                    AppState.settings.value.mangaAutoFullscreen =
                        !isFullscreened;

                    if (isFullscreened) {
                      exitFullscreen();
                      setState(() {
                        showOverlay = true;
                      });
                    } else {
                      enterFullscreen();
                      setState(() {
                        showOverlay = false;
                      });
                    }

                    await AppState.settings.value.save();
                  },
                  icon: Icon(
                    isFullscreened ? Icons.fullscreen_exit : Icons.fullscreen,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  showOptions();
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
          ),
        ),
        body: widget.pages.isEmpty
            ? Center(
                child: Text(
                  Translator.t.noPagesFound(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            : RawKeyboardListener(
                autofocus: true,
                focusNode: focusNode,
                onKey: handleKeyEvent,
                child: GestureDetector(
                  onDoubleTapDown: handleDoubleTapDown,
                  onDoubleTap: handleDoubleTap,
                  onTapUp: (final TapUpDetails details) {
                    focusNode.requestFocus();
                    final LastTapDetail currentTap = LastTapDetail(
                      _spaceFromPosition(
                        details.localPosition.dx /
                            MediaQuery.of(context).size.width,
                      ),
                      DateTime.now(),
                    );

                    final bool useDoubleClick =
                        AppState.settings.value.doubleClickSwitchChapter;
                    final bool satisfied = !useDoubleClick ||
                        lastTapDetail?.space == currentTap.space &&
                            (currentTap.time.millisecondsSinceEpoch -
                                    lastTapDetail!
                                        .time.millisecondsSinceEpoch) <=
                                kDoubleTapTimeout.inMilliseconds;

                    bool done = false;
                    if (currentTap.space == TapSpace.left) {
                      done = isReversed
                          ? _nextPage(satisfied)
                          : _prevPage(satisfied);
                    } else if (currentTap.space == TapSpace.right) {
                      done = isReversed
                          ? _prevPage(satisfied)
                          : _nextPage(satisfied);
                    } else {
                      setState(() {
                        showOverlay = !showOverlay;
                      });

                      done = true;
                    }

                    lastTapDetail = currentTap;

                    if (!done && currentTap.space != TapSpace.middle) {
                      final bool isPrev = isReversed
                          ? currentTap.space == TapSpace.right
                          : currentTap.space == TapSpace.left;
                      showFooterNotification(
                        Text(
                          isPrev
                              ? Translator.t.tapAgainToSwitchPreviousChapter()
                              : Translator.t.tapAgainToSwitchNextChapter(),
                          key: UniqueKey(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );

                      final bool useDoubleClick =
                          AppState.settings.value.doubleClickSwitchChapter;
                      final bool satisfied = !useDoubleClick ||
                          lastTapDetail?.space == currentTap.space &&
                              (currentTap.time.millisecondsSinceEpoch -
                                      lastTapDetail!
                                          .time.millisecondsSinceEpoch) <=
                                  kDoubleTapTimeout.inMilliseconds;

                      bool done = false;
                      if (currentTap.space == TapSpace.left) {
                        done = isReversed
                            ? _nextPage(satisfied)
                            : _prevPage(satisfied);
                      } else if (currentTap.space == TapSpace.right) {
                        done = isReversed
                            ? _prevPage(satisfied)
                            : _nextPage(satisfied);
                      } else {
                        setState(() {
                          showOverlay = !showOverlay;
                        });
                        done = true;
                      }

                      lastTapDetail = currentTap;

                      if (!done && currentTap.space != TapSpace.middle) {
                        final bool isPrev = isReversed
                            ? currentTap.space == TapSpace.right
                            : currentTap.space == TapSpace.left;
                        showFooterNotification(
                          Text(
                            isPrev
                                ? Translator.t.tapAgainToSwitchPreviousChapter()
                                : Translator.t.tapAgainToSwitchNextChapter(),
                            key: UniqueKey(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: PageView.builder(
                    allowImplicitScrolling: true,
                    scrollDirection:
                        AppState.settings.value.mangaReaderSwipeDirection ==
                                MangaSwipeDirections.horizontal
                            ? Axis.horizontal
                            : Axis.vertical,
                    onPageChanged: (final int page) {
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
                    itemCount: widget.pages.length,
                    itemBuilder:
                        (final BuildContext context, final int _index) {
                      final int index = isReversed
                          ? widget.pages.length - _index - 1
                          : _index;
                      final PageInfo page = widget.pages[index];

                      if (images[page] == null) {
                        images[page] =
                            StatefulValueHolder<ImageDescriber?>(null);
                      }

                      if (!images[page]!.hasValue) {
                        if (!images[page]!.isResolving) {
                          getPage(page);
                        }

                        return loader;
                      }

                      final ImageDescriber image = images[page]!.value!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: Image.network(
                              image.url,
                              headers: image.headers,
                              loadingBuilder: (
                                final BuildContext context,
                                final Widget child,
                                final ImageChunkEvent? loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return InteractiveViewer(
                                    transformationController:
                                        interactiveController,
                                    child: child,
                                    onInteractionEnd:
                                        (final ScaleEndDetails details) {
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
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: remToPx(0.5),
                          ),
                          ValueListenableBuilder<Widget?>(
                            valueListenable: footerNotificationContent,
                            builder: (
                              final BuildContext context,
                              final Widget? footerNotificationContent,
                              final Widget? child,
                            ) =>
                                Align(
                              child: AnimatedSwitcher(
                                duration: Defaults.animationsSlower,
                                child: footerNotificationContent ?? child!,
                              ),
                            ),
                            child: Text(
                              '${index + 1}/${widget.pages.length}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: remToPx(0.3),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
        bottomNavigationBar: ToggleableSlideWidget(
          offsetBegin: Offset.zero,
          offsetEnd: const Offset(0, 1),
          visible: showOverlay,
          controller: overlayController,
          curve: Curves.easeInOut,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: remToPx(0.5),
              vertical:
                  remToPx(1) + Theme.of(context).textTheme.subtitle2!.fontSize!,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(remToPx(0.25)),
                ),
                color: Theme.of(context).cardColor,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: remToPx(0.5),
                ),
                child: Row(
                  children: <Widget>[
                    Material(
                      type: MaterialType.transparency,
                      shape: const CircleBorder(),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          Theme.of(context).textTheme.headline4!.fontSize!,
                        ),
                        onTap: () {
                          ignoreScreenChanges = true;
                          widget.previousChapter();
                        },
                        child: Icon(
                          Icons.first_page,
                          size: Theme.of(context).textTheme.headline4?.fontSize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        children: <Widget>[
                          SliderTheme(
                            data: SliderThemeData(
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: remToPx(0.3),
                              ),
                              trackHeight: remToPx(0.15),
                              showValueIndicator: ShowValueIndicator.always,
                            ),
                            child: RotatedBox(
                              quarterTurns: isReversed ? 2 : 0,
                              child: Slider(
                                value: currentPage + 1,
                                min: 1,
                                max: widget.pages.length.toDouble(),
                                label: (currentPage + 1).toString(),
                                onChanged: (final double value) {
                                  setState(() {
                                    currentPage = value.toInt() - 1;
                                  });
                                },
                                onChangeEnd: (final double value) async {
                                  focusNode.requestFocus();
                                  goToPage(value.toInt() - 1);
                                },
                              ),
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
                        onTap: () {
                          ignoreScreenChanges = true;
                          widget.nextChapter();
                        },
                        child: Icon(
                          Icons.last_page,
                          size: Theme.of(context).textTheme.headline4?.fontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
