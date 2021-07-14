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
    );

    _dataSource = better_player.BetterPlayerDataSource(
      better_player.BetterPlayerDataSourceType.network,
      source.url,
      headers: source.headers,
    );

    _controller = better_player.BetterPlayerController(_configuration)
      ..setupDataSource(_dataSource);
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
  Future<void> seek(position) async {
    _controller.seekTo(position);
  }

  @override
  Future<void> setVolume(volume) async {
    _controller.setVolume(volume);
  }

  @override
  Widget getWidget() {
    return better_player.BetterPlayer(
      controller: _controller,
    );
  }

  @override
  bool get isPlaying {
    return _controller.isPlaying() ?? false;
  }
}
