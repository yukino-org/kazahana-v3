import 'dart:async';
import 'package:extensions/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './select_source.dart';
import './shared_props.dart';
import '../../../config/defaults.dart';
import '../../../modules/app/state.dart';
import '../../../modules/database/database.dart';
import '../../../modules/helpers/keyboard.dart';
import '../../../modules/helpers/screen.dart';
import '../../../modules/helpers/ui.dart';
import '../../../modules/schemas/settings/anime_keyboard_shortcuts.dart';
import '../../../modules/state/hooks.dart';
import '../../../modules/state/reactive_holder.dart';
import '../../../modules/trackers/provider.dart';
import '../../../modules/trackers/trackers.dart';
import '../../../modules/translator/translator.dart';
import '../../../modules/utils/utils.dart';
import '../../../modules/video_player/video_player.dart';
import '../../components/material_tiles/radio.dart';
import '../settings_page/setting_labels/anime.dart';

class _VideoDuration {
  _VideoDuration(this.current, this.total);

  final Duration current;
  final Duration total;
}

class _VideoStateProps {
  bool isReady = false;
  bool isBuffering = false;
  bool isPlaying = false;
  int volume = VideoPlayer.maxVolume;
  double speed = VideoPlayer.defaultSpeed;

  VideoPlayer? videoPlayer;
  List<EpisodeSource>? sources;
  int? currentIndex;
  bool ignoreScreenChanges = false;
  bool locked = false;
  Widget? message;

  final ValueNotifier<_VideoDuration> duration = ValueNotifier<_VideoDuration>(
    _VideoDuration(Duration.zero, Duration.zero),
  );

  void dispose() {
    videoPlayer?.destroy();
    duration.dispose();
  }
}

enum _SeekType {
  forward,
  backward,
  intro,
}

class WatchPage extends StatefulWidget {
  const WatchPage({
    required final this.props,
    required final this.pop,
    final Key? key,
  }) : super(key: key);

  final SharedProps props;
  final void Function() pop;

  @override
  WatchPageState createState() => WatchPageState();
}

