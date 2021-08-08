typedef StateSubscriber<T> = void Function(T current, T previous);

class SubscriberManager<T> {
  late T current;
  final List<StateSubscriber<T>> subscribers = <StateSubscriber<T>>[];

  // ignore: use_setters_to_change_properties
  void initialize(final T initial) {
    current = initial;
  }

  void modify(final T modified) {
    dispatch(modified, current);
    current = modified;
  }

  void Function() subscribe(final StateSubscriber<T> sub) {
    subscribers.add(sub);
    return () => unsubscribe(sub);
  }

  void unsubscribe(final StateSubscriber<T> sub) {
    subscribers.remove(sub);
  }

  void dispatch(final T current, final T previous) {
    for (final StateSubscriber<T> sub in subscribers) {
      sub(current, previous);
    }
  }
}
