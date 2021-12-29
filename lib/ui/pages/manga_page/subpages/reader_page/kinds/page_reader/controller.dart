import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../../../config/defaults.dart';
import '../../../../../../../modules/app/state.dart';
import '../../../../../../../modules/database/database.dart';
import '../../../../../../../modules/translator/translator.dart';
import '../../../../../../models/controller.dart';
import '../../controller.dart';

class PageReaderController extends Controller<PageReaderController> {
  PageReaderController({
    required final this.readerController,
  });

  final ReaderPageController readerController;

  Timer? footerNotificationTimer;
  TapDownDetails? lastTapDetails;

  final ValueNotifier<Widget?> footerNotificationContent =
      ValueNotifier<Widget?>(null);
  final TransformationController interactiveController =
      TransformationController();

  late final PageController pageController = PageController(
    initialPage: readerController.currentPageIndex,
  );

  @override
  Future<void> dispose() async {
    footerNotificationTimer?.cancel();
    footerNotificationContent.dispose();
    interactiveController.dispose();
    pageController.dispose();

    await super.dispose();
  }

  void showFooterNotification(final BuildContext context, final Widget? child) {
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
        showFooterNotification(context, null);
      });
    }
  }

  Future<void> previousPage(final BuildContext context) async {
    if (readerController.previousPageAvailable) {
      await setCurrentPageIndex(readerController.currentPageIndex - 1);
    } else {
      showFooterNotification(
        context,
        Text(Translator.t.tapAgainToSwitchPreviousChapter()),
      );
    }
  }

  Future<void> nextPage(final BuildContext context) async {
    if (readerController.nextPageAvailable) {
      await setCurrentPageIndex(readerController.currentPageIndex + 1);
    } else {
      showFooterNotification(
        context,
        Text(Translator.t.tapAgainToSwitchPreviousChapter()),
      );
    }
  }

  Future<void> previousChapter(final BuildContext context) async {
    if (readerController.previousChapterAvailable) {
      await readerController.previousChapter();
    } else {
      showFooterNotification(
        context,
        Text(Translator.t.noMoreChaptersLeft()),
      );
    }
  }

  Future<void> nextChapter(final BuildContext context) async {
    if (readerController.nextChapterAvailable) {
      await readerController.nextChapter();
    } else {
      showFooterNotification(
        context,
        Text(Translator.t.noMoreChaptersLeft()),
      );
    }
  }

  /// [kind] 1 - Tap, 2 - Double tap
  Future<void> leftTap(final BuildContext context, final int kind) async {
    switch (kind) {
      case 1:
        if (!AppState.settings.value.manga.doubleClickSwitchChapter &&
            !(isReversed
                ? readerController.nextPageAvailable
                : readerController.previousPageAvailable)) {
          await (isReversed ? nextChapter(context) : previousPage(context));
        } else {
          await (isReversed ? nextPage(context) : previousPage(context));
        }
        break;

      case 2:
        if (AppState.settings.value.manga.doubleClickSwitchChapter) {
          await (isReversed ? nextChapter(context) : previousChapter(context));
        }
        break;
    }
  }

  /// [kind] 1 - Tap, 2 - Double tap
  Future<void> middleTap(final BuildContext context, final int kind) async {
    switch (kind) {
      case 1:
        readerController
          ..showControls = !readerController.showControls
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
  Future<void> rightTap(final BuildContext context, final int kind) async {
    switch (kind) {
      case 1:
        if (!AppState.settings.value.manga.doubleClickSwitchChapter &&
            !(isReversed
                ? readerController.previousPageAvailable
                : readerController.nextPageAvailable)) {
          await (isReversed ? previousChapter(context) : nextPage(context));
        } else {
          await (isReversed ? previousPage(context) : nextPage(context));
        }
        break;

      case 2:
        if (AppState.settings.value.manga.doubleClickSwitchChapter) {
          await (isReversed ? previousChapter(context) : nextChapter(context));
        }
        break;
    }
  }

  /// [kind] 1 - Tap, 2 - Double tap
  Future<void> handleTaps(final BuildContext context, final int kind) async {
    if (lastTapDetails == null) return;

    final double position =
        lastTapDetails!.localPosition.dx / MediaQuery.of(context).size.width;

    if (!interactionOnProgress && position <= 0.3) {
      await leftTap(context, kind);
    } else if (!interactionOnProgress && position >= 0.7) {
      await rightTap(context, kind);
    } else {
      await middleTap(context, kind);
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
    readerController.setCurrentPageIndex(page);
  }

  bool get interactionOnProgress => !interactiveController.value.isIdentity();

  bool get isHorizontal =>
      AppState.settings.value.manga.swipeDirection ==
      MangaSwipeDirection.horizontal;

  bool get isReversed =>
      AppState.settings.value.manga.readerDirection ==
      MangaReaderDirection.rightToLeft;

  int get calculatedPageIndex => isReversed
      ? readerController.pages.value!.length -
          readerController.currentPageIndex -
          1
      : readerController.currentPageIndex;
}
