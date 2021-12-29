import 'dart:async';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../../../modules/app/state.dart';
import '../../../../../modules/database/database.dart';
import '../../../../../modules/helpers/keyboard.dart';
import '../../../../../modules/helpers/screen.dart';
import '../../../../../modules/state/stateful_holder.dart';
import '../../../../../modules/state/states.dart';
import '../../../../../modules/trackers/provider.dart';
import '../../../../../modules/trackers/trackers.dart';
import '../../../../models/controller.dart';
import '../../controller.dart';

class ReaderPageController extends Controller<ReaderPageController> {
  ReaderPageController({
    required final this.mangaController,
  });

  final MangaPageController mangaController;

  int currentPageIndex = 0;

  bool ignoreScreenChanges = false;
  bool locked = false;
  bool hasSynced = false;
  bool showControls = true;

  final FullscreenPreserver fullscreen = FullscreenPreserver();
  final StatefulValueHolderWithError<List<PageInfo>?> pages =
      StatefulValueHolderWithError<List<PageInfo>?>(null);
  final Map<PageInfo, StatefulValueHolderWithError<ImageDescriber?>> images =
      <PageInfo, StatefulValueHolderWithError<ImageDescriber?>>{};

  @override
  Future<void> setup() async {
    Screen.isWakelockEnabled().then((final bool isWakelockEnabled) async {
      if (!isWakelockEnabled) {
        await Screen.enableWakelock();
      }
    });

    if (AppState.settings.value.manga.fullscreen) {
      fullscreen.enterFullscreen();
    }

    await super.setup();
  }

  @override
  Future<void> ready() async {
    await fetchPages();
    await setCurrentPageIndex(currentPageIndex);

    await super.ready();
  }

  @override
  Future<void> dispose() async {
    if (!ignoreScreenChanges) {
      Screen.disableWakelock();
      fullscreen.exitFullscreen();
    }

    await super.dispose();
  }

  Future<void> fetchPages() async {
    pages.resolving(null);
    reassemble();

    try {
      pages.resolve(
        await mangaController.extractor!
            .getChapter(mangaController.currentChapter!),
      );
    } catch (err, stack) {
      pages.fail(null, ErrorInfo(err, stack));
    }

    reassemble();
  }

  Future<void> setCurrentPageIndex(final int index) async {
    currentPageIndex = index;
    reassemble();

    await Future.wait(<Future<void>>[
      fetchPage(currentPage),
      _updateTrackers(),
    ]);
  }

  Future<void> fetchPage(
    final PageInfo page, {
    final void Function()? reassemble,
  }) async {
    void _reassemble() {
      if (reassemble != null) return reassemble();

      this.reassemble();
    }

    if (images[page]?.state.isWaiting ?? true) {
      images[page] = StatefulValueHolderWithError<ImageDescriber?>(null)
        ..resolving(null);

      _reassemble();

      try {
        images[page]!.resolve(await mangaController.extractor!.getPage(page));
      } catch (err, stack) {
        images[page]!.fail(null, ErrorInfo(err, stack));
      }
    }

    _reassemble();
  }

  Future<void> _updateTrackers() async {
    if (hasSynced) return;

    final ChapterInfo? _currentChapter = mangaController.currentChapter;
    if (_currentChapter == null) return;

    final int? chapter = int.tryParse(mangaController.currentChapter!.chapter);
    if (chapter == null) return;

    final MangaProgress progress = MangaProgress(
      chapters: chapter,
      volume: _currentChapter.volume != null
          ? int.tryParse(_currentChapter.volume!)
          : null,
    );

    final String title = mangaController.info.value!.title;
    final String plugin = mangaController.extractor!.id;

    for (final TrackerProvider<MangaProgress> provider in Trackers.manga) {
      if (provider.isLoggedIn() && provider.isEnabled(title, plugin)) {
        final ResolvedTrackerItem? item =
            await provider.getComputed(title, plugin);

        if (item != null) {
          await provider.updateComputed(item, progress);
        }
      }
    }
  }

  Future<void> setFullscreen({
    required final bool enabled,
  }) async {
    AppState.settings.value.manga.fullscreen = enabled;

    await (AppState.settings.value.manga.fullscreen
        ? fullscreen.enterFullscreen()
        : fullscreen.exitFullscreen());

    await SettingsBox.save(AppState.settings.value);
  }

  KeyboardHandler getKeyboard(final BuildContext context) {
    final MangaKeyboardShortcuts shortcuts =
        AppState.settings.value.manga.shortcuts;

    return KeyboardHandler(
      onKeyDown: <KeyboardKeyHandler>[
        KeyboardKeyHandler(
          shortcuts.get(MangaKeyboardShortcutsKeys.fullscreen),
          (final RawKeyEvent event) async {
            await setFullscreen(
              enabled: !AppState.settings.value.manga.fullscreen,
            );
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(MangaKeyboardShortcutsKeys.exit),
          (final RawKeyEvent event) async {
            await mangaController.goHome();
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(MangaKeyboardShortcutsKeys.previousPage),
          (final RawKeyEvent event) async {
            if (previousPageAvailable) {
              await previousPage();
            }
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(MangaKeyboardShortcutsKeys.nextPage),
          (final RawKeyEvent event) async {
            if (nextPageAvailable) {
              await nextPage();
            }
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(MangaKeyboardShortcutsKeys.previousChapter),
          (final RawKeyEvent event) async {
            if (previousChapterAvailable) {
              await previousChapter();
            }
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(MangaKeyboardShortcutsKeys.nextChapter),
          (final RawKeyEvent event) async {
            if (nextChapterAvailable) {
              await nextChapter();
            }
          },
        ),
      ],
    );
  }

  Future<void> previousPage() async {
    if (previousPageAvailable) {
      await setCurrentPageIndex(currentPageIndex - 1);
    }
  }

  Future<void> nextPage() async {
    if (nextPageAvailable) {
      await setCurrentPageIndex(currentPageIndex + 1);
    }
  }

  Future<void> previousChapter() async {
    if (previousChapterAvailable) {
      await mangaController
          .setCurrentChapterIndex(mangaController.currentChapterIndex! - 1);
    }
  }

  Future<void> nextChapter() async {
    if (nextChapterAvailable) {
      await mangaController
          .setCurrentChapterIndex(mangaController.currentChapterIndex! + 1);
    }
  }

  PageInfo get currentPage => pages.value!.elementAt(currentPageIndex);

  StatefulValueHolderWithError<ImageDescriber?>? get currentPageImage =>
      images[currentPage];

  bool get previousPageAvailable => currentPageIndex - 1 >= 0;

  bool get nextPageAvailable => currentPageIndex + 1 < pages.value!.length;

  bool get previousChapterAvailable =>
      mangaController.currentChapterIndex != null &&
      mangaController.currentChapterIndex! - 1 >= 0;

  bool get nextChapterAvailable =>
      mangaController.currentChapterIndex != null &&
      mangaController.currentChapterIndex! + 1 <
          mangaController.info.value!.chapters.length;

  MangaReaderMode get mangaMode => AppState.settings.value.manga.readerMode;
}
