import 'dart:async';
import 'package:flutter/material.dart';

enum ControllerState {
  waiting,
  setup,
  ready,
  destroyed,
}

class ControllerObserver<T extends Controller<T>> {
  const ControllerObserver({
    final this.onSetup,
    final this.onReady,
    final this.onDispose,
    final this.onReassemble,
  });

  final Future<void> Function(Controller<T>)? onSetup;
  final Future<void> Function(Controller<T>)? onReady;
  final Future<void> Function(Controller<T>)? onDispose;
  final Future<void> Function(Controller<T>)? onReassemble;
}

abstract class Controller<T extends Controller<T>> {
  final List<ControllerObserver<T>> _observers = <ControllerObserver<T>>[];

  ControllerState _state = ControllerState.waiting;
  ControllerState get state => _state;

  @mustCallSuper
  Future<void> setup() async {
    _state = ControllerState.setup;

    _eachObserver((final ControllerObserver<T> observer) {
      observer.onSetup?.call(this);
    });
  }

  @mustCallSuper
  Future<void> ready() async {
    _state = ControllerState.ready;

    _eachObserver((final ControllerObserver<T> observer) {
      observer.onReady?.call(this);
    });
  }

  void reassemble() {
    _eachObserver((final ControllerObserver<T> observer) {
      observer.onReassemble?.call(this);
    });
  }

  void subscribe(final ControllerObserver<T> observer) {
    _observers.add(observer);
  }

  void unsubscribe(final ControllerObserver<T> observer) {
    _observers.remove(observer);
  }

  @mustCallSuper
  Future<void> dispose() async {
    if (state == ControllerState.destroyed) {
      throw StateError('Controller has already been disposed');
    }

    _state = ControllerState.destroyed;
    _observers.clear();
  }

  void _eachObserver(final Function(ControllerObserver<T>) fn) {
    for (final ControllerObserver<T> observer in _observers) {
      observer.onReassemble?.call(this);
    }
  }
}