class WatchPageState extends State<WatchPage>
    with FullscreenMixin, HooksMixin, OrientationMixin, WakelockMixin {
  final ReactiveHolder<_VideoStateProps> videoState =
      ReactiveHolder<_VideoStateProps>(_VideoStateProps());

  final FocusNode keyBoardFocusNode = FocusNode();
  late final KeyboardHandler keyboardHandler;

  Timer? _mouseOverlayTimer;
  bool hasSynced = false;
  bool showControls = true;
  Widget? playerChild;

  @override
  void initState() {
    super.initState();

    initFullscreen();

    final AnimeKeyboardShortcuts shortcuts =
        AppState.settings.value.animeShortcuts;

    keyboardHandler = KeyboardHandler(
      onKeyDown: <KeyboardKeyHandler>[
        KeyboardKeyHandler(
          shortcuts.fullscreen,
          (final RawKeyEvent event) async {
            await setFullscreen(
              enabled: !AppState.settings.value.animeAutoFullscreen,
            );
          },
        ),
        KeyboardKeyHandler(
          shortcuts.playPause,
          (final RawKeyEvent event) async {
            if (videoState.value.isReady) {
              await (videoState.value.videoPlayer!.isPlaying
                  ? videoState.value.videoPlayer!.pause()
                  : videoState.value.videoPlayer!.play());
            }
          },
        ),
        KeyboardKeyHandler(
          shortcuts.seekBackward,
          (final RawKeyEvent event) async {
            await seek(_SeekType.backward);
          },
        ),
        KeyboardKeyHandler(
          shortcuts.seekForward,
          (final RawKeyEvent event) async {
            await seek(_SeekType.forward);
          },
        ),
        KeyboardKeyHandler(
          shortcuts.skipIntro,
          (final RawKeyEvent event) async {
            await seek(_SeekType.intro);
          },
        ),
        KeyboardKeyHandler(
          shortcuts.exit,
          (final RawKeyEvent event) async {
            pop();
          },
        ),
        KeyboardKeyHandler(
          shortcuts.previousEpisode,
          (final RawKeyEvent event) async {
            if (previousEpisodeAvailable) {
              previousEpisode();
            }
          },
        ),
        KeyboardKeyHandler(
          shortcuts.nextEpisode,
          (final RawKeyEvent event) async {
            if (nextEpisodeAvailable) {
              nextEpisode();
            }
          },
        ),
      ],
    );

    onReady(() async {
      if (mounted) {
        isWakelockEnabled().then((final bool isWakelockEnabled) {
          if (mounted && !isWakelockEnabled) {
            enableWakelock();
          }
        });

        if (AppState.settings.value.animeAutoFullscreen) {
          enterFullscreen();
        }

        if (AppState.settings.value.animeForceLandscape) {
          enterLandscape();
        }

        await getSources();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hookState.markReady();
  }

  @override
  void dispose() {
    if (!videoState.value.ignoreScreenChanges) {
      disableWakelock();
      exitLandscape();
      exitFullscreen();
    }

    playerChild = null;
    videoState.value.dispose();
    keyBoardFocusNode.dispose();
    _mouseOverlayTimer?.cancel();

    super.dispose();
  }

  Future<void> getSources() async {
    videoState.value.sources =
        await widget.props.extractor!.getSources(widget.props.episode!);

    if (mounted) {
      setState(() {});

      if (videoState.value.sources!.isNotEmpty) {
        await showSelectSources();
      }
    }
  }

  Future<void> setPlayer(final int index) async {
    if (mounted) {
      setState(() {
        videoState.value.currentIndex = index;
        playerChild = null;
      });

      videoState.value.isPlaying = false;
      videoState.value.videoPlayer?.destroy();

      videoState.value.videoPlayer = VideoPlayerManager.createPlayer(
        VideoPlayerSource(
          url: videoState.value.sources![videoState.value.currentIndex!].url,
          headers:
              videoState.value.sources![videoState.value.currentIndex!].headers,
        ),
      )..subscribe(_videoPlayerSubscriber);

      await videoState.value.videoPlayer!.load();
    }
  }

  void _videoPlayerSubscriber(final VideoPlayerEvent event) {
    if (mounted) {
      switch (event.event) {
        case VideoPlayerEvents.load:
          videoState.value.isReady = true;

          videoState.value.videoPlayer!.setVolume(videoState.value.volume);
          setState(() {
            playerChild = videoState.value.videoPlayer!.getWidget();
          });

          _updateDuration();

          if (AppState.settings.value.autoPlay) {
            videoState.value.videoPlayer!.play();
            setState(() {
              showControls = false;
            });
          }

          break;

        case VideoPlayerEvents.durationUpdate:
          _updateDuration();
          break;

        case VideoPlayerEvents.play:
          videoState.modify(() {
            videoState.value.isPlaying = true;
          });
          break;

        case VideoPlayerEvents.pause:
          videoState.modify(() {
            videoState.value.isPlaying = false;
          });
          break;

        case VideoPlayerEvents.seek:
          break;

        case VideoPlayerEvents.volume:
          videoState.value.volume = videoState.value.videoPlayer!.volume;
          break;

        case VideoPlayerEvents.end:
          if (AppState.settings.value.autoNext) {
            if (nextEpisodeAvailable) {
              videoState.value.ignoreScreenChanges = true;
              nextEpisode();
            }
          }
          break;

        case VideoPlayerEvents.speed:
          videoState.value.speed = videoState.value.videoPlayer!.speed;
          break;

        case VideoPlayerEvents.buffering:
          videoState.modify(() {
            videoState.value.isBuffering =
                videoState.value.videoPlayer!.isBuffering;
          });
          break;

        case VideoPlayerEvents.error:
          setState(() {
            videoState.value.message = RichText(
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: '${Translator.t.somethingWentWrong()}\n'),
                  TextSpan(
                    text: event.data as String,
                    style: FunctionUtils.withValue(
                      Theme.of(context).textTheme.bodyText1,
                      (final TextStyle? style) => style?.copyWith(
                        color: style.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
                style: Theme.of(context).textTheme.bodyText1,
              ),
              textAlign: TextAlign.center,
            );
          });
          break;
      }
    }
  }

  Future<void> _updateDuration() async {
    videoState.value.duration.value = _VideoDuration(
      videoState.value.videoPlayer?.duration ?? Duration.zero,
      videoState.value.videoPlayer?.totalDuration ?? Duration.zero,
    );

    if ((videoState.value.duration.value.current.inSeconds /
                videoState.value.duration.value.total.inSeconds) *
            100 >
        AppState.settings.value.animeTrackerWatchPercent) {
      final int? episode = int.tryParse(widget.props.episode!.episode);

      if (episode != null && !hasSynced) {
        hasSynced = true;

        final AnimeProgress progress = AnimeProgress(episodes: episode);

        for (final TrackerProvider<AnimeProgress> provider in Trackers.anime) {
          if (provider.isLoggedIn() &&
              provider.isEnabled(
                widget.props.info!.title,
                widget.props.extractor!.id,
              )) {
            final ResolvedTrackerItem? item = await provider.getComputed(
              widget.props.info!.title,
              widget.props.extractor!.id,
            );

            if (item != null) {
              await provider.updateComputed(
                item,
                progress,
              );
            }
          }
        }
      }
    }
  }

  void pop() {
    exitFullscreen();
    widget.pop();
  }

  Future<void> showSelectSources() async {
    final dynamic value = await showGeneralDialog(
      context: context,
      barrierDismissible: videoState.value.currentIndex != null,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (
        final BuildContext context,
        final Animation<double> a1,
        final Animation<double> a2,
      ) =>
          SafeArea(
        child: SelectSourceWidget(
          sources: videoState.value.sources!,
          selected: videoState.value.currentIndex != null
              ? videoState.value.sources![videoState.value.currentIndex!]
              : null,
        ),
      ),
    );

    if (value is EpisodeSource) {
      final int index = videoState.value.sources!.indexOf(value);
      if (index >= 0) {
        setPlayer(index);
      }
    } else if (videoState.value.currentIndex == null) {
      pop();
    }
  }

  /// [kind] can be 1 (move) or 2 (tap)
  void _updateOverlayMovement(final int kind) {
    switch (kind) {
      case 1:
        if (videoState.value.isPlaying) {
          if (!showControls) {
            setState(() {
              showControls = true;
            });
          }

          _mouseOverlayTimer?.cancel();
          _mouseOverlayTimer = Timer(Defaults.mouseOverlayDuration, () {
            setState(() {
              showControls = false;
            });
          });
        }
        break;

      case 2:
        _mouseOverlayTimer?.cancel();
        setState(() {
          showControls = !showControls;
        });
        break;

      default:
    }
  }

  @override
  Widget build(final BuildContext context) => RawKeyboardListener(
        focusNode: keyBoardFocusNode,
        autofocus: true,
        onKey: (final RawKeyEvent event) =>
            keyboardHandler.onRawKeyEvent(event),
        child: Material(
          type: MaterialType.transparency,
          child: MouseRegion(
            onEnter: (final PointerEnterEvent event) {
              _updateOverlayMovement(1);
            },
            onHover: (final PointerHoverEvent event) {
              if (event.kind == PointerDeviceKind.mouse &&
                  event.delta.distance > 1) {
                _updateOverlayMovement(1);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _updateOverlayMovement(2);
              },
              child: Stack(
                children: <Widget>[
                  if (playerChild != null) playerChild!,
                  AnimatedSwitcher(
                    duration: Defaults.animationsNormal,
                    child: !videoState.value.isReady || showControls
                        ? _VideoControls(
                            props: widget.props,
                            videoState: videoState,
                            previousEpisodeAvailable: previousEpisodeAvailable,
                            nextEpisodeAvailable: nextEpisodeAvailable,
                            previousEpisode: previousEpisode,
                            nextEpisode: nextEpisode,
                            pop: pop,
                            setFullscreen: setFullscreen,
                            seek: seek,
                            enableLandscape: enterLandscape,
                            disableLandscape: exitLandscape,
                            showSelectSources: showSelectSources,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> setFullscreen({
    required final bool enabled,
  }) async {
    AppState.settings.value.animeAutoFullscreen = enabled;

    await (AppState.settings.value.animeAutoFullscreen
        ? enterFullscreen()
        : exitFullscreen());

    await SettingsBox.save(AppState.settings.value);
  }

  Future<void> seek(final _SeekType type) async {
    if (videoState.value.isReady) {
      switch (type) {
        case _SeekType.forward:
          final Duration amt = videoState.value.duration.value.current +
              Duration(
                seconds: AppState.settings.value.seekDuration,
              );

          await videoState.value.videoPlayer!.seek(
            amt < videoState.value.duration.value.total
                ? amt
                : videoState.value.duration.value.total,
          );
          break;

        case _SeekType.backward:
          final Duration amt = videoState.value.duration.value.current -
              Duration(
                seconds: AppState.settings.value.seekDuration,
              );
          await videoState.value.videoPlayer!.seek(
            amt <= Duration.zero ? Duration.zero : amt,
          );

          break;

        case _SeekType.intro:
          final Duration amt = videoState.value.duration.value.current +
              Duration(
                seconds: AppState.settings.value.introDuration,
              );

          await videoState.value.videoPlayer!.seek(
            amt < videoState.value.duration.value.total
                ? amt
                : videoState.value.duration.value.total,
          );
          break;
      }
    }
  }

  void previousEpisode() {
    if (previousEpisodeAvailable) {
      widget.props.setEpisode(widget.props.currentEpisodeIndex! - 1);
    }
  }

  void nextEpisode() {
    if (nextEpisodeAvailable) {
      widget.props.setEpisode(widget.props.currentEpisodeIndex! + 1);
    }
  }

  bool get previousEpisodeAvailable =>
      widget.props.currentEpisodeIndex! - 1 >= 0;

  bool get nextEpisodeAvailable =>
      widget.props.currentEpisodeIndex! + 1 <
      widget.props.info!.episodes.length;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required final this.icon,
    required final this.label,
    required final this.onPressed,
    required final this.enabled,
    final Key? key,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final void Function() onPressed;
  final bool enabled;

  @override
  Widget build(final BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: remToPx(0.2),
          ),
          side: BorderSide(
            color: Colors.white.withOpacity(0.3),
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
                  color: Colors.white,
                ),
                SizedBox(
                  width: remToPx(0.2),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _VideoControls extends StatefulWidget {
  const _VideoControls({
    required final this.props,
    required final this.videoState,
    required final this.previousEpisodeAvailable,
    required final this.nextEpisodeAvailable,
    required final this.setFullscreen,
    required final this.seek,
    required final this.enableLandscape,
    required final this.disableLandscape,
    required final this.previousEpisode,
    required final this.nextEpisode,
    required final this.pop,
    required final this.showSelectSources,
    final Key? key,
  }) : super(key: key);

  final SharedProps props;
  final ReactiveHolder<_VideoStateProps> videoState;

  final bool previousEpisodeAvailable;
  final bool nextEpisodeAvailable;

  final Future<void> Function({
    required bool enabled,
  }) setFullscreen;
  final Future<void> Function(_SeekType type) seek;
  final void Function() enableLandscape;
  final void Function() disableLandscape;
  final void Function() previousEpisode;
  final void Function() nextEpisode;
  final void Function() pop;
  final void Function() showSelectSources;

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls>
    with SingleTickerProviderStateMixin {
  bool wasPausedBySlider = false;

  late final AnimationController playPauseController;

  @override
  void initState() {
    super.initState();

    playPauseController = AnimationController(
      vsync: this,
      duration: Defaults.animationsSlower,
      value: widget.videoState.value.isPlaying ? 1 : 0,
    );
  }

  @override
  void dispose() {
    playPauseController.dispose();

    super.dispose();
  }

  Widget buildLock(final BuildContext context) => Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(remToPx(0.2)),
        child: IconButton(
          onPressed: () {
            setState(() {
              widget.videoState.value.locked = !widget.videoState.value.locked;
            });
          },
          icon: Icon(
            widget.videoState.value.locked ? Icons.lock : Icons.lock_open,
          ),
          color: Colors.white,
        ),
      );

  Future<void> showOptions() async {
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(remToPx(0.5)),
          topRight: Radius.circular(remToPx(0.5)),
        ),
      ),
      context: context,
      builder: (final BuildContext context) => SafeArea(
        child: StatefulBuilder(
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
                      RadioMaterialTile<double>(
                        title: Text(Translator.t.speed()),
                        icon: const Icon(Icons.speed),
                        value: widget.videoState.value.speed,
                        labels: VideoPlayer.allowedSpeeds.asMap().map(
                              (final int k, final double v) =>
                                  MapEntry<double, String>(v, '${v}x'),
                            ),
                        onChanged: (final double val) async {
                          await widget.videoState.value.videoPlayer
                              ?.setSpeed(val);

                          if (mounted) {
                            setState(() {
                              widget.videoState.value.speed = val;
                            });
                          }
                        },
                      ),
                      ...getSettingsAnime(
                        context,
                        AppState.settings.value,
                        () async {
                          await SettingsBox.save(AppState.settings.value);

                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLayoutedButton(
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

  Widget buildTopBar(final BuildContext context) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            top: remToPx(0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                ),
                tooltip: Translator.t.back(),
                onPressed: widget.pop,
                padding: EdgeInsets.only(
                  right: remToPx(1),
                  top: remToPx(0.5),
                  bottom: remToPx(0.5),
                ),
                color: Colors.white,
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.props.info!.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline6?.fontSize,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${Translator.t.episode()} ${widget.props.episode!.episode} ${Translator.t.of()} ${widget.props.info!.episodes.length}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              buildLock(context),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showOptions();
                },
                color: Colors.white,
              ),
            ],
          ),
        ),
      );

  Widget buildMiddleBar(final BuildContext context) {
    if (widget.videoState.value.sources?.isEmpty ?? false) {
      return Text(
        Translator.t.noValidSources(),
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.subtitle1?.fontSize,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      );
    }

    if (widget.videoState.value.message != null) {
      return widget.videoState.value.message!;
    }

    if (widget.videoState.value.isReady &&
        !widget.videoState.value.isBuffering) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              iconSize: remToPx(2),
              onPressed: () async {
                await widget.seek(_SeekType.backward);
              },
              icon: const Icon(
                Icons.fast_rewind,
              ),
              color: Colors.white,
            ),
          ),
          Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              iconSize: remToPx(3),
              onPressed: () {
                widget.videoState.value.isPlaying
                    ? widget.videoState.value.videoPlayer!.pause()
                    : widget.videoState.value.videoPlayer!.play();
              },
              icon: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: playPauseController,
              ),
              color: Colors.white,
            ),
          ),
          Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              iconSize: remToPx(2),
              onPressed: () async {
                await widget.seek(_SeekType.forward);
              },
              icon: const Icon(
                Icons.fast_forward,
              ),
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    return const CircularProgressIndicator();
  }

  Widget buildBottomBar(final BuildContext context) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: buildLayoutedButton(
                context,
                <Widget>[
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.skip_previous,
                      label: Translator.t.previous(),
                      onPressed: () {
                        widget.videoState.value.ignoreScreenChanges = true;
                        widget.previousEpisode();
                      },
                      enabled: widget.previousEpisodeAvailable,
                    ),
                  ),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.fast_forward,
                      label: Translator.t.skipIntro(),
                      onPressed: () async {
                        await widget.seek(_SeekType.intro);
                      },
                      enabled: widget.videoState.value.isReady,
                    ),
                  ),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.playlist_play,
                      label: Translator.t.sources(),
                      onPressed: widget.showSelectSources,
                      enabled:
                          widget.videoState.value.sources?.isNotEmpty ?? false,
                    ),
                  ),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.skip_next,
                      label: Translator.t.next(),
                      onPressed: () {
                        widget.videoState.value.ignoreScreenChanges = true;
                        widget.nextEpisode();
                      },
                      enabled: widget.nextEpisodeAvailable,
                    ),
                  ),
                ],
                2,
              ),
            ),
            ValueListenableBuilder<_VideoDuration>(
              valueListenable: widget.videoState.value.duration,
              builder: (
                final BuildContext context,
                final _VideoDuration duration,
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
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: remToPx(0.3),
                        ),
                        showValueIndicator: ShowValueIndicator.always,
                        thumbColor: !widget.videoState.value.isReady
                            ? Colors.white.withOpacity(
                                0.5,
                              )
                            : null,
                      ),
                      child: Slider(
                        label: DurationUtils.pretty(
                          duration.current,
                        ),
                        value: duration.current.inSeconds.toDouble(),
                        max: duration.total.inSeconds.toDouble(),
                        onChanged: widget.videoState.value.isReady
                            ? (
                                final double value,
                              ) {
                                widget.videoState.value.duration.value =
                                    _VideoDuration(
                                  Duration(
                                    seconds: value.toInt(),
                                  ),
                                  duration.total,
                                );
                              }
                            : null,
                        onChangeStart: widget.videoState.value.isReady
                            ? (
                                final double value,
                              ) async {
                                if (widget.videoState.value.isPlaying) {
                                  await widget.videoState.value.videoPlayer!
                                      .pause();

                                  wasPausedBySlider = true;
                                }
                              }
                            : null,
                        onChangeEnd: widget.videoState.value.isReady
                            ? (
                                final double value,
                              ) async {
                                await widget.videoState.value.videoPlayer!.seek(
                                  Duration(
                                    seconds: value.toInt(),
                                  ),
                                );

                                if (wasPausedBySlider) {
                                  await widget.videoState.value.videoPlayer!
                                      .play();

                                  wasPausedBySlider = false;
                                }
                              }
                            : null,
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
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: remToPx(0.5),
                  ),
                  if (AppState.isMobile) ...<Widget>[
                    StatefulBuilder(
                      builder: (
                        final BuildContext context,
                        final StateSetter setState,
                      ) =>
                          Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            remToPx(0.2),
                          ),
                          onTap: () async {
                            AppState.settings.value.animeForceLandscape =
                                !AppState.settings.value.animeForceLandscape;

                            AppState.settings.value.animeForceLandscape
                                ? widget.enableLandscape()
                                : widget.disableLandscape();

                            await SettingsBox.save(AppState.settings.value);

                            if (mounted) {
                              setState(() {});
                            }
                          },
                          child: Icon(
                            Icons.screen_rotation,
                            size: Theme.of(
                              context,
                            ).textTheme.headline6?.fontSize,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: remToPx(0.7),
                    ),
                  ],
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(remToPx(0.2)),
                      onTap: () async {
                        await widget.setFullscreen(
                          enabled: !AppState.settings.value.animeAutoFullscreen,
                        );
                      },
                      child: Icon(
                        AppState.settings.value.animeAutoFullscreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );

  @override
  Widget build(final BuildContext context) =>
      ValueListenableBuilder<_VideoStateProps>(
        valueListenable: widget.videoState,
        builder: (
          final BuildContext context,
          final _VideoStateProps videoState,
          final Widget? child,
        ) {
          widget.videoState.value.isPlaying
              ? playPauseController.forward()
              : playPauseController.reverse();

          return Container(
            color: !widget.videoState.value.locked
                ? Colors.black.withOpacity(0.3)
                : Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: remToPx(0.7),
              ),
              child: Column(
                children: widget.videoState.value.locked
                    ? <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: remToPx(0.5),
                            ),
                            child: buildLock(context),
                          ),
                        ),
                      ]
                    : <Widget>[
                        buildTopBar(context),
                        AnimatedSwitcher(
                          duration: Defaults.animationsFast,
                          child: buildMiddleBar(context),
                        ),
                        buildBottomBar(context),
                      ],
              ),
            ),
          );
        },
      );
}
