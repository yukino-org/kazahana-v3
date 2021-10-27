import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import './schemas/cache/cache.dart';
import './schemas/credentials/credentials.dart';
import './schemas/preferences/preferences.dart';
import './schemas/settings/settings.dart';
import '../../config/app.dart';
import '../helpers/logger.dart';

abstract class TypeIds {
  static const int settings = 1;
  static const int mangaDirections = 2;
  static const int mangaSwipeDirections = 3;
  static const int mangaMode = 4;
  static const int credentials = 6;
  static const int preferences = 7;
  static const int cache = 8;
}

abstract class DataStoreBoxNames {
  static const String settings = 'settings_box';
  static const String credentials = 'credentials_box';
  static const String preferences = 'preferences_box';
  static const String cache = 'cache_box';
}

abstract class DataStoreKeys {
  static const String settings = 'settings';
  static const String credentials = 'credentials';
  static const String preferences = 'preferences';
}

abstract class DataBox {
  static Box<SettingsSchema> get settings =>
      Hive.box<SettingsSchema>(DataStoreBoxNames.settings);

  static Box<CredentialsSchema> get credentials => Hive.box<CredentialsSchema>(
        DataStoreBoxNames.credentials,
      );

  static Box<PreferencesSchema> get preferences => Hive.box<PreferencesSchema>(
        DataStoreBoxNames.preferences,
      );

  static Box<CacheSchema> get cache => Hive.box<CacheSchema>(
        DataStoreBoxNames.cache,
      );
}

abstract class DataStore {
  static Future<void> initialize() async {
    await Hive.initFlutter(p.join(Config.code, 'data'));
    Logger.of('DataStore').info('Initialized "Hive"');

    Hive.registerAdapter(SettingsSchemaAdapter());
    Hive.registerAdapter(MangaDirectionsAdapter());
    Hive.registerAdapter(MangaSwipeDirectionsAdapter());
    Hive.registerAdapter(MangaModeAdapter());
    await Hive.openBox<SettingsSchema>(
      DataStoreBoxNames.settings,
    );
    Logger.of('DataStore').info('Registered "SettingsSchema"');

    Hive.registerAdapter(CredentialsSchemaAdapter());
    await Hive.openBox<CredentialsSchema>(
      DataStoreBoxNames.credentials,
    );
    Logger.of('DataStore').info('Registered "CredentialsSchema"');

    Hive.registerAdapter(PreferencesSchemaAdapter());
    await Hive.openBox<PreferencesSchema>(
      DataStoreBoxNames.preferences,
    );
    Logger.of('DataStore').info('Registered "PreferencesSchema"');

    Hive.registerAdapter(CacheSchemaAdapter());
    await Hive.openBox<CacheSchema>(
      DataStoreBoxNames.cache,
    );
    Logger.of('DataStore').info('Registered "CacheSchema"');
  }

  static Future<void> dispose() async {
    await Hive.close();
  }

  static SettingsSchema get settings {
    final SettingsSchema defaultValue = SettingsSchema();

    return DataBox.settings.get(
          DataStoreKeys.settings,
          defaultValue: defaultValue,
        ) ??
        defaultValue;
  }

  static CredentialsSchema get credentials {
    final CredentialsSchema defaultValue = CredentialsSchema();

    return DataBox.credentials.get(
          DataStoreKeys.credentials,
          defaultValue: defaultValue,
        ) ??
        defaultValue;
  }

  static PreferencesSchema get preferences {
    final PreferencesSchema defaultValue = PreferencesSchema();

    return DataBox.preferences.get(
          DataStoreKeys.preferences,
          defaultValue: defaultValue,
        ) ??
        defaultValue;
  }
}
