import 'package:better_player/better_player.dart' as better_player;
import 'package:flutter/material.dart';
import '../../app/state.dart';
import '../video_player.dart';

class BetterPlayer extends VideoPlayer {
  BetterPlayer(final VideoPlayerSource source) : super(source);

  late better_player.BetterPlayerConfiguration _configuration;
  late better_player.BetterPlayerDataSource _dataSource;
  late better_player.BetterPlayerController _controller;

  @override
  Future<void> load() async {
    _configuration = const better_player.BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      controlsConfiguration: better_player.BetterPlayerControlsConfiguration(
        loadingWidget: SizedBox.shrink(),
      ),
    );

    _dataSource = better_player.BetterPlayerDataSource(
      better_player.BetterPlayerDataSourceType.network,
      source.url,
      headers: source.headers,
    );

    _controller = better_player.BetterPlayerController(_configuration)
      ..setupDataSource(_dataSource)
      ..setControlsEnabled(false)
      ..addEventsListener(
        (final better_player.BetterPlayerEvent e) {
          switch (e.betterPlayerEventType) {
            case better_player.BetterPlayerEventType.initialized:
              dispatch(VideoPlayerEvent(VideoPlayerEvents.load, null));
              ready = true;
              break;

            case better_player.BetterPlayerEventType.progress:
            case better_player.BetterPlayerEventType.setupDataSource:
              dispatch(
                VideoPlayerEvent(VideoPlayerEvents.durationUpdate, null),
              );
              break;

            case better_player.BetterPlayerEventType.play:
              dispatch(VideoPlayerEvent(VideoPlayerEvents.play, null));
              break;

            case better_player.BetterPlayerEventType.pause:
              dispatch(VideoPlayerEvent(VideoPlayerEvents.pause, null));
              break;

            case better_player.BetterPlayerEventType.seekTo:
              dispatch(
                VideoPlayerEvent(VideoPlayerEvents.durationUpdate, null),
              );
              dispatch(VideoPlayerEvent(VideoPlayerEvents.seek, null));
              break;

            case better_player.BetterPlayerEventType.setVolume:
              dispatch(VideoPlayerEvent(VideoPlayerEvents.volume, null));
              break;

            case better_player.BetterPlayerEventType.finished:
              dispatch(VideoPlayerEvent(VideoPlayerEvents.end, null));
              break;

            case better_player.BetterPlayerEventType.setSpeed:
              dispatch(VideoPlayerEvent(VideoPlayerEvents.speed, null));
              break;

            case better_player.BetterPlayerEventType.bufferingUpdate:
              dispatch(VideoPlayerEvent(VideoPlayerEvents.buffering, null));
              break;

            case better_player.BetterPlayerEventType.exception:
              dispatch(
                VideoPlayerEvent(
                  VideoPlayerEvents.error,
                  e.parameters?['exception'] as String,
                ),
              );
              break;

            default:
              break;
          }
        },
      );
  }

  @override
  Future<void> play() async {
    _controller.play();
  }

  @override
  Future<void> pause() async {
    _controller.pause();
  }

  @override
  Future<void> seek(final Duration position) async {
    _controller.seekTo(position);
  }

  @override
  Future<void> setVolume(final int volume) async {
    _controller.setVolume(volume / VideoPlayer.maxVolume);
  }

  @override
  Future<void> setSpeed(final double speed) async {
    _controller.setSpeed(speed);
  }

  @override
  Widget getWidget() => better_player.BetterPlayer(
        controller: _controller,
      );

  @override
  Future<void> destroy() async {
    _controller.dispose();
    super.destroy();
  }

  @override
  bool get isPlaying => _controller.isPlaying() ?? false;

  @override
  bool get isBuffering => _controller.isBuffering() ?? true;

  @override
  Duration? get duration => _controller.videoPlayerController?.value.position;

  @override
  Duration? get totalDuration =>
      _controller.videoPlayerController?.value.duration;

  @override
  int get volume => ((_controller.videoPlayerController?.value.volume ??
              VideoPlayer.minVolume) *
          VideoPlayer.maxVolume)
      .toInt();

  @override
  double get speed =>
      _controller.videoPlayerController?.value.speed ??
      VideoPlayer.defaultSpeed;

  static bool isSupported() => AppState.isMobile;
}
