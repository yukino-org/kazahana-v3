import 'dart:async';
import './states.dart';

typedef OnReadyHook = Future<void> Function();

class HooksState {
  ReactiveStates ready = ReactiveStates.waiting;
  OnReadyHook? onReady;

  Future<void> markReady() async {
    if (ready == ReactiveStates.waiting && onReady != null) {
      ready = ReactiveStates.resolving;
      try {
        await onReady!();
        ready = ReactiveStates.resolved;
      } catch (err) {
        ready = ReactiveStates.failed;
        rethrow;
      }
    }
  }
}

mixin HooksMixin {
  final HooksState hookState = HooksState();

  // ignore: use_setters_to_change_properties
  void onReady(final OnReadyHook? hook) {
    hookState.onReady = hook;
  }
}
