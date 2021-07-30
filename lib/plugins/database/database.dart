import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yukino_app/plugins/database/schemas/settings/settings.dart'
    as settings_schema;

abstract class DataStoreBoxNames {
  static const main = 'main_box';
}

abstract class DataStoreKeys {
  static const settings = 'settings';
}

abstract class DataBox {
  static Box get main => Hive.box(DataStoreBoxNames.main);
}

abstract class DataStore {
  static Future<void> initialize() async {
    await Hive.initFlutter();

    Hive.registerAdapter(settings_schema.SettingsSchemaAdapter());
    Hive.registerAdapter(settings_schema.MangaDirectionsAdapter());
    Hive.registerAdapter(settings_schema.MangaSwipeDirectionsAdapter());
    Hive.registerAdapter(settings_schema.MangaModeAdapter());

    await Hive.openBox(DataStoreBoxNames.main);
  }

  static settings_schema.SettingsSchema getSettings() => DataBox.main.get(
        DataStoreKeys.settings,
        defaultValue: settings_schema.SettingsSchema(),
      );
}
