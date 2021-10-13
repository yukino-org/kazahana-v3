import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utilx/utilities/window.dart';
import 'package:window_manager/window_manager.dart';
import './eventer.dart';
import '../state.dart';

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

    if (isFullscreened.value) {
      await Screen.exitFullscreen(prevScreenState);
    }

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
    if (AppState.isMobile) {
      SystemChrome.setSystemUIChangeCallback((final bool fullscreen) async {
        isFullscreened = fullscreen;

        uiChangeNotifier.dispatch(fullscreen);
      });
    }
  }

  static Future<void> setTitle(final String title) async {
    if (!AppState.isDesktop) return;

    await WindowManager.instance.setTitle(title);
  }

  static Future<void> close() async {
    if (!AppState.isDesktop) return;

    await WindowManager.instance.terminate();
  }

  static Future<void> focus() async {
    if (!AppState.isDesktop) return;

    WindowManager.instance.show();
    if (Platform.isLinux || Platform.isMacOS) {
      WindowManager.instance.focus();
    } else {
      await WindowUtils.focus();
    }
  }

  static Future<ScreenState?> enterFullscreen() async {
    ScreenState? state;

    if (AppState.isMobile) {
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
    if (AppState.isMobile) {
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
