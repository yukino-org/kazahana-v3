typedef EventerSubscriber<T> = void Function(T event);

class Eventer<T> {
  final List<EventerSubscriber<T>> _subscribers = <EventerSubscriber<T>>[];

  void Function() subscribe(final EventerSubscriber<T> sub) {
    _subscribers.add(sub);
    return () => unsubscribe(sub);
  }

  void unsubscribe(final EventerSubscriber<T> sub) {
    _subscribers.remove(sub);
  }

  void dispatch(final T event) {
    for (final EventerSubscriber<T> sub in _subscribers) {
      sub(event);
    }
  }

  void destroy() {
    _subscribers.clear();
  }
}

typedef ReactiveEventerSubscriber<T> = void Function(T current, T previous);

class ReactiveEventer<T> {
  ReactiveEventer(this._value);

  T _value;
  final List<ReactiveEventerSubscriber<T>> subscribers =
      <ReactiveEventerSubscriber<T>>[];

  set value(final T modified) {
    dispatch(modified, value);
    _value = modified;
  }

  T get value => _value;

  void Function() subscribe(final ReactiveEventerSubscriber<T> sub) {
    subscribers.add(sub);
    return () => unsubscribe(sub);
  }

  void unsubscribe(final ReactiveEventerSubscriber<T> sub) {
    subscribers.remove(sub);
  }

  void dispatch(final T current, final T previous) {
    for (final ReactiveEventerSubscriber<T> sub in subscribers) {
      sub(current, previous);
    }
  }
}
