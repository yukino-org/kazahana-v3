import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './select_source.dart';
import '../../components/player/player.dart';
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../core/models/player.dart' as player_model;
import '../../plugins/helpers/ui.dart';
import '../../plugins/helpers/utils/duration.dart';
import '../../plugins/helpers/utils/list.dart';
import '../../plugins/state.dart' show AppState;
import '../../plugins/translator/translator.dart';
import '../settings_page/setting_dialog.dart';
import '../settings_page/setting_radio.dart';
import '../settings_page/setting_switch.dart';
import '../settings_page/setting_tile.dart';

class VideoDuration {
  VideoDuration(this.current, this.total);

  final Duration current;
  final Duration total;
}

class WatchPage extends StatefulWidget {
  const WatchPage({
    required final this.sources,
    required final this.title,
    required final this.onPop,
    required final this.previousEpisodeEnabled,
    required final this.previousEpisode,
    required final this.nextEpisodeEnabled,
    required final this.nextEpisode,
    final Key? key,
    final this.initialIndex,
  }) : super(key: key);

  final int? initialIndex;
  final List<anime_model.EpisodeSource> sources;
  final Widget title;
  final void Function() onPop;
  final bool previousEpisodeEnabled;
  final void Function() previousEpisode;
  final bool nextEpisodeEnabled;
  final void Function() nextEpisode;

  @override
  WatchPageState createState() => WatchPageState();
}

class WatchPageState extends State<WatchPage> with TickerProviderStateMixin {
  int? currentIndex;
  player_model.Player? player;
  Widget? playerChild;

  bool showControls = true;
  bool locked = false;
  bool autoPlay = AppState.settings.current.autoPlay;
  bool autoNext = AppState.settings.current.autoNext;
  bool? wasPausedBySlider;
  double speed = player_model.Player.defaultSpeed;
  int seekDuration = AppState.settings.current.seekDuration;
  int introDuration = AppState.settings.current.introDuration;
  final Duration animationDuration = const Duration(milliseconds: 300);

  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  late AnimationController playPauseController;
  late AnimationController overlayController;

  late final ValueNotifier<VideoDuration> duration =
      ValueNotifier<VideoDuration>(
    VideoDuration(Duration.zero, Duration.zero),
  );
  late final ValueNotifier<int> volume = ValueNotifier<int>(
    100,
  );

