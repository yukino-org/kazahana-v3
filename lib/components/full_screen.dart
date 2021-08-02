import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../plugins/state.dart' show AppState;

class FullScreenWidget extends StatefulWidget {
  final Widget child;

  const FullScreenWidget({Key? key, required this.child}) : super(key: key);

  @override
  FullScreenState createState() => FullScreenState();
}

class FullScreenState extends State<FullScreenWidget> {
  final interval = const Duration(seconds: 5);
  Timer? currentTimer;
  late bool isOnFullscreen;

  @override
  void initState() {
    super.initState();

    AppState.uiStyleNotifier.subscribe(_onUiChange);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    currentTimer?.cancel();
    currentTimer = null;

    AppState.uiStyleNotifier.unsubscribe(_onUiChange);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  void _onUiChange(bool isOnFullscreen) {
    isOnFullscreen = isOnFullscreen;

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
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Colors.black,
        child: widget.child,
      ),
    );
  }
}
