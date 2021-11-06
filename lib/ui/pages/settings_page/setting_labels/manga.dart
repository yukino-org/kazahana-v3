import 'package:flutter/material.dart';
import '../../../../modules/app/state.dart';
import '../../../../modules/database/database.dart';
import '../../../../modules/translator/translator.dart';
import '../../../components/material_tiles/radio.dart';
import '../../../components/material_tiles/switch.dart';

List<Widget> getSettingsManga(
  final BuildContext context,
  final SettingsSchema settings,
  final Future<void> Function() save,
) =>
    <Widget>[
      RadioMaterialTile<MangaDirections>(
        title: Text(Translator.t.mangaReaderDirection()),
        icon: const Icon(Icons.auto_stories),
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
        RadioMaterialTile<MangaSwipeDirections>(
          title: Text(Translator.t.mangaReaderSwipeDirection()),
          icon: const Icon(Icons.swipe),
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
      RadioMaterialTile<MangaMode>(
        title: Text(Translator.t.mangaReaderMode()),
        icon: const Icon(Icons.pageview),
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
      MaterialSwitchTile(
        title: Text(Translator.t.doubleTapToSwitchChapter()),
        icon: const Icon(Icons.double_arrow),
        subtitle: Text(Translator.t.doubleTapToSwitchChapterDetail()),
        value: settings.doubleClickSwitchChapter,
        onChanged: (final bool val) async {
          settings.doubleClickSwitchChapter = val;

          await save();
        },
      ),
      MaterialSwitchTile(
        title: Text(Translator.t.autoMangaFullscreen()),
        icon: settings.mangaAutoFullscreen
            ? const Icon(Icons.fullscreen)
            : const Icon(Icons.fullscreen_exit),
        subtitle: Text(Translator.t.autoMangaFullscreenDetail()),
        value: settings.mangaAutoFullscreen,
        onChanged: (final bool val) async {
          settings.mangaAutoFullscreen = val;

          await save();
        },
      ),
    ];
