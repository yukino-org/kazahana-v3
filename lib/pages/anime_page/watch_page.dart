import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../core/models/player.dart' as player_model;
import '../../plugins/translator/translator.dart';
import '../../plugins/state.dart' show AppState;
import '../../components/player/player.dart';
import '../settings_page/setting_tile.dart';
import '../settings_page/setting_switch.dart';
import '../settings_page/setting_dialog.dart';

class VideoDuration {
  final Duration current;
  final Duration total;

  VideoDuration(this.current, this.total);
}

class WatchPage extends StatefulWidget {
  final int? initialIndex;
  final List<anime_model.EpisodeSource> sources;
  final Widget title;
  final void Function() onPop;
  final bool previousEpisodeEnabled;
  final void Function() previousEpisode;
  final bool nextEpisodeEnabled;
  final void Function() nextEpisode;

  const WatchPage({
    Key? key,
    required this.sources,
    this.initialIndex,
    required this.title,
    required this.onPop,
    required this.previousEpisodeEnabled,
    required this.previousEpisode,
    required this.nextEpisodeEnabled,
    required this.nextEpisode,
  }) : super(key: key);

  @override
  WatchPageState createState() => WatchPageState();
}

class WatchPageState extends State<WatchPage> with TickerProviderStateMixin {
  late int currentIndex;
  player_model.Player? player;
  Widget? playerChild;

  bool showControls = true;
  bool autoPlay = AppState.settings.current.autoPlay;
  bool autoNext = AppState.settings.current.autoNext;
  bool? wasPausedBySlider;
  int seekDuration = AppState.settings.current.seekDuration;
  int introDuration = AppState.settings.current.introDuration;
  final animationDuration = const Duration(milliseconds: 300);

  final isPlaying = ValueNotifier<bool>(false);
  late AnimationController playPauseController;
  late AnimationController overlayController;

  late final duration = ValueNotifier<VideoDuration>(
    VideoDuration(Duration.zero, Duration.zero),
  );
  late final volume = ValueNotifier<int>(
    100,
  );

