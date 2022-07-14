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

  // ignore: use_setters_to_change_properties
  void _setState(final States state) {
    this.state = state;
  }

  // ignore: use_setters_to_change_properties
  void _setValue(final T value) {
    this.value = value;
  }

  void _setError([final Object? error, final StackTrace? stackTrace]) {
    this.error = error;
    this.stackTrace = stackTrace;
  }

  void loading() {
    _setState(States.waiting);
  }

  void finish(final T value) {
    _setState(States.finished);
    _setValue(value);
  }

  void fail([
    final Object? error,
    final StackTrace? stackTrace,
  ]) {
    _setState(States.failed);
    _setError(error, stackTrace);
  }
}

class ListenableStatedValue<T> extends StatedValue<T> with ChangeNotifier {
  @override
  void _setState(final States state) {
    super._setState(state);
    notifyListeners();
  }
}
