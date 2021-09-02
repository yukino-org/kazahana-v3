import './database/database.dart' as database;
import './database/schemas/settings/settings.dart' as settings_schema;
import './helpers/stater.dart';

abstract class AppState {
  static String? afterInitialRoute;
  static final SubscriberManager<settings_schema.SettingsSchema> settings =
      SubscriberManager<settings_schema.SettingsSchema>();

  static Future<void> initialize() async {
    final settings_schema.SettingsSchema settings = database.DataStore.settings;
    AppState.settings.initialize(settings);
  }
}
