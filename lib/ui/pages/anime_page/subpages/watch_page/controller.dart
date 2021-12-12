import 'dart:async';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../../../modules/app/state.dart';
import '../../../../../modules/database/database.dart';
import '../../../../../modules/helpers/keyboard.dart';
import '../../../../../modules/helpers/screen.dart';
import '../../../../../modules/trackers/provider.dart';
import '../../../../../modules/trackers/trackers.dart';
import '../../../../../modules/translator/translator.dart';
import '../../../../../modules/video_player/video_player.dart';
import '../../../../models/controller.dart';
import '../../controller.dart';
import '../../widgets/select_source.dart';

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

class WatchPageController extends Controller<WatchPageController> {
  WatchPageController({
    required final this.animeController,
  });

  final AnimePageController animeController;

  bool isBuffering = false;
  bool isPlaying = false;
  int volume = VideoPlayer.maxVolume;
  double speed = VideoPlayer.defaultSpeed;

  VideoPlayer? videoPlayer;
  List<EpisodeSource>? sources;
  int? currentSourceIndex;
  Widget? currentPlayerWidget;
  Widget? message;

  bool ignoreScreenChanges = false;
  bool locked = false;
  bool hasSynced = false;
  bool showControls = true;

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

    if (AppState.settings.value.anime.fullscreen) {
      fullscreen.enterFullscreen();
    }

    if (AppState.isMobile && AppState.settings.value.anime.landscape) {
      Screen.setOrientation(ScreenOrientation.vertical);
    }

