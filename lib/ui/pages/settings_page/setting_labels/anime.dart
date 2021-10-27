import 'package:flutter/material.dart';
import '../../../../modules/app/state.dart';
import '../../../../modules/database/schemas/settings/settings.dart';
import '../../../../modules/helpers/ui.dart';
import '../../../../modules/translator/translator.dart';
import '../../../../modules/video_player/video_player.dart';
import '../setting_dialog.dart';
import '../setting_switch.dart';

List<Widget> getAnime(
  final SettingsSchema settings,
  final Future<void> Function() save,
) =>
    <Widget>[
      if (AppState.isMobile)
        SettingSwitch(
          title: Translator.t.landscapeVideoPlayer(),
          icon: Icons.screen_lock_landscape,
          desc: Translator.t.landscapeVideoPlayerDetail(),
          value: settings.animeForceLandscape,
          onChanged: (final bool val) async {
            settings.animeForceLandscape = val;

            await save();
          },
        ),
      SettingSwitch(
        title: Translator.t.autoAnimeFullscreen(),
        icon: settings.animeAutoFullscreen
            ? Icons.fullscreen
            : Icons.fullscreen_exit,
        desc: Translator.t.autoAnimeFullscreenDetail(),
        value: settings.animeAutoFullscreen,
        onChanged: (final bool val) async {
          settings.animeAutoFullscreen = val;

          await save();
        },
      ),
      SettingDialog(
        title: Translator.t.skipIntroDuration(),
        icon: Icons.fast_forward,
        subtitle: '${settings.introDuration} ${Translator.t.seconds()}',
        builder: (
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
      SettingDialog(
        title: Translator.t.seekDuration(),
        icon: Icons.fast_forward,
        subtitle: '${settings.seekDuration} ${Translator.t.seconds()}',
        builder: (
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
      SettingSwitch(
        title: Translator.t.autoPlay(),
        icon: Icons.slideshow,
        desc: Translator.t.autoPlayDetail(),
        value: settings.autoPlay,
        onChanged: (final bool val) async {
          settings.autoPlay = val;

          await save();
        },
      ),
      SettingSwitch(
        title: Translator.t.autoNext(),
        icon: Icons.skip_next,
        desc: Translator.t.autoNextDetail(),
        value: settings.autoNext,
        onChanged: (final bool val) async {
          settings.autoNext = val;

          await save();
        },
      ),
      SettingDialog(
        title: Translator.t.animeSyncPercent(),
        icon: Icons.sync_alt,
        subtitle: '${settings.animeTrackerWatchPercent}%',
        builder: (
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
    ];
