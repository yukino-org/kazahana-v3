import 'dart:async';
import 'dart:math';
import 'package:dart_vlc/dart_vlc.dart' as dart_vlc;
import 'package:flutter/material.dart';
import '../../app/state.dart';
import '../../local_server/routes/proxy.dart';
import '../video_player.dart';

late final dart_vlc.Player _player;

class DartVlc extends VideoPlayer {
  DartVlc(final VideoPlayerSource source) : super(source);

  double? _prevSpeed;
  double? _prevVolume;
  double? _prevBuffering;
  final GlobalKey _playerKey = GlobalKey();

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  Future<void> load() async {
    _subscriptions.addAll(
      <StreamSubscription<dynamic>>[
        _player.positionStream.listen((final dart_vlc.PositionState position) {
          dispatch(VideoPlayerEvent(VideoPlayerEvents.durationUpdate, null));
        }),
        _player.playbackStream.listen((final dart_vlc.PlaybackState playback) {
          dispatch(
            VideoPlayerEvent(
              playback.isPlaying
                  ? VideoPlayerEvents.play
                  : VideoPlayerEvents.pause,
              null,
            ),
          );

          if (playback.isCompleted) {
            dispatch(VideoPlayerEvent(VideoPlayerEvents.end, null));
          }
        }),
        _player.generalStream.listen((final dart_vlc.GeneralState general) {
          if (_prevSpeed != general.rate) {
            dispatch(VideoPlayerEvent(VideoPlayerEvents.speed, null));
          }

          if (_prevVolume != general.volume) {
            dispatch(VideoPlayerEvent(VideoPlayerEvents.volume, null));
          }
        }),
        _player.currentStream.listen((final dart_vlc.CurrentState current) {
          if (!ready && current.medias.isNotEmpty) {
            dispatch(VideoPlayerEvent(VideoPlayerEvents.load, null));
            ready = true;
          }
        }),
        _player.bufferingProgressStream
            .listen((final double bufferingProgress) {
          if (_prevBuffering != bufferingProgress) {
            dispatch(VideoPlayerEvent(VideoPlayerEvents.buffering, null));
          }
        })
      ],
    );

    _player.open(
      dart_vlc.Playlist(
        medias: <dart_vlc.Media>[
          dart_vlc.Media.network(
            getProxiedURL(source.url, source.headers),
          ),
        ],
      ),
      autoStart: false,
    );

    dispatch(VideoPlayerEvent(VideoPlayerEvents.error, 'hello bro'));
  }

  @override
  Future<void> play() async {
    _player.play();
  }

  @override
  Future<void> pause() async {
    _player.pause();
  }

  @override
  Future<void> seek(final Duration position) async {
    _player.seek(position);
  }

  @override
  Future<void> setVolume(final int volume) async {
    _player.setVolume(volume / VideoPlayer.maxVolume);
  }

  @override
  Future<void> setSpeed(final double speed) async {
    _player.setRate(speed);
  }

  @override
  Widget getWidget() => dart_vlc.Video(
        key: _playerKey,
        showControls: false,
        player: _player,
      );

  @override
  Future<void> destroy() async {
    _player.stop();

    for (final StreamSubscription<dynamic> x in _subscriptions) {
      x.cancel();
    }

    super.destroy();
  }

  @override
  bool get isPlaying => _player.playback.isPlaying;

  @override
  bool get isBuffering => _player.bufferingProgress < 100.0;

  @override
  Duration? get duration => _player.position.position;

  @override
  Duration? get totalDuration => _player.position.duration;

  @override
  int get volume => ((_player.general.volume) * VideoPlayer.maxVolume).toInt();

  @override
  double get speed => _player.general.rate;

  static Future<void> initialize() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    dart_vlc.DartVLC.initialize();
    _player = dart_vlc.Player(id: Random.secure().nextInt(69420));
  }

  static bool isSupported() => AppState.isDesktop;
}
