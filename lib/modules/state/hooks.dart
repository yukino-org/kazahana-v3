import 'dart:async';
import './states.dart';

typedef OnReadyHook = Future<void> Function();

class HooksState {
  ReactiveStates ready = ReactiveStates.waiting;
  OnReadyHook? onReady;
}

mixin HooksMixin {
  final HooksState hookState = HooksState();

  // ignore: use_setters_to_change_properties
  void onReady(final OnReadyHook? hook) {
    hookState.onReady = hook;
  }

  Future<void> maybeEmitReady() async {
    if (hookState.ready == ReactiveStates.waiting &&
        hookState.onReady != null) {
      hookState.ready = ReactiveStates.resolving;
      try {
        await hookState.onReady!();
        hookState.ready = ReactiveStates.resolved;
      } catch (err) {
        hookState.ready = ReactiveStates.failed;
        rethrow;
      }
    }
  }
}
