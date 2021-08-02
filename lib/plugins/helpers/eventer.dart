typedef EventerSubscriber<T> = void Function(T value);

class Eventer<T> {
  final List<EventerSubscriber<T>> _subscribers = [];

  void Function() subscribe(EventerSubscriber<T> sub) {
    _subscribers.add(sub);
    return () => unsubscribe(sub);
  }

  void unsubscribe(EventerSubscriber<T> sub) {
    _subscribers.remove(sub);
  }

  void dispatch(T value) {
    for (final sub in _subscribers) {
      sub(value);
    }
  }

  void destroy() {
    _subscribers.clear();
  }
}