    await super.setup();
  }

  @override
  Future<void> ready() async {
    await fetchSources();

    await super.ready();
  }

  @override
  Future<void> dispose() async {
    if (!ignoreScreenChanges) {
      Screen.disableWakelock();
      Screen.setOrientation(ScreenOrientation.unlock);
      fullscreen.exitFullscreen();
    }

    currentPlayerWidget = null;
    videoPlayer?.destroy();
    duration.dispose();

    await super.dispose();
  }

  Future<void> fetchSources() async {
    sources = await animeController.extractor!
        .getSources(animeController.currentEpisode!);
  }

  Future<void> setFullscreen({
    required final bool enabled,
  }) async {
    AppState.settings.value.anime.fullscreen = enabled;

    await (AppState.settings.value.anime.fullscreen
        ? fullscreen.enterFullscreen()
        : fullscreen.exitFullscreen());

    await SettingsBox.save(AppState.settings.value);
  }

  Future<void> setLandscape({
    required final bool enabled,
  }) async {
    AppState.settings.value.anime.landscape = enabled;

    await (AppState.settings.value.anime.landscape
        ? Screen.setOrientation(ScreenOrientation.vertical)
        : Screen.setOrientation(ScreenOrientation.unlock));

    await SettingsBox.save(AppState.settings.value);
  }

  Future<void> seek(final SeekType type) async {
    if (isReady) {
      switch (type) {
        case SeekType.forward:
          final Duration amt = duration.value.current +
              Duration(seconds: AppState.settings.value.anime.seekDuration);

          await videoPlayer!
              .seek(amt < duration.value.total ? amt : duration.value.total);
          break;

        case SeekType.backward:
          final Duration amt = duration.value.current -
              Duration(seconds: AppState.settings.value.anime.seekDuration);

          await videoPlayer!.seek(amt <= Duration.zero ? Duration.zero : amt);
          break;

        case SeekType.intro:
          final Duration amt = duration.value.current +
              Duration(seconds: AppState.settings.value.anime.introDuration);

          await videoPlayer!
              .seek(amt < duration.value.total ? amt : duration.value.total);
          break;
      }
    }
  }

  Future<void> setPlayer(final int index) async {
    currentSourceIndex = index;
    currentPlayerWidget = null;
    isPlaying = false;
    videoPlayer?.destroy();
    reassemble();

    videoPlayer = VideoPlayerManager.createPlayer(
      VideoPlayerSource(
        url: sources![currentSourceIndex!].url,
        headers: sources![currentSourceIndex!].headers,
      ),
    )..subscribe(_videoPlayerSubscriber);

    await videoPlayer!.load();
  }

  void _videoPlayerSubscriber(final VideoPlayerEvent event) {
    switch (event.event) {
      case VideoPlayerEvents.load:
        videoPlayer!.setVolume(volume);
        currentPlayerWidget = videoPlayer!.getWidget();
        reassemble();
        _updateDuration();

        if (AppState.settings.value.anime.autoPlay) {
          videoPlayer!.play();

          showControls = false;
          reassemble();
        }

        break;

      case VideoPlayerEvents.durationUpdate:
        _updateDuration();
        break;

      case VideoPlayerEvents.play:
        isPlaying = true;
        reassemble();
        break;

      case VideoPlayerEvents.pause:
        isPlaying = false;
        reassemble();
        break;

      case VideoPlayerEvents.seek:
        break;

      case VideoPlayerEvents.volume:
        volume = videoPlayer!.volume;
        break;

      case VideoPlayerEvents.end:
        if (AppState.settings.value.anime.autoNext) {
          if (nextEpisodeAvailable) {
            ignoreScreenChanges = true;
            nextEpisode();
          }
        }
        break;

      case VideoPlayerEvents.speed:
        speed = videoPlayer!.speed;
        break;

      case VideoPlayerEvents.buffering:
        isBuffering = videoPlayer!.isBuffering;
        reassemble();
        break;

      case VideoPlayerEvents.error:
        message = Builder(
          builder: (final BuildContext context) => RichText(
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
          ),
        );
        reassemble();
        break;
    }
  }

  Future<void> _updateDuration() async {
    duration.value = VideoDuration(
      videoPlayer?.duration ?? Duration.zero,
      videoPlayer?.totalDuration ?? Duration.zero,
    );

    if ((duration.value.current.inSeconds / duration.value.total.inSeconds) *
            100 >
        AppState.settings.value.anime.syncThreshold) {
      final int? episode =
          int.tryParse(animeController.currentEpisode!.episode);

      if (episode != null && !hasSynced) {
        hasSynced = true;

        final AnimeProgress progress = AnimeProgress(episodes: episode);

        for (final TrackerProvider<AnimeProgress> provider in Trackers.anime) {
          if (provider.isLoggedIn() &&
              provider.isEnabled(
                animeController.info.value!.title,
                animeController.extractor!.id,
              )) {
            final ResolvedTrackerItem? item = await provider.getComputed(
              animeController.info.value!.title,
              animeController.extractor!.id,
            );

            if (item != null) {
              await provider.updateComputed(item, progress);
            }
          }
        }
      }
    }
  }

  Future<void> showSelectSources(final BuildContext context) async {
    final dynamic value = await showGeneralDialog(
      context: context,
      barrierDismissible: currentSourceIndex != null,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (
        final BuildContext context,
        final Animation<double> a1,
        final Animation<double> a2,
      ) =>
          SafeArea(
        child: SelectSourceWidget(
          sources: sources!,
          selected:
              currentSourceIndex != null ? sources![currentSourceIndex!] : null,
        ),
      ),
    );

    if (value is EpisodeSource) {
      final int index = sources!.indexOf(value);
      if (index >= 0) {
        setPlayer(index);
      }
    }
  }

  KeyboardHandler getKeyboard(final BuildContext context) {
    final AnimeKeyboardShortcuts shortcuts =
        AppState.settings.value.anime.shortcuts;

    return KeyboardHandler(
      onKeyDown: <KeyboardKeyHandler>[
        KeyboardKeyHandler(
          shortcuts.get(AnimeKeyboardShortcutsKeys.fullscreen),
          (final RawKeyEvent event) async {
            await setFullscreen(
              enabled: !AppState.settings.value.anime.fullscreen,
            );
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(AnimeKeyboardShortcutsKeys.playPause),
          (final RawKeyEvent event) async {
            if (isReady) {
              showControls = videoPlayer!.isPlaying;
              await (videoPlayer!.isPlaying
                  ? videoPlayer!.pause()
                  : videoPlayer!.play());
              reassemble();
            }
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(AnimeKeyboardShortcutsKeys.seekBackward),
          (final RawKeyEvent event) async {
            await seek(SeekType.backward);
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(AnimeKeyboardShortcutsKeys.seekForward),
          (final RawKeyEvent event) async {
            await seek(SeekType.forward);
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(AnimeKeyboardShortcutsKeys.skipIntro),
          (final RawKeyEvent event) async {
            await seek(SeekType.intro);
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(AnimeKeyboardShortcutsKeys.exit),
          (final RawKeyEvent event) async {
            await animeController.goHome();
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(AnimeKeyboardShortcutsKeys.previousEpisode),
          (final RawKeyEvent event) async {
            if (previousEpisodeAvailable) {
              previousEpisode();
            }
          },
        ),
        KeyboardKeyHandler(
          shortcuts.get(AnimeKeyboardShortcutsKeys.nextEpisode),
          (final RawKeyEvent event) async {
            if (nextEpisodeAvailable) {
              nextEpisode();
            }
          },
        ),
      ],
    );
  }

  void previousEpisode() {
    if (previousEpisodeAvailable) {
      animeController
          .setCurrentEpisodeIndex(animeController.currentEpisodeIndex! - 1);
    }
  }

  void nextEpisode() {
    if (nextEpisodeAvailable) {
      animeController
          .setCurrentEpisodeIndex(animeController.currentEpisodeIndex! + 1);
    }
  }

  bool get previousEpisodeAvailable =>
      animeController.currentEpisodeIndex! - 1 >= 0;

  bool get nextEpisodeAvailable =>
      animeController.currentEpisodeIndex! + 1 <
      animeController.info.value!.episodes.length;

  bool get isReady => videoPlayer?.ready ?? false;
}
