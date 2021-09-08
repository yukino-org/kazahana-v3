import 'package:flutter/foundation.dart';

enum LoadState {
  waiting,
  resolving,
  resolved,
  failed,
}

class StatefulHolder<T> {
  StatefulHolder(
    final this.value, {
    final this.state = LoadState.waiting,
  });

  LoadState state;
  T value;

  void _state(final T _value, final LoadState _state) {
    value = _value;
    state = _state;
  }

  void waiting(final T value) {
    _state(value, LoadState.waiting);
  }

  void resolving(final T value) {
    _state(value, LoadState.resolving);
  }

  void resolve(final T value) {
    _state(value, LoadState.resolved);
  }

  void fail(final T value) {
    _state(value, LoadState.failed);
  }

  bool get isWaiting => state == LoadState.waiting;
  bool get isResolving => state == LoadState.resolving;
  bool get hasResolved => state == LoadState.resolved;
  bool get hasFailed => state == LoadState.failed;
  bool get hasValue => state == LoadState.resolved && value is T;
  bool get hasEnded => state == LoadState.resolved || state == LoadState.failed;
}

class StatefulListenableHolder<T> extends StatefulHolder<T>
    with ChangeNotifier
    implements ValueListenable<T> {
  StatefulListenableHolder(
    final T value, {
    final LoadState state = LoadState.waiting,
  }) : super(value, state: state);

  @override
  void _state(final T _value, final LoadState _state) {
    super._state(_value, _state);
    notifyListeners();
  }
}
