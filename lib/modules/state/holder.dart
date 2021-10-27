import './states.dart';

class StatefulValueHolder<T> {
  StatefulValueHolder(
    final this.value, {
    final this.state = ReactiveStates.waiting,
  });

  ReactiveStates state;
  T value;

  void _state(final T _value, final ReactiveStates _state) {
    value = _value;
    state = _state;
  }

  void waiting(final T value) {
    _state(value, ReactiveStates.waiting);
  }

  void resolving(final T value) {
    _state(value, ReactiveStates.resolving);
  }

  void resolve(final T value) {
    _state(value, ReactiveStates.resolved);
  }

  void fail(final T value) {
    _state(value, ReactiveStates.failed);
  }

  bool get isWaiting => state == ReactiveStates.waiting;
  bool get isResolving => state == ReactiveStates.resolving;
  bool get hasResolved => state == ReactiveStates.resolved;
  bool get hasFailed => state == ReactiveStates.failed;
  bool get hasValue => state == ReactiveStates.resolved;
  bool get hasEnded =>
      state == ReactiveStates.resolved || state == ReactiveStates.failed;
}
