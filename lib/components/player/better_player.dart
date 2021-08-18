import 'dart:io' show Platform;
import 'package:better_player/better_player.dart' as better_player;
import 'package:flutter/material.dart';
import '../../core/models/player.dart' as model;

bool isSupported() => Platform.isAndroid || Platform.isIOS;

class VideoPlayer extends model.Player {
  VideoPlayer(final model.PlayerSource source) : super(source);

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

            case better_player.BetterPlayerEventType.setSpeed:
              dispatch(model.PlayerEvents.speed);
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
    _controller.setVolume(volume / model.Player.maxVolume);
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
  Duration? get duration => _controller.videoPlayerController?.value.position;

  @override
  Duration? get totalDuration =>
      _controller.videoPlayerController?.value.duration;

  @override
  int get volume => ((_controller.videoPlayerController?.value.volume ??
              model.Player.minVolume) *
          model.Player.maxVolume)
      .toInt();

  @override
  double get speed =>
      _controller.videoPlayerController?.value.speed ??
      model.Player.defaultSpeed;
}
