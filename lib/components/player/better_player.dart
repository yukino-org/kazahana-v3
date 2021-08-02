import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart' as better_player;
import '../../../core/models/player.dart' as model;

class VideoPlayer extends model.Player {
  late better_player.BetterPlayerConfiguration _configuration;
  late better_player.BetterPlayerDataSource _dataSource;
  late better_player.BetterPlayerController _controller;

  VideoPlayer(model.PlayerSource source) : super(source);

  @override
  Future<void> initialize() async {
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
      ..addEventsListener((e) {
        switch (e.betterPlayerEventType) {
          case better_player.BetterPlayerEventType.initialized:
            dispatch(model.PlayerEvents.load);
            ready = true;
            break;

          case better_player.BetterPlayerEventType.progress:
          case better_player.BetterPlayerEventType.setupDataSource:
            dispatch(model.PlayerEvents.durationUpdate);
            break;

          case better_player.BetterPlayerEventType.play:
            dispatch(model.PlayerEvents.play);
            break;

          case better_player.BetterPlayerEventType.pause:
            dispatch(model.PlayerEvents.pause);
            break;

          case better_player.BetterPlayerEventType.seekTo:
            dispatch(model.PlayerEvents.durationUpdate);
            dispatch(model.PlayerEvents.seek);
            break;

          case better_player.BetterPlayerEventType.setVolume:
            dispatch(model.PlayerEvents.volume);
            break;

          case better_player.BetterPlayerEventType.finished:
            dispatch(model.PlayerEvents.end);
            break;

          default:
            break;
        }
      });
  }

  @override
  play() async {
    _controller.play();
  }

  @override
  pause() async {
    _controller.pause();
  }

  @override
  seek(position) async {
    _controller.seekTo(position);
  }

  @override
  setVolume(volume) async {
    _controller.setVolume(volume / model.Player.maxVolume);
  }

  @override
  getWidget() {
    return better_player.BetterPlayer(
      controller: _controller,
    );
  }

  @override
  destroy() async {
    _controller.dispose();
    super.destroy();
  }

  @override
  get isPlaying {
    return _controller.isPlaying() ?? false;
  }

  @override
  get duration {
    return _controller.videoPlayerController?.value.position;
  }

  @override
  get totalDuration {
    return _controller.videoPlayerController?.value.duration;
  }

  @override
  get volume {
    return ((_controller.videoPlayerController?.value.volume ??
                model.Player.minVolume) *
            model.Player.maxVolume)
        .toInt();
  }
}
