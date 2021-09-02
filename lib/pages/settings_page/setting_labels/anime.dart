import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../../core/models/player.dart' show Player;
import '../../../plugins/database/schemas/settings/settings.dart';
import '../../../plugins/helpers/ui.dart';
import '../../../plugins/translator/translator.dart';
import '../setting_dialog.dart';
import '../setting_switch.dart';

List<Widget> getAnime(
  final SettingsSchema settings,
  final Future<void> Function() save,
) =>
    <Widget>[
      if (Platform.isAndroid || Platform.isIOS)
        SettingSwitch(
          title: Translator.t.landscapeVideoPlayer(),
          icon: Icons.screen_lock_landscape,
          desc: Translator.t.landscapeVideoPlayerDetail(),
          value: settings.fullscreenVideoPlayer,
          onChanged: (final bool val) async {
            settings.fullscreenVideoPlayer = val;

            await save();
          },
        ),
      SettingDialog(
        title: Translator.t.volume(),
        icon: settings.volume == 0
            ? Icons.volume_mute
            : settings.volume > 50
                ? Icons.volume_up
                : Icons.volume_down,
        subtitle: '${settings.volume}%',
        builder: (
          final BuildContext context,
          final StateSetter setState,
        ) =>
            Padding(
          padding: EdgeInsets.symmetric(
            horizontal: remToPx(0.5),
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.volume_mute),
                onPressed: () {
                  setState(() {
                    settings.volume = Player.minVolume;
                  });
                },
              ),
              Expanded(
                child: Wrap(
                  children: <Widget>[
                    SliderTheme(
                      data: SliderThemeData(
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: remToPx(0.4),
                        ),
                        showValueIndicator: ShowValueIndicator.always,
                      ),
                      child: Slider(
                        label: '${settings.volume}%',
                        value: settings.volume.toDouble(),
                        min: Player.minVolume.toDouble(),
                        max: Player.maxVolume.toDouble(),
                        onChanged: (final double value) {
                          setState(() {
                            settings.volume = value.toInt();
                          });
                        },
                        onChangeEnd: (final double value) async {
                          setState(() {
                            settings.volume = value.toInt();
                          });

                          await save();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  setState(() {
                    settings.volume = Player.maxVolume;
                  });
                },
              ),
            ],
          ),
        ),
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
                min: Player.minIntroLength.toDouble(),
                max: Player.maxIntroLength.toDouble(),
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
                min: Player.minSeekLength.toDouble(),
                max: Player.maxSeekLength.toDouble(),
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
      Visibility(
        visible: Platform.isLinux || Platform.isLinux || Platform.isWindows,
        child: SettingSwitch(
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
      ),
    ];
