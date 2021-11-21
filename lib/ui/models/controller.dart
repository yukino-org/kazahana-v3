import 'package:flutter/material.dart';

enum ControllerState {
  waiting,
  setup,
  ready,
  destroyed,
}

class ControllerInternals {
  const ControllerInternals({
    required final this.isMounted,
    required final this.getCurrentContext,
  });

  factory ControllerInternals.fromState(final State state) =>
      ControllerInternals(
        isMounted: () => state.mounted,
        getCurrentContext: () => state.context,
      );

  final bool Function() isMounted;
  final BuildContext Function() getCurrentContext;
}

abstract class Controller extends ChangeNotifier {
  ControllerInternals? internals;
  ControllerState state = ControllerState.waiting;

  @mustCallSuper
  Future<void> setup() async {
    state = ControllerState.setup;
  }

  @mustCallSuper
  Future<void> ready() async {
    state = ControllerState.ready;
  }

  void rebuild() {
    notifyListeners();
  }

  @override
  @mustCallSuper
  Future<void> dispose() async {
    state = ControllerState.destroyed;

    super.dispose();
  }

  bool get mounted => internals?.isMounted() ?? false;
  BuildContext? get context => internals?.getCurrentContext();
}
