import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import './controller.dart';
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
import '../../../../../../models/view.dart';
import '../../controller.dart';
import '../../widgets/appbar.dart';
import 'widgets/controls.dart';

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
  final FocusNode focusNode = FocusNode();

  late final PageReaderController controller = PageReaderController(
    readerController: widget.controller,
  );

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => View<PageReaderController>(
        controller: controller,
        builder: (
          final BuildContext context,
          final PageReaderController controller,
        ) =>
            Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: PreferredSizeWrapper.fromChild(
            builder: (
              final BuildContext context,
              final PreferredSizeWidget child,
            ) =>
                AnimatedSlide(
              duration: Defaults.animationsNormal,
              offset: controller.readerController.showControls
                  ? Offset.zero
                  : const Offset(0, -1),
              curve: Curves.easeInOut,
              child: child,
            ),
            child: MangaReaderAppBar(
              controller: controller.readerController,
            ),
          ),
          body: Builder(
            builder: (final BuildContext context) {
              if (controller.readerController.pages.value!.isEmpty) {
                return Center(
                  child: KawaiiErrorWidget(
                    message: Translator.t.noPagesFound(),
                  ),
                );
              }

              return RawKeyboardListener(
                autofocus: true,
                focusNode: focusNode,
                onKey: (final RawKeyEvent event) => controller.readerController
                    .getKeyboard(context)
                    .onRawKeyEvent(event),
                child: PageView.builder(
                  allowImplicitScrolling: true,
                  scrollDirection:
                      AppState.settings.value.manga.swipeDirection ==
                              MangaSwipeDirection.horizontal
                          ? Axis.horizontal
                          : Axis.vertical,
                  onPageChanged: (final int page) {
                    controller
                      ..readerController.setCurrentPageIndex(page)
                      ..interactiveController.value = Matrix4.identity()
                      ..readerController.reassemble();
                  },
                  physics: controller.interactionOnProgress
                      ? const NeverScrollableScrollPhysics()
                      : const PageScrollPhysics(),
                  controller: controller.pageController,
                  itemCount: controller.readerController.pages.value!.length,
                  itemBuilder: (final BuildContext context, final int _index) {
                    final StatefulValueHolderWithError<ImageDescriber?>? image =
                        controller.readerController.currentPageImage;

                    return ReactiveStateBuilder(
                      state: image?.state ?? ReactiveStates.waiting,
                      onResolving: (final BuildContext context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      onResolved: (final BuildContext context) =>
                          GestureDetector(
                        onTapDown: (final TapDownDetails details) {
                          controller.lastTapDetails = details;
                        },
                        onDoubleTapDown: (final TapDownDetails details) {
                          controller.lastTapDetails = details;
                        },
                        onTap: () async {
                          await controller.handleTaps(context, 1);
                        },
                        onDoubleTap: () async {
                          await controller.handleTaps(context, 2);
                        },
                        child: Stack(
                          children: <Widget>[
                            Align(
                              child: SizedBox.fromSize(
                                size: MediaQuery.of(context).size,
                                child: InteractiveViewer(
                                  transformationController:
                                      controller.interactiveController,
                                  child: Image.network(
                                    image!.value!.url,
                                    headers: image.value!.headers,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (
                                      final BuildContext context,
                                      final Widget child,
                                      final ImageChunkEvent? loadingProgress,
                                    ) {
                                      if (loadingProgress == null) {
                                        return child;
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
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.all(remToPx(0.3)),
                                child: ValueListenableBuilder<Widget?>(
                                  valueListenable:
                                      controller.footerNotificationContent,
                                  builder: (
                                    final BuildContext context,
                                    final Widget? footerNotificationContent,
                                    final Widget? child,
                                  ) =>
                                      AnimatedSwitcher(
                                    duration: Defaults.animationsSlower,
                                    child: footerNotificationContent ?? child!,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: remToPx(0.3),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(remToPx(0.2)),
                                    ),
                                    child: Text(
                                      '${controller.readerController.currentPageIndex + 1}/${controller.readerController.pages.value!.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
            offset: controller.readerController.showControls
                ? Offset.zero
                : const Offset(0, 1),
            curve: Curves.easeInOut,
            child: PageReaderControls(controller: controller),
          ),
        ),
      );
}
