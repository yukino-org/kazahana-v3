import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../modules/app/state.dart';
import '../../../../modules/database/database.dart';
import '../../../../modules/helpers/ui.dart';
import '../../../../modules/translator/translator.dart';
import '../../../components/material_tiles/dialog.dart';
import '../../../components/material_tiles/header.dart';
import '../../../components/material_tiles/radio.dart';
import '../../../components/material_tiles/switch.dart';
import '../../../components/settings/keyboard_tite.dart';

List<Widget> getSettingsManga(
  final BuildContext context,
  final SettingsSchema settings,
  final Future<void> Function() save,
) {
  final bool isPageMode = settings.manga.readerMode == MangaReaderMode.page;
  final bool isListMode = settings.manga.readerMode == MangaReaderMode.list;
  final MangaKeyboardShortcuts shortcuts = settings.manga.shortcuts;

  return <Widget>[
    MaterialRadioTile<MangaReaderMode>(
      title: Text(Translator.t.mangaReaderMode()),
      icon: const Icon(Icons.pageview),
      value: settings.manga.readerMode,
      labels: <MangaReaderMode, String>{
        MangaReaderMode.list: Translator.t.list(),
        MangaReaderMode.page: Translator.t.page(),
      },
      onChanged: (final MangaReaderMode val) async {
        settings.manga.readerMode = val;

        await save();
      },
    ),
    if (isPageMode)
      MaterialRadioTile<MangaReaderDirection>(
        title: Text(Translator.t.mangaReaderDirection()),
        icon: const Icon(Icons.auto_stories),
        value: settings.manga.readerDirection,
        labels: <MangaReaderDirection, String>{
          MangaReaderDirection.leftToRight: Translator.t.leftToRight(),
          MangaReaderDirection.rightToLeft: Translator.t.rightToLeft(),
        },
        onChanged: (final MangaReaderDirection val) async {
          settings.manga.readerDirection = val;

          await save();
        },
      ),
    if (isPageMode && AppState.isMobile)
      MaterialRadioTile<MangaSwipeDirection>(
        title: Text(Translator.t.mangaReaderSwipeDirection()),
        icon: const Icon(Icons.swipe),
        value: settings.manga.swipeDirection,
        labels: <MangaSwipeDirection, String>{
          MangaSwipeDirection.horizontal: Translator.t.horizontal(),
          MangaSwipeDirection.vertical: Translator.t.vertical(),
        },
        onChanged: (final MangaSwipeDirection val) async {
          settings.manga.swipeDirection = val;

          await save();
        },
      ),
    if (isPageMode)
      MaterialSwitchTile(
        title: Text(Translator.t.doubleTapToSwitchChapter()),
        icon: const Icon(Icons.double_arrow),
        subtitle: Text(Translator.t.doubleTapToSwitchChapterDetail()),
        value: settings.manga.doubleClickSwitchChapter,
        onChanged: (final bool val) async {
          settings.manga.doubleClickSwitchChapter = val;

          await save();
        },
      ),
    MaterialSwitchTile(
      title: Text(Translator.t.autoMangaFullscreen()),
      icon: settings.manga.fullscreen
          ? const Icon(Icons.fullscreen)
          : const Icon(Icons.fullscreen_exit),
      subtitle: Text(Translator.t.autoMangaFullscreenDetail()),
      value: settings.manga.fullscreen,
      onChanged: (final bool val) async {
        settings.manga.fullscreen = val;

        await save();
      },
    ),
    if (isListMode)
      MaterialRadioTile<MangaListModeSizing>(
        title: Text(Translator.t.imageSize()),
        icon: const Icon(Icons.photo_size_select_small),
        value: settings.manga.listModeSizing,
        labels: <MangaListModeSizing, String>{
          MangaListModeSizing.custom: Translator.t.custom(),
          MangaListModeSizing.fitHeight: Translator.t.fitHeight(),
          MangaListModeSizing.fitWidth: Translator.t.fitWidth(),
        },
        onChanged: (final MangaListModeSizing val) async {
          settings.manga.listModeSizing = val;

          await save();
        },
      ),
    if (isListMode &&
        settings.manga.listModeSizing == MangaListModeSizing.custom)
      MaterialDialogTile(
        title: Text(Translator.t.imageCustomWidth()),
        icon: const Icon(Icons.photo_size_select_actual),
        subtitle: Text('${settings.manga.listModeCustomWidth}%'),
        dialogBuilder: (
          final BuildContext context,
          final StateSetter setState,
        ) =>
            Wrap(
          children: <Widget>[
            SliderTheme(
              data: SliderThemeData(
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: remToPx(0.4),
                ),
                showValueIndicator: ShowValueIndicator.always,
              ),
              child: Slider(
                label: '${settings.manga.listModeCustomWidth}%',
                value: settings.manga.listModeCustomWidth.toDouble(),
                min: 1,
                max: 100,
                onChanged: (final double value) {
                  setState(() {
                    settings.manga.listModeCustomWidth = value.toInt();
                  });
                },
                onChangeEnd: (final double value) async {
                  setState(() {
                    settings.manga.listModeCustomWidth = value.toInt();
                  });

                  await save();
                },
              ),
            ),
          ],
        ),
      ),
    MaterialHeaderTile(text: Text(Translator.t.keyboardShortcuts())),
    SettingsKeyboardTile(
      title: Text(Translator.t.fullscreen()),
      icon: const Icon(Icons.fullscreen),
      keys: shortcuts.get(MangaKeyboardShortcutsKeys.fullscreen),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(MangaKeyboardShortcutsKeys.fullscreen, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.goBack()),
      icon: const Icon(Icons.exit_to_app),
      keys: shortcuts.get(MangaKeyboardShortcutsKeys.exit),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(MangaKeyboardShortcutsKeys.exit, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.previousPage()),
      icon: const Icon(Icons.arrow_back),
      keys: shortcuts.get(MangaKeyboardShortcutsKeys.previousPage),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(MangaKeyboardShortcutsKeys.previousPage, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.nextPage()),
      icon: const Icon(Icons.arrow_forward),
      keys: shortcuts.get(MangaKeyboardShortcutsKeys.nextPage),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(MangaKeyboardShortcutsKeys.nextPage, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.previousChapter()),
      icon: const Icon(Icons.fast_rewind),
      keys: shortcuts.get(MangaKeyboardShortcutsKeys.previousChapter),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(MangaKeyboardShortcutsKeys.previousChapter, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.nextChapter()),
      icon: const Icon(Icons.fast_forward),
      keys: shortcuts.get(MangaKeyboardShortcutsKeys.nextChapter),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(MangaKeyboardShortcutsKeys.nextChapter, keys);

        await save();
      },
    ),
  ];
}
