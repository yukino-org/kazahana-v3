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
}
