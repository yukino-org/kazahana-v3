import 'package:flutter/material.dart';

enum ControllerState {
  waiting,
  setup,
  ready,
  destroyed,
}

abstract class Controller extends ChangeNotifier {
  ControllerState state = ControllerState.waiting;

  @mustCallSuper
  Future<void> setup() async {
    state = ControllerState.setup;
  }

  @mustCallSuper
  Future<void> ready(final BuildContext context) async {
    state = ControllerState.ready;
  }

  void rebuild() {
    notifyListeners();
  }

  @mustCallSuper
  Future<void> destroy() async {
    state = ControllerState.destroyed;

    super.dispose();
  }
}
