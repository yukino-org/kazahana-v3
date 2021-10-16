import 'package:flutter/material.dart';
import '../../../plugins/database/schemas/settings/settings.dart';
import '../../../plugins/state.dart';
import '../../../plugins/translator/translator.dart';
import '../setting_radio.dart';
import '../setting_switch.dart';

List<Widget> getManga(
  final SettingsSchema settings,
  final Future<void> Function() save,
) =>
    <Widget>[
      SettingRadio<MangaDirections>(
        title: Translator.t.mangaReaderDirection(),
        icon: Icons.auto_stories,
        value: settings.mangaReaderDirection,
        labels: <MangaDirections, String>{
          MangaDirections.leftToRight: Translator.t.leftToRight(),
          MangaDirections.rightToLeft: Translator.t.rightToLeft(),
        },
        onChanged: (final MangaDirections val) async {
          settings.mangaReaderDirection = val;

          await save();
        },
      ),
      if (AppState.isMobile)
        SettingRadio<MangaSwipeDirections>(
          title: Translator.t.mangaReaderSwipeDirection(),
          icon: Icons.swipe,
          value: settings.mangaReaderSwipeDirection,
          labels: <MangaSwipeDirections, String>{
            MangaSwipeDirections.horizontal: Translator.t.horizontal(),
            MangaSwipeDirections.vertical: Translator.t.vertical(),
          },
          onChanged: (final MangaSwipeDirections val) async {
            settings.mangaReaderSwipeDirection = val;

            await save();
          },
        ),
      SettingRadio<MangaMode>(
        title: Translator.t.mangaReaderMode(),
        icon: Icons.pageview,
        value: settings.mangaReaderMode,
        labels: <MangaMode, String>{
          MangaMode.list: Translator.t.list(),
          MangaMode.page: Translator.t.page(),
        },
        onChanged: (final MangaMode val) async {
          settings.mangaReaderMode = val;

          await save();
        },
      ),
      SettingSwitch(
        title: Translator.t.doubleTapToSwitchChapter(),
        icon: Icons.double_arrow,
        desc: Translator.t.doubleTapToSwitchChapterDetail(),
        value: settings.doubleClickSwitchChapter,
        onChanged: (final bool val) async {
          settings.doubleClickSwitchChapter = val;

          await save();
        },
      ),
      SettingSwitch(
        title: Translator.t.autoMangaFullscreen(),
        icon: settings.mangaAutoFullscreen
            ? Icons.fullscreen
            : Icons.fullscreen_exit,
        desc: Translator.t.autoMangaFullscreenDetail(),
        value: settings.mangaAutoFullscreen,
        onChanged: (final bool val) async {
          settings.mangaAutoFullscreen = val;

          await save();
        },
      ),
    ];
