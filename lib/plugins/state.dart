import 'package:flutter/services.dart' show SystemChrome;
import './database/database.dart' as database;
import './database/schemas/settings/settings.dart' as settings_schema;
import './helpers/eventer.dart';

typedef StateSubscriber<T> = void Function(T current, T previous);

class SubscriberManager<T> {
  late T current;
  final List<StateSubscriber<T>> subscribers = [];

  void initialize(T initial) => current = initial;

  void modify(T modified) {
    dispatch(modified, current);
    current = modified;
  }

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

abstract class AppState {
  static final settings = SubscriberManager<settings_schema.SettingsSchema>();
  static final uiStyleNotifier = Eventer<bool>();

  static Future<void> initialize() async {
    final settings = database.DataStore.getSettings();
    AppState.settings.initialize(settings);

    SystemChrome.setSystemUIChangeCallback((isOnFullscreen) async {
      uiStyleNotifier.dispatch(isOnFullscreen);
    });
  }
}
