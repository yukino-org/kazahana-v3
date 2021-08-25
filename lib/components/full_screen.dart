import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;
import '../plugins/state.dart' show AppState;

class FullScreenWidget extends StatefulWidget {
  const FullScreenWidget({
    required final this.child,
    final Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  _FullScreenState createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreenWidget> {
  final Duration interval = const Duration(seconds: 5);
  Timer? currentTimer;

  final FocusNode focusNode = FocusNode();
  late bool isOnFullscreen;
  late Rect prevBounds;

  @override
  void initState() {
    super.initState();

    AppState.uiStyleNotifier.subscribe(_onUiChange);

    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      _setFullScreen();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    currentTimer?.cancel();
    currentTimer = null;

    AppState.uiStyleNotifier.unsubscribe(_onUiChange);

    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      _exitFullScreen();
    }

    super.dispose();
  }

  Future<void> _setFullScreen() async {
    prevBounds = await WindowManager.instance.getBounds();

    if (Platform.isLinux || Platform.isMacOS) {
      WindowManager.instance.setFullScreen(true);
    } else if (Platform.isWindows) {
      window_size.enterFullscreen();
    }
  }

  Future<void> _exitFullScreen() async {
    if (Platform.isLinux || Platform.isMacOS) {
      WindowManager.instance.setFullScreen(false);
    } else if (Platform.isWindows) {
      window_size.exitFullscreen();
    }

    await WindowManager.instance.setBounds(prevBounds);

    final Size? maxSize = AppState.maxSize;
    if (maxSize != null &&
        maxSize.width == prevBounds.width &&
        maxSize.height == prevBounds.height) {
      WindowManager.instance.maximize();
    }
  }

  void _onUiChange(final bool fullscreen) {
    isOnFullscreen = fullscreen;
    currentTimer?.cancel();
    currentTimer = null;
    if (!isOnFullscreen) {
      currentTimer = Timer(interval, () {
        if (!isOnFullscreen) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        }
      });
    }
  }

  void _onKey(final RawKeyEvent event) {
    if (Platform.isWindows && event.logicalKey == LogicalKeyboardKey.escape) {
      _exitFullScreen();
    }
  }

  @override
  Widget build(final BuildContext context) => RawKeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKey: _onKey,
        child: SizedBox.expand(
          child: Container(
            color: Colors.black,
            child: widget.child,
          ),
        ),
      );
}
