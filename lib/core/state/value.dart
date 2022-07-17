import 'package:flutter/material.dart';
import 'states.dart';

class StatedValue<T> {
  StatedValue({
    this.state = States.waiting,
  });

  States state;
  late T value;
  Object? error;
  StackTrace? stackTrace;

  void _change(
    final States state, {
    final T? value,
    final Object? error,
    final StackTrace? stackTrace,
  }) {
    this.state = state;
    if (value != null) {
      this.value = value;
    }
    if (error != null) {
      this.error = error;
    }
    if (stackTrace != null) {
      this.stackTrace = stackTrace;
    }
  }

  void waiting([final T? value]) {
    _change(States.waiting, value: value);
  }

  void loading([final T? value]) {
    _change(States.processing, value: value);
  }

  void finish(final T value) {
    _change(States.finished, value: value);
  }

  void fail([
    final Object? error,
    final StackTrace? stackTrace,
  ]) {
    _change(States.failed, error: error, stackTrace: stackTrace);
  }

  bool get isWaiting => state == States.waiting;
  bool get isProcessing => state == States.processing;
  bool get hasFinished => state == States.finished;
  bool get hasFailed => state == States.failed;
}

class ListenableStatedValue<T> extends StatedValue<T> with ChangeNotifier {
  @override
  void _change(
    final States state, {
    final T? value,
    final Object? error,
    final StackTrace? stackTrace,
  }) {
    super._change(state, value: value, error: error, stackTrace: stackTrace);
    notifyListeners();
  }
}