  final Widget loader = const Center(
    child: CircularProgressIndicator(),
  );

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () {
      showSelectSources();
    });

    playPauseController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );

    overlayController = AnimationController(
      vsync: this,
      duration: animationDuration,
      value: showControls ? 1 : 0,
    );

    overlayController.addStatusListener((final AnimationStatus status) {
      switch (status) {
        case AnimationStatus.forward:
          setState(() {
            showControls = true;
          });
          break;

        case AnimationStatus.dismissed:
          setState(() {
            showControls = overlayController.isCompleted;
          });
          break;

        default:
          setState(() {
            showControls = overlayController.value > 0;
          });
          break;
      }
    });

    _updateLandscape();
  }

  @override
  void dispose() {
    isPlaying.dispose();
    duration.dispose();
    volume.dispose();

    if (player != null) {
      playerChild = null;
      player!.destroy();
    }

    _updateLandscape(true);

    super.dispose();
  }

  Future<void> setPlayer(final int index) async {
    setState(() {
      currentIndex = index;
      playerChild = null;
    });

    if (player != null) {
      player!.destroy();
    }

    isPlaying.value = false;

    player = createPlayer(
      player_model.PlayerSource(
        url: widget.sources[currentIndex!].url,
        headers: widget.sources[currentIndex!].headers,
      ),
    )..subscribe(_subscriber);

    await player!.load();
  }

  void _subscriber(final player_model.PlayerEvents event) {
    switch (event) {
      case player_model.PlayerEvents.load:
        player!.setVolume(volume.value);
        setState(() {
          playerChild = player!.getWidget();
        });
        _updateDuration();
        if (autoPlay) {
          player!.play();
        }
        break;

      case player_model.PlayerEvents.durationUpdate:
        _updateDuration();
        break;

      case player_model.PlayerEvents.play:
        isPlaying.value = true;
        break;

      case player_model.PlayerEvents.pause:
        isPlaying.value = false;
        break;

      case player_model.PlayerEvents.seek:
        if (wasPausedBySlider == true) {
          player!.play();
          wasPausedBySlider = null;
        }
        break;

      case player_model.PlayerEvents.volume:
        volume.value = player!.volume;
        break;

      case player_model.PlayerEvents.end:
        if (autoNext) {
          if (widget.nextEpisodeEnabled) {
            widget.nextEpisode();
          }
        }
        break;

      case player_model.PlayerEvents.speed:
        speed = player!.speed;
        break;
    }
  }

  void _updateDuration() {
    duration.value = VideoDuration(
      player?.duration ?? Duration.zero,
      player?.totalDuration ?? Duration.zero,
    );
  }

  void _updateLandscape([final bool reset = false]) {
    SystemChrome.setPreferredOrientations(
      !reset && AppState.settings.current.fullscreenVideoPlayer
          ? <DeviceOrientation>[
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : <DeviceOrientation>[],
    );
  }

  Future<void> showSelectSources() async {
    final dynamic value = await showDialog(
      context: context,
      builder: (final BuildContext context) => Dialog(
        child: SelectSourceWidget(
          sources: widget.sources,
          selected: currentIndex != null ? widget.sources[currentIndex!] : null,
        ),
      ),
    );

    if (value is anime_model.EpisodeSource) {
      final int index = widget.sources.indexOf(value);
      if (index >= 0) {
        setPlayer(index);
      }
    }
  }

  void showOptions() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(remToPx(0.5)),
          topRight: Radius.circular(remToPx(0.5)),
        ),
      ),
      context: context,
      builder: (final BuildContext context) => StatefulBuilder(
        builder: (
          final BuildContext context,
          final StateSetter setState,
        ) =>
            Padding(
          padding: EdgeInsets.symmetric(vertical: remToPx(0.25)),
          child: SingleChildScrollView(
            child: Wrap(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SettingSwitch(
                      title: Translator.t.landscapeVideoPlayer(),
                      icon: Icons.screen_lock_landscape,
                      desc: Translator.t.landscapeVideoPlayerDetail(),
                      value: AppState.settings.current.fullscreenVideoPlayer,
                      onChanged: (final bool val) async {
                        AppState.settings.current.fullscreenVideoPlayer = val;
                        await AppState.settings.current.save();
                        _updateLandscape();
                        setState(() {});
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: volume,
                      builder: (
                        final BuildContext context,
                        int volume,
                        final Widget? child,
                      ) =>
                          SettingTile(
                        icon: Icons.volume_up,
                        title: Translator.t.volume(),
                        subtitle: '$volume%',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (final BuildContext context) =>
                                StatefulBuilder(
                              builder: (
                                final BuildContext context,
                                final StateSetter setState,
                              ) =>
                                  Dialog(
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: const Icon(Icons.volume_mute),
                                      onPressed: () {
                                        player?.setVolume(
                                          player_model.Player.minVolume,
                                        );
                                        volume = player_model.Player.minVolume;
                                        setState(() {});
                                      },
                                    ),
                                    Expanded(
                                      child: Wrap(
                                        children: <Widget>[
                                          SliderTheme(
                                            data: SliderThemeData(
                                              thumbShape: RoundSliderThumbShape(
                                                enabledThumbRadius:
                                                    remToPx(0.4),
                                              ),
                                              showValueIndicator:
                                                  ShowValueIndicator.always,
                                            ),
                                            child: Slider(
                                              label: '$volume%',
                                              value: volume.toDouble(),
                                              min: player_model.Player.minVolume
                                                  .toDouble(),
                                              max: player_model.Player.maxVolume
                                                  .toDouble(),
                                              onChanged: (final double value) {
                                                volume = value.toInt();
                                                setState(() {});
                                              },
                                              onChangeEnd:
                                                  (final double value) {
                                                player?.setVolume(
                                                  value.toInt(),
                                                );
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up),
                                      onPressed: () {
                                        player?.setVolume(
                                          player_model.Player.maxVolume,
                                        );
                                        volume = player_model.Player.maxVolume;
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SettingRadio<double>(
                      title: Translator.t.speed(),
                      icon: Icons.speed,
                      value: speed,
                      labels: <double, String>{
                        for (final double speed
                            in player_model.Player.allowedSpeeds)
                          speed: '${speed}x',
                      },
                      onChanged: (final double val) async {
                        await player?.setSpeed(val);
                        setState(() {
                          speed = val;
                        });
                      },
                    ),
                    SettingDialog(
                      title: Translator.t.skipIntroDuration(),
                      icon: Icons.fast_forward,
                      subtitle: '$introDuration ${Translator.t.seconds()}',
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
                              label: '$introDuration ${Translator.t.seconds()}',
                              value: introDuration.toDouble(),
                              min:
                                  player_model.Player.minIntroLength.toDouble(),
                              max:
                                  player_model.Player.maxIntroLength.toDouble(),
                              onChanged: (final double value) {
                                setState(() {
                                  introDuration = value.toInt();
                                });
                              },
                              onChangeEnd: (final double value) async {
                                setState(() {
                                  introDuration = value.toInt();
                                });
                                AppState.settings.current.introDuration =
                                    introDuration;
                                await AppState.settings.current.save();
                                this.setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SettingDialog(
                      title: Translator.t.seekDuration(),
                      icon: Icons.fast_forward,
                      subtitle: '$seekDuration ${Translator.t.seconds()}',
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
                              label: '$seekDuration ${Translator.t.seconds()}',
                              value: seekDuration.toDouble(),
                              min: player_model.Player.minSeekLength.toDouble(),
                              max: player_model.Player.maxSeekLength.toDouble(),
                              onChanged: (final double value) {
                                setState(() {
                                  seekDuration = value.toInt();
                                });
                              },
                              onChangeEnd: (final double value) async {
                                setState(() {
                                  seekDuration = value.toInt();
                                });
                                AppState.settings.current.seekDuration =
                                    seekDuration;
                                await AppState.settings.current.save();
                                this.setState(() {});
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
                      value: autoPlay,
                      onChanged: (final bool val) async {
                        setState(() {
                          autoPlay = val;
                        });
                        AppState.settings.current.autoPlay = val;
                        await AppState.settings.current.save();
                      },
                    ),
                    SettingSwitch(
                      title: Translator.t.autoNext(),
                      icon: Icons.skip_next,
                      desc: Translator.t.autoNextDetail(),
                      value: AppState.settings.current.autoNext,
                      onChanged: (final bool val) async {
                        setState(() {
                          autoNext = val;
                        });
                        AppState.settings.current.autoNext = val;
                        await AppState.settings.current.save();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget actionButton({
    required final IconData icon,
    required final String label,
    required final void Function() onPressed,
    required final bool enabled,
  }) =>
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: remToPx(0.2),
          ),
          side: BorderSide(
            color:
                Theme.of(context).textTheme.headline6!.color!.withOpacity(0.3),
          ),
          backgroundColor: Colors.black.withOpacity(0.5),
        ),
        onPressed: enabled ? onPressed : null,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: remToPx(0.4),
            vertical: remToPx(0.2),
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: Theme.of(context).textTheme.subtitle1?.fontSize,
                  color: Theme.of(context).textTheme.headline6?.color,
                ),
                SizedBox(
                  width: remToPx(0.2),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
                    color: Theme.of(context).textTheme.headline6?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget getLayoutedButton(
    final BuildContext context,
    final List<Widget> children,
    final int maxPerWhenSm,
  ) {
    final double width = MediaQuery.of(context).size.width;
    final Widget spacer = SizedBox(
      width: remToPx(0.4),
    );

    if (width < ResponsiveSizes.sm) {
      final List<List<Widget>> rows = ListUtils.chunk(children, maxPerWhenSm);

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: rows
            .map(
              (final List<Widget> x) => Flexible(
                child: Row(
                  children: ListUtils.insertBetween(x, spacer),
                ),
              ),
            )
            .toList(),
      );
    }

    return Row(
      children: ListUtils.insertBetween(children, spacer),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final Widget lock = IconButton(
      onPressed: () {
        setState(() {
          locked = !locked;
        });
      },
      icon: Icon(
        locked ? Icons.lock : Icons.lock_open,
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: <Widget>[
            if (playerChild != null) playerChild! else loader,
            FadeTransition(
              opacity: overlayController,
              child: showControls
                  ? Container(
                      color: !locked
                          ? Colors.black.withOpacity(0.3)
                          : Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: remToPx(0.7),
                        ),
                        child: Stack(
                          children: locked
                              ? <Widget>[
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: remToPx(0.5),
                                      ),
                                      child: lock,
                                    ),
                                  ),
                                ]
                              : <Widget>[
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: remToPx(0.5),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          IconButton(
                                            icon: const Icon(Icons.arrow_back),
                                            onPressed: widget.onPop,
                                            padding: EdgeInsets.only(
                                              right: remToPx(1),
                                              top: remToPx(0.5),
                                              bottom: remToPx(0.5),
                                            ),
                                          ),
                                          widget.title,
                                          lock,
                                          IconButton(
                                            onPressed: () {
                                              showOptions();
                                            },
                                            icon: const Icon(Icons.more_vert),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    child: playerChild != null
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              Material(
                                                type: MaterialType.transparency,
                                                shape: const CircleBorder(),
                                                clipBehavior: Clip.hardEdge,
                                                child: IconButton(
                                                  iconSize: remToPx(2),
                                                  onPressed: () {
                                                    if (player?.ready ??
                                                        false) {
                                                      final Duration amt =
                                                          duration.value
                                                                  .current -
                                                              Duration(
                                                                seconds:
                                                                    seekDuration,
                                                              );
                                                      player!.seek(
                                                        amt <= Duration.zero
                                                            ? Duration.zero
                                                            : amt,
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.fast_rewind,
                                                  ),
                                                ),
                                              ),
                                              ValueListenableBuilder<bool>(
                                                valueListenable: isPlaying,
                                                builder: (
                                                  final BuildContext context,
                                                  final bool isPlaying,
                                                  final Widget? child,
                                                ) {
                                                  isPlaying
                                                      ? playPauseController
                                                          .forward()
                                                      : playPauseController
                                                          .reverse();
                                                  return Material(
                                                    type: MaterialType
                                                        .transparency,
                                                    shape: const CircleBorder(),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: IconButton(
                                                      iconSize: remToPx(3),
                                                      onPressed: () {
                                                        if (player != null &&
                                                            player!.ready) {
                                                          isPlaying
                                                              ? player!.pause()
                                                              : player!.play();
                                                        }
                                                      },
                                                      icon: AnimatedIcon(
                                                        icon: AnimatedIcons
                                                            .play_pause,
                                                        progress:
                                                            playPauseController,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Material(
                                                type: MaterialType.transparency,
                                                shape: const CircleBorder(),
                                                clipBehavior: Clip.hardEdge,
                                                child: IconButton(
                                                  iconSize: remToPx(2),
                                                  onPressed: () {
                                                    if (player?.ready ??
                                                        false) {
                                                      final Duration amt =
                                                          duration.value
                                                                  .current +
                                                              Duration(
                                                                seconds:
                                                                    seekDuration,
                                                              );
                                                      player!.seek(
                                                        amt <
                                                                duration
                                                                    .value.total
                                                            ? amt
                                                            : duration
                                                                .value.total,
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.fast_forward,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Flexible(
                                          child: getLayoutedButton(
                                            context,
                                            <Widget>[
                                              Expanded(
                                                child: actionButton(
                                                  icon: Icons.skip_previous,
                                                  label:
                                                      Translator.t.previous(),
                                                  onPressed:
                                                      widget.previousEpisode,
                                                  enabled: widget
                                                      .previousEpisodeEnabled,
                                                ),
                                              ),
                                              Expanded(
                                                child: actionButton(
                                                  icon: Icons.fast_forward,
                                                  label:
                                                      Translator.t.skipIntro(),
                                                  onPressed: () {
                                                    if (player?.ready ??
                                                        false) {
                                                      final Duration amt =
                                                          duration.value
                                                                  .current +
                                                              Duration(
                                                                seconds:
                                                                    introDuration,
                                                              );
                                                      player!.seek(
                                                        amt <
                                                                duration
                                                                    .value.total
                                                            ? amt
                                                            : duration
                                                                .value.total,
                                                      );
                                                    }
                                                  },
                                                  enabled: playerChild != null,
                                                ),
                                              ),
                                              Expanded(
                                                child: actionButton(
                                                  icon: Icons.playlist_play,
                                                  label: Translator.t.sources(),
                                                  onPressed: showSelectSources,
                                                  enabled: true,
                                                ),
                                              ),
                                              Expanded(
                                                child: actionButton(
                                                  icon: Icons.skip_next,
                                                  label: Translator.t.next(),
                                                  onPressed: widget.nextEpisode,
                                                  enabled:
                                                      widget.nextEpisodeEnabled,
                                                ),
                                              ),
                                            ],
                                            2,
                                          ),
                                        ),
                                        if (playerChild != null)
                                          ValueListenableBuilder<VideoDuration>(
                                            valueListenable: duration,
                                            builder: (
                                              final BuildContext context,
                                              final VideoDuration duration,
                                              final Widget? child,
                                            ) =>
                                                Row(
                                              children: <Widget>[
                                                Container(
                                                  constraints: BoxConstraints(
                                                    minWidth: remToPx(1.8),
                                                  ),
                                                  child: Text(
                                                    DurationUtils.pretty(
                                                      duration.current,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: SliderTheme(
                                                    data: SliderThemeData(
                                                      thumbShape:
                                                          RoundSliderThumbShape(
                                                        enabledThumbRadius:
                                                            remToPx(0.3),
                                                      ),
                                                      showValueIndicator:
                                                          ShowValueIndicator
                                                              .always,
                                                    ),
                                                    child: Slider(
                                                      label:
                                                          DurationUtils.pretty(
                                                        duration.current,
                                                      ),
                                                      value: duration
                                                          .current.inSeconds
                                                          .toDouble(),
                                                      max: duration
                                                          .total.inSeconds
                                                          .toDouble(),
                                                      onChanged: (
                                                        final double value,
                                                      ) {
                                                        this.duration.value =
                                                            VideoDuration(
                                                          Duration(
                                                            seconds:
                                                                value.toInt(),
                                                          ),
                                                          duration.total,
                                                        );
                                                      },
                                                      onChangeStart: (
                                                        final double value,
                                                      ) {
                                                        if (player?.isPlaying ??
                                                            false) {
                                                          player!.pause();
                                                          wasPausedBySlider =
                                                              true;
                                                        }
                                                      },
                                                      onChangeEnd: (
                                                        final double value,
                                                      ) async {
                                                        if (player?.ready ??
                                                            false) {
                                                          await player!.seek(
                                                            Duration(
                                                              seconds:
                                                                  value.toInt(),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    minWidth: remToPx(1.8),
                                                  ),
                                                  child: Text(
                                                    DurationUtils.pretty(
                                                      duration.total,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        onTap: () {
          showControls
              ? overlayController.reverse()
              : overlayController.forward();
        },
      ),
    );
  }
}
