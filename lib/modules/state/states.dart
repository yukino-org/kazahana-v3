enum ReactiveStates {
  waiting,
  resolving,
  resolved,
  failed,
}

extension ReactiveStatesUtils on ReactiveStates {
  bool get isWaiting => this == ReactiveStates.waiting;
  bool get isResolving => this == ReactiveStates.resolving;
  bool get hasResolved => this == ReactiveStates.resolved;
  bool get hasFailed => this == ReactiveStates.failed;
  bool get hasEnded =>
      this == ReactiveStates.resolved || this == ReactiveStates.failed;
}