  final loader = const Center(
    child: CircularProgressIndicator(),
  );

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex ?? 0;
    Future.delayed(Duration.zero, () {
      setPlayer(currentIndex);
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

    overlayController.addStatusListener((status) {
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
    if (player != null) {
      playerChild = null;
      player!.destroy();
    }

    _updateLandscape(true);

    super.dispose();
  }

  Future<void> setPlayer(int index) async {
    if (player != null) {
      playerChild = null;
      player!.destroy();
    }

    isPlaying.value = false;
    setState(() {
      currentIndex = index;
    });

    player = createPlayer(
      player_model.PlayerSource(
        url: widget.sources[currentIndex].url,
        headers: widget.sources[currentIndex].headers,
      ),
    )..subscribe(_subscriber);

    await player!.initialize();
  }

  void _subscriber(player_model.PlayerEvents event) {
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
    }
  }

  void _updateDuration() {
    duration.value = VideoDuration(
      player?.duration ?? Duration.zero,
      player?.totalDuration ?? Duration.zero,
    );
  }

  void _updateLandscape([bool reset = false]) {
    SystemChrome.setPreferredOrientations(
      !reset && AppState.settings.current.fullscreenVideoPlayer
          ? [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : [],
    );
  }

  void showOptions() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(utils.remToPx(0.5)),
          topRight: Radius.circular(utils.remToPx(0.5)),
        ),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: utils.remToPx(0.25)),
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    Column(
                      children: [
                        SettingSwitch(
                          title: Translator.t.landscapeVideoPlayer(),
                          icon: Icons.screen_lock_landscape,
                          desc: Translator.t.landscapeVideoPlayerDetail(),
                          value:
                              AppState.settings.current.fullscreenVideoPlayer,
                          onChanged: (val) async {
                            AppState.settings.current.fullscreenVideoPlayer =
                                val;
                            await AppState.settings.current.save();
                            _updateLandscape();
                            setState(() {});
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: volume,
                          builder: (context, int volume, child) {
                            return SettingTile(
                              icon: Icons.volume_up,
                              title: Translator.t.volume(),
                              subtitle: '$volume%',
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Dialog(
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.volume_mute),
                                                onPressed: () {
                                                  player?.setVolume(
                                                    player_model
                                                        .Player.minVolume,
                                                  );
                                                  volume = player_model
                                                      .Player.minVolume;
                                                  setState(() {});
                                                },
                                              ),
                                              Expanded(
                                                child: Wrap(
                                                  direction: Axis.horizontal,
                                                  children: [
                                                    SliderTheme(
                                                      data: SliderThemeData(
                                                        thumbShape:
                                                            RoundSliderThumbShape(
                                                          enabledThumbRadius:
                                                              utils
                                                                  .remToPx(0.4),
                                                        ),
                                                        showValueIndicator:
                                                            ShowValueIndicator
                                                                .always,
                                                      ),
                                                      child: Slider(
                                                        label: '$volume%',
                                                        value:
                                                            volume.toDouble(),
                                                        min: player_model
                                                            .Player.minVolume
                                                            .toDouble(),
                                                        max: player_model
                                                            .Player.maxVolume
                                                            .toDouble(),
                                                        onChanged: (value) {
                                                          volume =
                                                              value.toInt();
                                                          setState(() {});
                                                        },
                                                        onChangeEnd: (value) {
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
                                                icon:
                                                    const Icon(Icons.volume_up),
                                                onPressed: () {
                                                  player?.setVolume(
                                                    player_model
                                                        .Player.maxVolume,
                                                  );
                                                  volume = player_model
                                                      .Player.maxVolume;
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        SettingDialog(
                          title: Translator.t.skipIntroDuration(),
                          icon: Icons.fast_forward,
                          subtitle: '$introDuration ${Translator.t.seconds()}',
                          builder: (context, setState) {
                            return Wrap(
                              direction: Axis.horizontal,
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: utils.remToPx(0.4),
                                    ),
                                    showValueIndicator:
                                        ShowValueIndicator.always,
                                  ),
                                  child: Slider(
                                    label:
                                        '$introDuration ${Translator.t.seconds()}',
                                    value: introDuration.toDouble(),
                                    min: player_model.Player.minIntroLength
                                        .toDouble(),
                                    max: player_model.Player.maxIntroLength
                                        .toDouble(),
                                    onChanged: (value) {
                                      setState(() {
                                        introDuration = value.toInt();
                                      });
                                    },
                                    onChangeEnd: (value) async {
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
                            );
                          },
                        ),
                        SettingDialog(
                          title: Translator.t.seekDuration(),
                          icon: Icons.fast_forward,
                          subtitle: '$seekDuration ${Translator.t.seconds()}',
                          builder: (context, setState) {
                            return Wrap(
                              direction: Axis.horizontal,
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: utils.remToPx(0.4),
                                    ),
                                    showValueIndicator:
                                        ShowValueIndicator.always,
                                  ),
                                  child: Slider(
                                    label:
                                        '$seekDuration ${Translator.t.seconds()}',
                                    value: seekDuration.toDouble(),
                                    min: player_model.Player.minSeekLength
                                        .toDouble(),
                                    max: player_model.Player.maxSeekLength
                                        .toDouble(),
                                    onChanged: (value) {
                                      setState(() {
                                        seekDuration = value.toInt();
                                      });
                                    },
                                    onChangeEnd: (value) async {
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
                            );
                          },
                        ),
                        SettingSwitch(
                          title: Translator.t.autoPlay(),
                          icon: Icons.slideshow,
                          desc: Translator.t.autoPlayDetail(),
                          value: autoPlay,
                          onChanged: (val) async {
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
                          onChanged: (val) async {
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
            );
          },
        );
      },
    );
  }

  Widget actionButton({
    required IconData icon,
    required String label,
    required void Function() onPressed,
    required bool enabled,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: utils.remToPx(0.2),
        ),
        side: BorderSide(
          width: 1,
          color: Theme.of(context).textTheme.headline6!.color!.withOpacity(0.3),
        ),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: utils.remToPx(0.4),
          vertical: utils.remToPx(0.2),
        ),
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: Theme.of(context).textTheme.subtitle1?.fontSize,
                color: Theme.of(context).textTheme.headline6?.color,
              ),
              SizedBox(
                width: utils.remToPx(0.2),
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
      onPressed: enabled ? onPressed : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            playerChild != null ? playerChild! : loader,
            FadeTransition(
              opacity: overlayController,
              child: showControls
                  ? Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: utils.remToPx(0.7),
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: utils.remToPx(0.5),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: widget.onPop,
                                      padding: EdgeInsets.only(
                                        right: utils.remToPx(1),
                                        top: utils.remToPx(0.5),
                                        bottom: utils.remToPx(0.5),
                                      ),
                                    ),
                                    widget.title,
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
                              alignment: Alignment.center,
                              child: playerChild != null
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Material(
                                          type: MaterialType.transparency,
                                          shape: const CircleBorder(),
                                          clipBehavior: Clip.hardEdge,
                                          child: IconButton(
                                            iconSize: utils.remToPx(2),
                                            onPressed: () {
                                              if (player?.ready ?? false) {
                                                final amt =
                                                    duration.value.current -
                                                        Duration(
                                                          seconds: seekDuration,
                                                        );
                                                player!.seek(
                                                  amt <= Duration.zero
                                                      ? Duration.zero
                                                      : amt,
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.fast_rewind),
                                          ),
                                        ),
                                        ValueListenableBuilder(
                                          valueListenable: isPlaying,
                                          builder:
                                              (context, bool isPlaying, child) {
                                            isPlaying
                                                ? playPauseController.forward()
                                                : playPauseController.reverse();
                                            return Material(
                                              type: MaterialType.transparency,
                                              shape: const CircleBorder(),
                                              clipBehavior: Clip.hardEdge,
                                              child: IconButton(
                                                iconSize: utils.remToPx(3),
                                                onPressed: () {
                                                  if (player != null &&
                                                      player!.ready) {
                                                    player!.isPlaying
                                                        ? player!.pause()
                                                        : player!.play();
                                                  }
                                                },
                                                icon: AnimatedIcon(
                                                  icon:
                                                      AnimatedIcons.play_pause,
                                                  progress: playPauseController,
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
                                            iconSize: utils.remToPx(2),
                                            onPressed: () {
                                              if (player?.ready ?? false) {
                                                final amt =
                                                    duration.value.current +
                                                        Duration(
                                                          seconds: seekDuration,
                                                        );
                                                player!.seek(
                                                  amt < duration.value.total
                                                      ? amt
                                                      : duration.value.total,
                                                );
                                              }
                                            },
                                            icon:
                                                const Icon(Icons.fast_forward),
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
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: actionButton(
                                          icon: Icons.skip_previous,
                                          label: Translator.t.previous(),
                                          onPressed: widget.previousEpisode,
                                          enabled:
                                              widget.previousEpisodeEnabled,
                                        ),
                                      ),
                                      SizedBox(
                                        width: utils.remToPx(0.4),
                                      ),
                                      Expanded(
                                        child: actionButton(
                                          icon: Icons.fast_forward,
                                          label: Translator.t.skipIntro(),
                                          onPressed: () {
                                            if (player?.ready ?? false) {
                                              final amt =
                                                  duration.value.current +
                                                      Duration(
                                                        seconds: introDuration,
                                                      );
                                              player!.seek(
                                                amt < duration.value.total
                                                    ? amt
                                                    : duration.value.total,
                                              );
                                            }
                                          },
                                          enabled: playerChild != null,
                                        ),
                                      ),
                                      SizedBox(
                                        width: utils.remToPx(0.4),
                                      ),
                                      Expanded(
                                        child: actionButton(
                                          icon: Icons.skip_next,
                                          label: Translator.t.next(),
                                          onPressed: widget.nextEpisode,
                                          enabled: widget.nextEpisodeEnabled,
                                        ),
                                      ),
                                    ],
                                  ),
                                  playerChild != null
                                      ? ValueListenableBuilder(
                                          valueListenable: duration,
                                          builder: (
                                            context,
                                            VideoDuration duration,
                                            child,
                                          ) {
                                            return Row(
                                              children: [
                                                Container(
                                                  constraints: BoxConstraints(
                                                    minWidth:
                                                        utils.remToPx(1.8),
                                                  ),
                                                  child: Text(
                                                    utils.Fns
                                                        .prettyShortDuration(
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
                                                            utils.remToPx(0.3),
                                                      ),
                                                      showValueIndicator:
                                                          ShowValueIndicator
                                                              .always,
                                                    ),
                                                    child: Slider(
                                                      label: utils.Fns
                                                          .prettyShortDuration(
                                                        duration.current,
                                                      ),
                                                      value: duration
                                                          .current.inSeconds
                                                          .toDouble(),
                                                      min: 0,
                                                      max: duration
                                                          .total.inSeconds
                                                          .toDouble(),
                                                      onChanged: (value) {
                                                        this.duration.value =
                                                            VideoDuration(
                                                          Duration(
                                                            seconds:
                                                                value.toInt(),
                                                          ),
                                                          duration.total,
                                                        );
                                                      },
                                                      onChangeStart: (value) {
                                                        if (player?.isPlaying ??
                                                            false) {
                                                          player!.pause();
                                                          wasPausedBySlider =
                                                              true;
                                                        }
                                                      },
                                                      onChangeEnd:
                                                          (value) async {
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
                                                    minWidth:
                                                        utils.remToPx(1.8),
                                                  ),
                                                  child: Text(
                                                    utils.Fns
                                                        .prettyShortDuration(
                                                      duration.total,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                      : const SizedBox.shrink(),
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
