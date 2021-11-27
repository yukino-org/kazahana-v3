import 'dart:async';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils/function.dart';
import '../../../../../../../config/defaults.dart';
import '../../../../../../../modules/app/state.dart';
import '../../../../../../../modules/database/database.dart';
import '../../../../../../../modules/helpers/ui.dart';
import '../../../../../../../modules/state/stateful_holder.dart';
import '../../../../../../../modules/state/states.dart';
import '../../../../../../../modules/translator/translator.dart';
import '../../../../../../components/error_widget.dart';
import '../../../../../../components/preferred_size_wrapper.dart';
import '../../../../../../components/reactive_state_builder.dart';
import '../../../../../settings_page/setting_labels/manga.dart';
import '../../controller.dart';

class PageReader extends StatefulWidget {
  const PageReader({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final ReaderPageController controller;

  @override
  _PageReaderState createState() => _PageReaderState();
}

class _PageReaderState extends State<PageReader> {
  Timer? footerNotificationTimer;
  TapDownDetails? lastTapDetails;

  final ValueNotifier<Widget?> footerNotificationContent =
      ValueNotifier<Widget?>(null);
  final FocusNode focusNode = FocusNode();
  final TransformationController interactiveController =
      TransformationController();
  late final PageController pageController = PageController(
    initialPage: widget.controller.currentPageIndex,
  );

  @override
  void dispose() {
    footerNotificationTimer?.cancel();
    footerNotificationContent.dispose();
    interactiveController.dispose();
    pageController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  Future<void> showOptions() async {
    await showModalBottomSheet(
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
                  children: getSettingsManga(
                    context,
                    AppState.settings.value,
                    () async {
                      await SettingsBox.save(AppState.settings.value);

                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    widget.controller.mangaController.reassemble();
  }

  void showFooterNotification(final Widget? child) {
    footerNotificationContent.value = child != null
        ? DefaultTextStyle(
            key: UniqueKey(),
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: Colors.white),
            child: child,
          )
        : null;
    footerNotificationTimer?.cancel();

    if (footerNotificationContent.value != null) {
      footerNotificationTimer = Timer(Defaults.notifyInfoDuration, () {
        showFooterNotification(null);
      });
    }
  }

  Future<void> previousPage() async {
    if (widget.controller.previousPageAvailable) {
      await setCurrentPageIndex(widget.controller.currentPageIndex - 1);
    } else {
      showFooterNotification(
        Text(Translator.t.tapAgainToSwitchPreviousChapter()),
      );
    }
  }

  Future<void> nextPage() async {
    if (widget.controller.nextPageAvailable) {
      await setCurrentPageIndex(widget.controller.currentPageIndex + 1);
    } else {
      showFooterNotification(
        Text(Translator.t.tapAgainToSwitchPreviousChapter()),
      );
    }
  }

  Future<void> previousChapter() async {
    if (widget.controller.previousChapterAvailable) {
      await widget.controller.previousChapter();
    } else {
      showFooterNotification(
        Text(Translator.t.noMoreChaptersLeft()),
      );
    }
  }

  Future<void> nextChapter() async {
    if (widget.controller.nextChapterAvailable) {
      await widget.controller.nextChapter();
    } else {
      showFooterNotification(
        Text(Translator.t.noMoreChaptersLeft()),
      );
    }
  }

  /// [kind] 1 - Tap, 2 - Double tap
  Future<void> leftTap(final int kind) async {
    switch (kind) {
      case 1:
        if (!AppState.settings.value.doubleClickSwitchChapter &&
            !(isReversed
                ? widget.controller.nextPageAvailable
                : widget.controller.previousPageAvailable)) {
          await (isReversed ? nextChapter() : previousPage());
        } else {
          await (isReversed ? nextPage() : previousPage());
        }
        break;

      case 2:
        if (AppState.settings.value.doubleClickSwitchChapter) {
          await (isReversed ? nextChapter() : previousChapter());
        }
        break;
    }
  }

  /// [kind] 1 - Tap, 2 - Double tap
  Future<void> middleTap(final int kind) async {
    switch (kind) {
      case 1:
        widget.controller
          ..showControls = !widget.controller.showControls
          ..reassemble();
        break;

      case 2:
        if (!interactiveController.value.isIdentity()) {
          interactiveController.value = interactiveController.value.clone()
            ..setIdentity();
        } else {
          final Offset position = lastTapDetails!.localPosition;
          interactiveController.value = interactiveController.value.clone()
            ..translate(-position.dx, -position.dy)
            ..scale(2.5);
        }
        break;
    }
  }

  /// [kind] 1 - Tap, 2 - Double tap
  Future<void> rightTap(final int kind) async {
    switch (kind) {
      case 1:
        if (!AppState.settings.value.doubleClickSwitchChapter &&
            !(isReversed
                ? widget.controller.previousPageAvailable
                : widget.controller.nextPageAvailable)) {
          await (isReversed ? previousChapter() : nextPage());
        } else {
          await (isReversed ? previousPage() : nextPage());
        }
        break;

      case 2:
        if (AppState.settings.value.doubleClickSwitchChapter) {
          await (isReversed ? previousChapter() : nextChapter());
        }
        break;
    }
  }

  /// [kind] 1 - Tap, 2 - Double tap
  Future<void> handleTaps(final int kind) async {
    if (lastTapDetails == null) return;

    final double position =
        lastTapDetails!.localPosition.dx / MediaQuery.of(context).size.width;

    if (!interactionOnProgress && position <= 0.3) {
      await leftTap(kind);
    } else if (!interactionOnProgress && position >= 0.7) {
      await rightTap(kind);
    } else {
      await middleTap(kind);
    }
  }

  Future<void> animateToPage(final int page) async {
    if (pageController.hasClients) {
      await pageController.animateToPage(
        page,
        duration: Defaults.animationsNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> setCurrentPageIndex(final int page) async {
    await animateToPage(page);
    widget.controller.setCurrentPageIndex(page);
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: PreferredSizeWrapper(
          builder: (
            final BuildContext context,
            final PreferredSizeWidget child,
          ) =>
              AnimatedSlide(
            duration: Defaults.animationsNormal,
            offset: widget.controller.showControls
                ? Offset.zero
                : const Offset(0, -1),
            curve: Curves.easeInOut,
            child: child,
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor:
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: Translator.t.back(),
              onPressed: widget.controller.mangaController.goHome,
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () async {
                  await widget.controller.setFullscreen(
                    enabled: !AppState.settings.value.mangaAutoFullscreen,
                  );
                },
                icon: Icon(
                  AppState.settings.value.mangaAutoFullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                ),
              ),
              IconButton(
                onPressed: showOptions,
                icon: const Icon(Icons.more_vert),
              ),
            ],
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.controller.mangaController.info.value!.title),
                FunctionUtils.withValue(
                  widget.controller.mangaController.currentChapter!,
                  (final ChapterInfo currentChapter) => Text(
                    '${currentChapter.volume != null ? '${Translator.t.vol()} ${currentChapter.volume} ' : ''}${Translator.t.ch()} ${currentChapter.chapter} ${currentChapter.title != null ? '- ${currentChapter.title}' : ''}',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.subtitle2?.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Builder(
          builder: (final BuildContext context) {
            if (widget.controller.pages.value!.isEmpty) {
              return Center(
                child: KawaiiErrorWidget(
                  message: Translator.t.noPagesFound(),
                ),
              );
            }

            return RawKeyboardListener(
              autofocus: true,
              focusNode: focusNode,
              onKey: (final RawKeyEvent event) =>
                  widget.controller.getKeyboard(context).onRawKeyEvent(event),
              child: PageView.builder(
                allowImplicitScrolling: true,
                scrollDirection:
                    AppState.settings.value.mangaReaderSwipeDirection ==
                            MangaSwipeDirections.horizontal
                        ? Axis.horizontal
                        : Axis.vertical,
                onPageChanged: (final int page) {
                  widget.controller.setCurrentPageIndex(page);
                  interactiveController.value = Matrix4.identity();
                  widget.controller.reassemble();
                },
                physics: interactionOnProgress
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                controller: pageController,
                itemCount: widget.controller.pages.value!.length,
                itemBuilder: (final BuildContext context, final int _index) {
                  final StatefulValueHolderWithError<ImageDescriber?>? image =
                      widget.controller.currentPageImage;

                  return ReactiveStateBuilder(
                    state: image?.state ?? ReactiveStates.waiting,
                    onResolving: (final BuildContext context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    onResolved: (final BuildContext context) => GestureDetector(
                      onTapDown: (final TapDownDetails details) {
                        lastTapDetails = details;
                      },
                      onDoubleTapDown: (final TapDownDetails details) {
                        lastTapDetails = details;
                      },
                      onTap: () async {
                        await handleTaps(1);
                      },
                      onDoubleTap: () async {
                        await handleTaps(2);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: SizedBox.expand(
                              child: Image.network(
                                image!.value!.url,
                                headers: image.value!.headers,
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
                                    );
                                  }

                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
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
                          ),
                          SizedBox(height: remToPx(0.5)),
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
                              '${widget.controller.currentPageIndex + 1}/${widget.controller.pages.value!.length}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: remToPx(0.3),
                          ),
                        ],
                      ),
                    ),
                    onFailed: (final BuildContext context) =>
                        KawaiiErrorWidget.fromErrorInfo(
                      message: Translator.t.noResultsFound(),
                      error: image?.error,
                    ),
                  );
                },
              ),
            );
          },
        ),
        bottomNavigationBar: AnimatedSlide(
          duration: Defaults.animationsNormal,
          offset:
              widget.controller.showControls ? Offset.zero : const Offset(0, 1),
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
                        onTap: widget.controller.previousChapterAvailable
                            ? () {
                                widget.controller.ignoreScreenChanges = true;
                                widget.controller.previousChapter();
                              }
                            : null,
                        child: Icon(
                          Icons.first_page,
                          color: widget.controller.previousChapterAvailable
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
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
                              overlayShape: RoundSliderOverlayShape(
                                overlayRadius: remToPx(0.9),
                              ),
                              trackHeight: remToPx(0.15),
                              showValueIndicator: ShowValueIndicator.always,
                            ),
                            child: RotatedBox(
                              quarterTurns: isReversed ? 2 : 0,
                              child: Slider(
                                value: widget.controller.currentPageIndex + 1,
                                min: 1,
                                max: widget.controller.pages.value!.length
                                    .toDouble(),
                                label: (widget.controller.currentPageIndex + 1)
                                    .toString(),
                                onChanged: (final double value) async {
                                  await animateToPage(value.toInt() - 1);
                                },
                                onChangeEnd: (final double value) async {
                                  await setCurrentPageIndex(value.toInt() - 1);
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
                        onTap: widget.controller.nextChapterAvailable
                            ? () {
                                widget.controller.ignoreScreenChanges = true;
                                widget.controller.nextChapter();
                              }
                            : null,
                        child: Icon(
                          Icons.last_page,
                          color: widget.controller.nextChapterAvailable
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
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

  bool get interactionOnProgress => !interactiveController.value.isIdentity();

  bool get isHorizontal =>
      AppState.settings.value.mangaReaderSwipeDirection ==
      MangaSwipeDirections.horizontal;

  bool get isReversed =>
      AppState.settings.value.mangaReaderDirection ==
      MangaDirections.rightToLeft;

  int get calculatedPageIndex => isReversed
      ? widget.controller.pages.value!.length -
          widget.controller.currentPageIndex -
          1
      : widget.controller.currentPageIndex;
}
