import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../modules/app/state.dart';
import '../../../../modules/database/database.dart';
import '../../../../modules/helpers/ui.dart';
import '../../../../modules/schemas/settings/anime_keyboard_shortcuts.dart';
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
  final AnimeKeyboardShortcuts shortcuts = settings.animeShortcuts;

  return <Widget>[
    if (AppState.isMobile)
      MaterialSwitchTile(
        title: Text(Translator.t.landscapeVideoPlayer()),
        icon: const Icon(Icons.screen_lock_landscape),
        subtitle: Text(Translator.t.landscapeVideoPlayerDetail()),
        value: settings.animeForceLandscape,
        onChanged: (final bool val) async {
          settings.animeForceLandscape = val;

          await save();
        },
      ),
    MaterialSwitchTile(
      title: Text(Translator.t.autoAnimeFullscreen()),
      icon: settings.animeAutoFullscreen
          ? const Icon(Icons.fullscreen)
          : const Icon(Icons.fullscreen_exit),
      subtitle: Text(Translator.t.autoAnimeFullscreenDetail()),
      value: settings.animeAutoFullscreen,
      onChanged: (final bool val) async {
        settings.animeAutoFullscreen = val;

        await save();
      },
    ),
    MaterialDialogTile(
      title: Text(Translator.t.skipIntroDuration()),
      icon: const Icon(Icons.fast_forward),
      subtitle: Text('${settings.introDuration} ${Translator.t.seconds()}'),
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
              label: '${settings.introDuration} ${Translator.t.seconds()}',
              value: settings.introDuration.toDouble(),
              min: VideoPlayer.minIntroLength.toDouble(),
              max: VideoPlayer.maxIntroLength.toDouble(),
              onChanged: (final double value) {
                setState(() {
                  settings.introDuration = value.toInt();
                });
              },
              onChangeEnd: (final double value) async {
                setState(() {
                  settings.introDuration = value.toInt();
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
      subtitle: Text('${settings.seekDuration} ${Translator.t.seconds()}'),
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
              label: '${settings.seekDuration} ${Translator.t.seconds()}',
              value: settings.seekDuration.toDouble(),
              min: VideoPlayer.minSeekLength.toDouble(),
              max: VideoPlayer.maxSeekLength.toDouble(),
              onChanged: (final double value) {
                setState(() {
                  settings.seekDuration = value.toInt();
                });
              },
              onChangeEnd: (final double value) async {
                setState(() {
                  settings.seekDuration = value.toInt();
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
      value: settings.autoPlay,
      onChanged: (final bool val) async {
        settings.autoPlay = val;

        await save();
      },
    ),
    MaterialSwitchTile(
      title: Text(Translator.t.autoNext()),
      icon: const Icon(Icons.skip_next),
      subtitle: Text(Translator.t.autoNextDetail()),
      value: settings.autoNext,
      onChanged: (final bool val) async {
        settings.autoNext = val;

        await save();
      },
    ),
    MaterialDialogTile(
      title: Text(Translator.t.animeSyncPercent()),
      icon: const Icon(Icons.sync_alt),
      subtitle: Text('${settings.animeTrackerWatchPercent}%'),
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
              label: '${settings.animeTrackerWatchPercent}%',
              value: settings.animeTrackerWatchPercent.toDouble(),
              min: 1,
              max: 100,
              onChanged: (final double value) {
                setState(() {
                  settings.animeTrackerWatchPercent = value.toInt();
                });
              },
              onChangeEnd: (final double value) async {
                setState(() {
                  settings.animeTrackerWatchPercent = value.toInt();
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
      title: Text(Translator.t.playPause()),
      icon: const Icon(Icons.play_arrow),
      keys: shortcuts.playPause,
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.playPause = keys;
        settings.animeShortcuts = shortcuts;

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.fullscreen()),
      icon: const Icon(Icons.fullscreen),
      keys: shortcuts.fullscreen,
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.fullscreen = keys;
        settings.animeShortcuts = shortcuts;

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.seekBackward()),
      icon: const Icon(Icons.fast_rewind),
      keys: shortcuts.seekBackward,
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.seekBackward = keys;
        settings.animeShortcuts = shortcuts;

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.seekForward()),
      icon: const Icon(Icons.fast_forward),
      keys: shortcuts.seekForward,
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.seekForward = keys;
        settings.animeShortcuts = shortcuts;

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.skipIntro()),
      icon: const Icon(Icons.fast_forward),
      keys: shortcuts.skipIntro,
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.skipIntro = keys;
        settings.animeShortcuts = shortcuts;

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.goBack()),
      icon: const Icon(Icons.exit_to_app),
      keys: shortcuts.exit,
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.exit = keys;
        settings.animeShortcuts = shortcuts;

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.previousEpisode()),
      icon: const Icon(Icons.arrow_back),
      keys: shortcuts.previousEpisode,
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.previousEpisode = keys;
        settings.animeShortcuts = shortcuts;

        await save();
      },
    ),
    SettingsKeyboardTile(
      title: Text(Translator.t.nextEpisode()),
      icon: const Icon(Icons.arrow_forward),
      keys: shortcuts.nextEpisode,
      onChanged: (final Set<LogicalKeyboardKey> keys) async {
        shortcuts.playPause = keys;
        settings.animeShortcuts = shortcuts;

        await save();
      },
    ),
  ];
}
