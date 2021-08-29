import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import './eventer.dart';

class ScreenState {
  ScreenState({
    required final this.maximized,
    required final this.bounds,
  });

  final bool maximized;
  final Rect bounds;
}

mixin FullscreenMixin {
  late Duration fullscreenInterval;
  ScreenState? prevScreenState;
  OnFullscreenChange? fullscreenWatcher;
  final ValueNotifier<bool> isFullscreened = ValueNotifier<bool>(false);

  // ignore: use_setters_to_change_properties
  void initFullscreen([final Duration interval = const Duration(seconds: 5)]) {
    fullscreenInterval = interval;
  }

  Future<void> enterFullscreen() async {
    prevScreenState = await Screen.enterFullscreen();
    fullscreenWatcher = OnFullscreenChange(fullscreenInterval);
    isFullscreened.value = true;
  }

  Future<void> exitFullscreen() async {
    fullscreenWatcher?.dispose();
    await Screen.exitFullscreen(prevScreenState);
    isFullscreened.value = false;
  }
}

class OnFullscreenChange {
  OnFullscreenChange(this.duration) {
    Screen.uiChangeNotifier.subscribe(onUiChange);
  }

  final Duration duration;

  Timer? timer;

  void dispose() {
    timer?.cancel();
    timer = null;
    Screen.uiChangeNotifier.unsubscribe(onUiChange);
  }

  // ignore: avoid_positional_boolean_parameters
  void onUiChange(final bool fullscreen) {
    timer?.cancel();
    timer = null;
    if (!fullscreen) {
      timer = Timer(duration, () {
        if (!Screen.isFullscreened) {
          Screen.enterFullscreen();
        }
      });
    }
  }
}

abstract class Screen {
  static final Eventer<bool> uiChangeNotifier = Eventer<bool>();

  static bool isFullscreened = false;

  static Future<void> initialize() async {
    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setSystemUIChangeCallback((final bool fullscreen) async {
        isFullscreened = fullscreen;

        uiChangeNotifier.dispatch(fullscreen);
      });
    }
  }

  static Future<ScreenState?> enterFullscreen() async {
    ScreenState? state;

    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      state = ScreenState(
        bounds: await WindowManager.instance.getBounds(),
        maximized: await WindowManager.instance.isMaximized(),
      );

      WindowManager.instance.setFullScreen(true);
    }

    isFullscreened = true;
    return state;
  }

  static Future<void> exitFullscreen([final ScreenState? state]) async {
    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      WindowManager.instance.setFullScreen(false);

      if (state != null) {
        await WindowManager.instance.setBounds(state.bounds);
        if (state.maximized) {
          WindowManager.instance.maximize();
        }
      }
    }

    isFullscreened = false;
  }
}
