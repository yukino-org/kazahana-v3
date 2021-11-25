import 'dart:async';
import 'package:flutter/material.dart';

enum ControllerState {
  waiting,
  setup,
  ready,
  destroyed,
}

typedef ControllerSubscriber = void Function();

abstract class Controller {
  bool _didSetup = false;
  bool _didReady = false;
  ControllerState state = ControllerState.waiting;

  final List<ControllerSubscriber> _subs = <ControllerSubscriber>[];
  bool _didDestroy = false;

  @mustCallSuper
  Future<bool> setup() async {
    if (!_didSetup) {
      state = ControllerState.setup;
      _didSetup = true;
      return true;
    }

    return false;
  }

  @mustCallSuper
  Future<bool> ready() async {
    if (!_didReady) {
      state = ControllerState.ready;
      _didReady = true;
      return true;
    }

    return false;
  }

  void subscribe(final ControllerSubscriber sub) {
    _subs.add(sub);
  }

  void unsubscribe(final ControllerSubscriber sub) {
    _subs.remove(sub);
  }

  void rebuild() {
    if (state == ControllerState.ready) {
      for (final ControllerSubscriber sub in _subs) {
        sub();
      }
    }
  }

  @mustCallSuper
  Future<bool> maybeDispose() async {
    if (!_didDestroy && disposable) {
      state = ControllerState.destroyed;
      _didDestroy = true;
      return true;
    }

    return false;
  }

  @mustCallSuper
  Future<bool> dispose() async {
    _subs.clear();
    return maybeDispose();
  }

  bool get disposable => _subs.isEmpty;
}
