import 'dart:async';
import 'package:extensions/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../widgets/select_source.dart';
import '../../widgets/shared_props.dart';
import '../../../../../config/defaults.dart';
import '../../../../../modules/app/state.dart';
import '../../../../../modules/database/database.dart';
import '../../../../../modules/helpers/keyboard.dart';
import '../../../../../modules/helpers/logger.dart';
import '../../../../../modules/helpers/screen.dart';
import '../../../../../modules/helpers/ui.dart';
import '../../../../../modules/schemas/settings/anime_keyboard_shortcuts.dart';
import '../../../../../modules/state/hooks.dart';
import '../../../../../modules/state/reactive_holder.dart';
import '../../../../../modules/trackers/provider.dart';
import '../../../../../modules/trackers/trackers.dart';
import '../../../../../modules/translator/translator.dart';
import '../../../../../modules/utils/utils.dart';
import '../../../../../modules/video_player/video_player.dart';
import '../../../../components/material_tiles/radio.dart';
import '../../../settings_page/setting_labels/anime.dart';
import '../../../../models/controller.dart';

class VideoDuration {
  const VideoDuration(this.current, this.total);

  final Duration current;
  final Duration total;
}

enum SeekType {
  forward,
  backward,
  intro,
}

class WatchPageController extends Controller {
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

  final ValueNotifier<VideoDuration> duration = ValueNotifier<VideoDuration>(
    const VideoDuration(Duration.zero, Duration.zero),
  );

  final FullscreenPreserver fullscreen = FullscreenPreserver();

  @override
  Future<void> setup() async {
    Screen.isWakelockEnabled().then((final bool isWakelockEnabled) async {
      if (!isWakelockEnabled) {
        await Screen.enableWakelock();
      }
    });

    if (AppState.settings.value.animeAutoFullscreen) {
      logger.info('0 - Fullscreen');
      fullscreen.enterFullscreen();
      logger.info('1 - Fullscreen');
    }

    if (AppState.isMobile && AppState.settings.value.animeForceLandscape) {
      logger.info('0 - Landscape');
      enterLandscape();
      logger.info('1 - Landscape');
    }

    super.setup();
  }

  @override
  Future<void> destroy() async {
    videoPlayer?.destroy();
    duration.dispose();

    super.destroy();
  }

  KeyboardHandler get keyboardHandler {
    final AnimeKeyboardShortcuts shortcuts =
        AppState.settings.value.animeShortcuts;

    return KeyboardHandler(
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
            if (isReady) {
              await (videoPlayer!.isPlaying
                  ? videoPlayer!.pause()
                  : videoPlayer!.play());
            }
          },
        ),
        KeyboardKeyHandler(
          shortcuts.seekBackward,
          (final RawKeyEvent event) async {
            await seek(SeekType.backward);
          },
        ),
        KeyboardKeyHandler(
          shortcuts.seekForward,
          (final RawKeyEvent event) async {
            await seek(SeekType.forward);
          },
        ),
        KeyboardKeyHandler(
          shortcuts.skipIntro,
          (final RawKeyEvent event) async {
            await seek(SeekType.intro);
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
  }
}
