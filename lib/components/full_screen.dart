import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// TODO: have to fix this
// import 'package:window_manager/window_manager.dart';
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
  late bool isOnFullscreen;

  @override
  void initState() {
    super.initState();

    AppState.uiStyleNotifier.subscribe(_onUiChange);

    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // TODO: needs some update
      // WindowManager.instance.setFullScreen(true);
    }
  }

  @override
  void dispose() {
    currentTimer?.cancel();
    currentTimer = null;

    AppState.uiStyleNotifier.unsubscribe(_onUiChange);

    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // TODO: needs some update
      // WindowManager.instance.setFullScreen(false);
    }

    super.dispose();
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

  @override
  Widget build(final BuildContext context) => SizedBox.expand(
        child: Container(
          color: Colors.black,
          child: widget.child,
        ),
      );
}
