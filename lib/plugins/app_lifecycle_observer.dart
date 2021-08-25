import 'package:flutter/material.dart';

// Pending at https://github.com/flutter/flutter/issues/30735
class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    // Save window state in desktop
  }
}

final _AppLifecycleObserver appLifecycleObserver = _AppLifecycleObserver();
