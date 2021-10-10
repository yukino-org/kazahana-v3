import 'dart:math';
import 'package:dart_vlc/dart_vlc.dart' as dart_vlc;
import 'package:flutter/material.dart';
import '../../core/models/player.dart' as model;
import '../../plugins/helpers/local_server/routes/proxy.dart'
    show getProxiedURL;
import '../../plugins/state.dart';

late final dart_vlc.Player _player;

Future<void> initialize() async {
  dart_vlc.DartVLC.initialize();
  _player = dart_vlc.Player(id: Random.secure().nextInt(69420));
}

bool isSupported() => AppState.isDesktop;

class VideoPlayer extends model.Player {
  VideoPlayer(final model.PlayerSource source) : super(source);

  double? _prevSpeed;
  double? _prevVolume;

  @override
  Future<void> load() async {
    _player
      ..positionStream.listen((final dart_vlc.PositionState position) {
        dispatch(model.PlayerEvent(model.PlayerEvents.durationUpdate, null));
      })
      ..playbackStream.listen((final dart_vlc.PlaybackState playback) {
        dispatch(
          model.PlayerEvent(
            playback.isPlaying
                ? model.PlayerEvents.play
                : model.PlayerEvents.pause,
            null,
          ),
        );

        if (playback.isCompleted) {
          dispatch(model.PlayerEvent(model.PlayerEvents.end, null));
        }
      })
      ..generalStream.listen((final dart_vlc.GeneralState general) {
        if (_prevSpeed != general.rate) {
          dispatch(model.PlayerEvent(model.PlayerEvents.speed, null));
        }

        if (_prevVolume != general.volume) {
          dispatch(model.PlayerEvent(model.PlayerEvents.volume, null));
        }
      })
      ..currentStream.listen((final dart_vlc.CurrentState current) {
        if (!ready && current.medias.isNotEmpty) {
          dispatch(model.PlayerEvent(model.PlayerEvents.load, null));
          ready = true;
        }
      })
      ..open(
        dart_vlc.Playlist(
          medias: <dart_vlc.Media>[
            dart_vlc.Media.network(
              getProxiedURL(source.url, source.headers),
            ),
          ],
        ),
        autoStart: false,
      );
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
    _player.setVolume(volume / model.Player.maxVolume);
  }

  @override
  Future<void> setSpeed(final double speed) async {
    _player.setRate(speed);
  }

  @override
  Widget getWidget() => dart_vlc.Video(
        showControls: false,
        player: _player,
      );

  @override
  Future<void> destroy() async {
    _player.stop();
    super.destroy();
  }

  @override
  bool get isPlaying => _player.playback.isPlaying;

  @override
  Duration? get duration => _player.position.position;

  @override
  Duration? get totalDuration => _player.position.duration;

  @override
  int get volume => ((_player.general.volume) * model.Player.maxVolume).toInt();

  @override
  double get speed => _player.general.rate;
}
