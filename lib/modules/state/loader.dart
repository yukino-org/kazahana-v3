import './states.dart';

class InitialStateLoader {
  ReactiveStates loadState = ReactiveStates.waiting;

  Future<void> load() async {
    throw UnimplementedError();
  }

  Future<void> maybeLoad() async {
    if (loadState != ReactiveStates.waiting) return;

    loadState = ReactiveStates.resolving;
    try {
      await load();
      loadState = ReactiveStates.resolved;
    } catch (err) {
      loadState = ReactiveStates.failed;
      rethrow;
    }
  }
}
