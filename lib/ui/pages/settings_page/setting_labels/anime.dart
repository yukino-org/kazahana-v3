import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../modules/app/state.dart';
import '../../../../modules/database/database.dart';
import '../../../../modules/helpers/ui.dart';
import '../../../../modules/translator/translator.dart';
import '../../../../modules/video_player/video_player.dart';
import '../../../components/material_tiles/dialog.dart';
import '../../../components/material_tiles/header.dart';
import '../../../components/material_tiles/switch.dart';
import '../../../components/settings/keyboard_tite.dart';

List<Widget> getSettingsAnime(
  final BuildContext context,
  final SettingsSchema settings,
  final Future<void> Function() save,
) {
  final AnimeKeyboardShortcuts shortcuts = settings.anime.shortcuts;

  return <Widget>[
    if (AppState.isMobile)
      MaterialSwitchTile(
        title: Text(Translator.t.landscapeVideoPlayer()),
        icon: const Icon(Icons.screen_lock_landscape),
        subtitle: Text(Translator.t.landscapeVideoPlayerDetail()),
        value: settings.anime.landscape,
        onChanged: (final bool val) async {
          settings.anime.landscape = val;

          await save();
        },
      ),
    MaterialSwitchTile(
      title: Text(Translator.t.autoAnimeFullscreen()),
      icon: settings.anime.fullscreen
          ? const Icon(Icons.fullscreen)
          : const Icon(Icons.fullscreen_exit),
      subtitle: Text(Translator.t.autoAnimeFullscreenDetail()),
      value: settings.anime.fullscreen,
      onChanged: (final bool val) async {
        settings.anime.fullscreen = val;

        await save();
      },
    ),
    MaterialDialogTile(
      title: Text(Translator.t.skipIntroDuration()),
      icon: const Icon(Icons.fast_forward),
      subtitle:
          Text('${settings.anime.introDuration} ${Translator.t.seconds()}'),
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
              label:
                  '${settings.anime.introDuration} ${Translator.t.seconds()}',
              value: settings.anime.introDuration.toDouble(),
              min: VideoPlayer.minIntroLength.toDouble(),
              max: VideoPlayer.maxIntroLength.toDouble(),
              onChanged: (final double value) {
                setState(() {
                  settings.anime.introDuration = value.toInt();
                });
              },
              onChangeEnd: (final double value) async {
                setState(() {
                  settings.anime.introDuration = value.toInt();
                });

                await save();
              },
            ),
          ),
        ],
      ),
    ),
    MaterialDialogTile(
      title: Text(Translator.t.seekDuration()),
      icon: const Icon(Icons.fast_forward),
      subtitle:
          Text('${settings.anime.seekDuration} ${Translator.t.seconds()}'),
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
              label: '${settings.anime.seekDuration} ${Translator.t.seconds()}',
              value: settings.anime.seekDuration.toDouble(),
              min: VideoPlayer.minSeekLength.toDouble(),
              max: VideoPlayer.maxSeekLength.toDouble(),
              onChanged: (final double value) {
                setState(() {
                  settings.anime.seekDuration = value.toInt();
                });
              },
              onChangeEnd: (final double value) async {
                setState(() {
                  settings.anime.seekDuration = value.toInt();
                });

                await save();
              },
            ),
          ),
        ],
      ),
    ),
    MaterialSwitchTile(
      title: Text(Translator.t.autoPlay()),
      icon: const Icon(Icons.slideshow),
      subtitle: Text(Translator.t.autoPlayDetail()),
      value: settings.anime.autoPlay,
      onChanged: (final bool val) async {
        settings.anime.autoPlay = val;

        await save();
      },
    ),
    MaterialSwitchTile(
      title: Text(Translator.t.autoNext()),
      icon: const Icon(Icons.skip_next),
      subtitle: Text(Translator.t.autoNextDetail()),
      value: settings.anime.autoNext,
      onChanged: (final bool val) async {
        settings.anime.autoNext = val;

        await save();
      },
    ),
    MaterialDialogTile(
      title: Text(Translator.t.animeSyncPercent()),
      icon: const Icon(Icons.sync_alt),
      subtitle: Text('${settings.anime.syncThreshold}%'),
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
              label: '${settings.anime.syncThreshold}%',
              value: settings.anime.syncThreshold.toDouble(),
              min: 1,
              max: 100,
              onChanged: (final double value) {
                setState(() {
                  settings.anime.syncThreshold = value.toInt();
                });
              },
              onChangeEnd: (final double value) async {
                setState(() {
                  settings.anime.syncThreshold = value.toInt();
                });

                await save();
              },
            ),
          ),
        ],
      ),
    ),
    Align(
      alignment: Alignment.topLeft,
      child: MaterialHeaderTile(text: Text(Translator.t.keyboardShortcuts())),
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.playPause()),
      icon: const Icon(Icons.play_arrow),
      keys: shortcuts.get(AnimeKeyboardShortcutsKeys.playPause),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(AnimeKeyboardShortcutsKeys.playPause, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.fullscreen()),
      icon: const Icon(Icons.fullscreen),
      keys: shortcuts.get(AnimeKeyboardShortcutsKeys.fullscreen),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(AnimeKeyboardShortcutsKeys.fullscreen, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.seekBackward()),
      icon: const Icon(Icons.fast_rewind),
      keys: shortcuts.get(AnimeKeyboardShortcutsKeys.seekBackward),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(AnimeKeyboardShortcutsKeys.seekBackward, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.seekForward()),
      icon: const Icon(Icons.fast_forward),
      keys: shortcuts.get(AnimeKeyboardShortcutsKeys.seekForward),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(AnimeKeyboardShortcutsKeys.seekForward, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.skipIntro()),
      icon: const Icon(Icons.fast_forward),
      keys: shortcuts.get(AnimeKeyboardShortcutsKeys.skipIntro),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(AnimeKeyboardShortcutsKeys.skipIntro, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.goBack()),
      icon: const Icon(Icons.exit_to_app),
      keys: shortcuts.get(AnimeKeyboardShortcutsKeys.exit),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(AnimeKeyboardShortcutsKeys.exit, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.previousEpisode()),
      icon: const Icon(Icons.arrow_back),
      keys: shortcuts.get(AnimeKeyboardShortcutsKeys.previousEpisode),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(AnimeKeyboardShortcutsKeys.previousEpisode, keys);

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.nextEpisode()),
      icon: const Icon(Icons.arrow_forward),
      keys: shortcuts.get(AnimeKeyboardShortcutsKeys.nextEpisode),
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.set(AnimeKeyboardShortcutsKeys.nextEpisode, keys);

        await save();
      },
    ),
  ];
}
