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

  T value;
  LoadState state;

  bool get isWaiting => state == LoadState.waiting;
  bool get isResolving => state == LoadState.resolving;
  bool get hasResolved => state == LoadState.resolved;
  bool get hasFailed => state == LoadState.failed;
  bool get hasValue => state == LoadState.resolved && value is T;
}
