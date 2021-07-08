typedef StateSubscriber<T> = dynamic Function(T current, T previous);

class SubscriberManager<T> {
  final List<StateSubscriber<T>> subscribers = [];

  void Function() subscribe(StateSubscriber<T> sub) {
    subscribers.add(sub);
    return () {
      return unsubscribe(sub);
    };
  }

  void unsubscribe(StateSubscriber<T> sub) {
    subscribers.remove(sub);
  }

  void dispatch(T current, T previous) {
    for (final sub in subscribers) {
      sub(current, previous);
    }
  }
}

class AppTheme {
  bool systemPreferred;
  bool darkMode;

  AppTheme(this.systemPreferred, this.darkMode);
}

abstract class AppState {
  static final darkMode = SubscriberManager<AppTheme>();
}
