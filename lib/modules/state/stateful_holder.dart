import 'package:utilx/utilities/utils.dart';
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

class StatefulValueHolderWithError<T> extends StatefulValueHolder<T> {
  StatefulValueHolderWithError(
    final T value, {
    final ReactiveStates state = ReactiveStates.waiting,
  }) : super(value, state: state);

  ErrorInfo? error;

  @override
  void fail(final T value, [final ErrorInfo? err]) {
    _state(value, ReactiveStates.failed);
    error = err;
  }

  void failUnknown(final T value, final Object err, [final StackTrace? stack]) {
    _state(value, ReactiveStates.failed);
    error = ErrorInfo(err, stack);
  }
}
