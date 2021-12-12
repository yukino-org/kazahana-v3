import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './widgets/controls.dart';
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
import '../../controller.dart';
import '../../widgets/appbar.dart';

class _ImageSize {
  _ImageSize({
    final this.width,
    final this.height,
  });

  final double? width;
  final double? height;
}

class ListReader extends StatefulWidget {
  const ListReader({
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final ReaderPageController controller;

  @override
  _ListReaderState createState() => _ListReaderState();
}

class _ListReaderState extends State<ListReader>
    with SingleTickerProviderStateMixin {
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  ScrollDirection? lastScrollDirection;
  final ValueNotifier<bool> showOverlay = ValueNotifier<bool>(true);
  late AnimationController appBarAnimationController = AnimationController(
    vsync: this,
    duration: Defaults.animationsNormal,
  );
  late final Animation<Color?> appBarColorTween = ColorTween(
    begin: Colors.black,
    end: Colors.black.withOpacity(0.3),
  ).animate(appBarAnimationController);

  @override
  void dispose() {
    focusNode.dispose();
    appBarAnimationController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  _ImageSize getImageSize(final BuildContext context) {
    switch (AppState.settings.value.manga.listModeSizing) {
      case MangaListModeSizing.custom:
        return _ImageSize(
          width: MediaQuery.of(context).size.width *
              (AppState.settings.value.manga.listModeCustomWidth / 100),
        );

      case MangaListModeSizing.fitHeight:
        return _ImageSize(
          height: MediaQuery.of(context).size.height,
        );

      case MangaListModeSizing.fitWidth:
        return _ImageSize(
          width: MediaQuery.of(context).size.width,
        );
    }
  }

  @override
  Widget build(final BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (final ScrollNotification notification) {
          if (notification is UserScrollNotification) {
            showOverlay.value =
                notification.direction != ScrollDirection.reverse &&
                    lastScrollDirection != ScrollDirection.reverse;

            if (notification.direction == ScrollDirection.forward ||
                notification.direction == ScrollDirection.reverse) {
              lastScrollDirection = notification.direction;
            }

            notification.metrics.pixels <= kToolbarHeight
                ? appBarAnimationController.reverse()
                : appBarAnimationController.forward();
          }

          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: PreferredSizeWrapper(
            builder: (final BuildContext context) =>
                ValueListenableBuilder<bool>(
              valueListenable: showOverlay,
              builder: (
                final BuildContext context,
                final bool showOverlay,
                final Widget? child,
              ) =>
                  AnimatedSlide(
                duration: Defaults.animationsNormal,
                offset: showOverlay ? Offset.zero : const Offset(0, -1),
                curve: Curves.easeInOut,
                child: AnimatedBuilder(
                  animation: appBarColorTween,
                  builder: (final BuildContext context, final Widget? child) =>
                      MangaReaderAppBar(
                    controller: widget.controller,
                  ),
                ),
              ),
            ),
            size: const Size.fromHeight(kToolbarHeight),
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

              return GestureDetector(
                onTap: () {
                  showOverlay.value = !showOverlay.value;
                },
                child: RawKeyboardListener(
                  autofocus: true,
                  focusNode: focusNode,
                  onKey: (final RawKeyEvent event) => widget.controller
                      .getKeyboard(context)
                      .onRawKeyEvent(event),
                  child: Stack(
                    children: <Widget>[
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: AppState.settings.value.manga.listModeSizing ==
                                MangaListModeSizing.fitHeight
                            ? const BouncingScrollPhysics()
                            : null,
                        controller: scrollController,
                        itemCount: widget.controller.pages.value!.length,
                        itemBuilder:
                            (final BuildContext context, final int index) =>
                                StatefulBuilder(
                          builder: (
                            final BuildContext context,
                            final StateSetter setState,
                          ) {
                            final PageInfo page =
                                widget.controller.pages.value![index];
                            final StatefulValueHolderWithError<ImageDescriber?>?
                                image = widget.controller.images[page];

                            if (image?.state.isWaiting ?? true) {
                              widget.controller.fetchPage(
                                page,
                                reassemble: () {
                                  setState(() {});
                                },
                              );
                            }

                            return ReactiveStateBuilder(
                              state: image?.state ?? ReactiveStates.waiting,
                              onResolving: (final BuildContext context) =>
                                  Padding(
                                padding: EdgeInsets.all(remToPx(5)),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              onResolved: (final BuildContext context) {
                                final _ImageSize size = getImageSize(context);

                                return SizedBox(
                                  width: size.width,
                                  height: size.height,
                                  child: Image.network(
                                    image!.value!.url,
                                    headers: image.value!.headers,
                                    width: size.width,
                                    height: size.height,
                                    fit: BoxFit.fill,
                                    loadingBuilder: (
                                      final BuildContext context,
                                      final Widget child,
                                      final ImageChunkEvent? loadingProgress,
                                    ) {
                                      final double minLoaderHeight =
                                          remToPx(20);
                                      final double screenHeight =
                                          MediaQuery.of(context).size.height;
                                      final double loaderHeight = size.height ??
                                          (screenHeight > minLoaderHeight
                                              ? screenHeight
                                              : minLoaderHeight);

                                      final Widget inChild =
                                          loadingProgress != null
                                              ? SizedBox(
                                                  height: loaderHeight,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                )
                                              : child;

                                      return Stack(
                                        alignment:
                                            AlignmentDirectional.bottomStart,
                                        children: <Widget>[
                                          Align(
                                            alignment:
                                                AlignmentDirectional.center,
                                            child: inChild,
                                          ),
                                          Align(
                                            alignment: AlignmentDirectional
                                                .bottomCenter,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                bottom: remToPx(0.3),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: remToPx(0.3),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  remToPx(0.2),
                                                ),
                                              ),
                                              child: Text(
                                                '${index + 1}/${widget.controller.pages.value!.length}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                              onFailed: (final BuildContext context) =>
                                  KawaiiErrorWidget.fromErrorInfo(
                                message: Translator.t.noResultsFound(),
                                error: image?.error,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: ValueListenableBuilder<bool>(
            valueListenable: showOverlay,
            builder: (
              final BuildContext context,
              final bool showOverlay,
              final Widget? child,
            ) =>
                AnimatedSlide(
              duration: Defaults.animationsNormal,
              offset: showOverlay ? Offset.zero : const Offset(0, 1),
              curve: Curves.easeInOut,
              child: child,
            ),
            child: ListReaderControls(controller: widget.controller),
          ),
        ),
      );
}
