import 'dart:async';

class AppEvent {
  const AppEvent(this.name, [this.data]);

  final String name;
  final dynamic data;

  @override
  bool operator ==(final Object other) =>
      other is AppEvent && other.name == name;

  @override
  int get hashCode => Object.hash(name, data);

  static const AppEvent initialized = AppEvent('initialized');
  static const AppEvent afterAnitialized = AppEvent('after_initialized');
  static const AppEvent anilistStateChange = AppEvent('anilist_state_change');
  static const AppEvent settingsChange = AppEvent('settings_change');
  static const AppEvent translationsChange = AppEvent('translations_change');
}

abstract class AppEvents {
  static final StreamController<AppEvent> controller =
      StreamController<AppEvent>.broadcast();

  static final Stream<AppEvent> stream = controller.stream;
}
