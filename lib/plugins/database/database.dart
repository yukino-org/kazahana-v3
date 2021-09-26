import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import './schemas/cache/cache.dart' as cache_schema;
import './schemas/credentials/credentials.dart' as credentials_schema;
import './schemas/preferences/preferences.dart' as preferences_schema;
import './schemas/settings/settings.dart' as settings_schema;
import '../../config.dart';
import '../helpers/logger.dart';
import '../helpers/utils/string.dart';

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
  static Box<settings_schema.SettingsSchema> get settings =>
      Hive.box<settings_schema.SettingsSchema>(DataStoreBoxNames.settings);

  static Box<credentials_schema.CredentialsSchema> get credentials =>
      Hive.box<credentials_schema.CredentialsSchema>(
        DataStoreBoxNames.credentials,
      );

  static Box<preferences_schema.PreferencesSchema> get preferences =>
      Hive.box<preferences_schema.PreferencesSchema>(
        DataStoreBoxNames.preferences,
      );

  static Box<cache_schema.CacheSchema> get cache =>
      Hive.box<cache_schema.CacheSchema>(
        DataStoreBoxNames.cache,
      );
}

abstract class DataStore {
  static Future<void> initialize() async {
    await Hive.initFlutter(p.join(Config.code, 'data'));
    Logger.of(DataStore).info('Initialized ${StringUtils.type(Hive)}');

    Hive.registerAdapter(settings_schema.SettingsSchemaAdapter());
    Hive.registerAdapter(settings_schema.MangaDirectionsAdapter());
    Hive.registerAdapter(settings_schema.MangaSwipeDirectionsAdapter());
    Hive.registerAdapter(settings_schema.MangaModeAdapter());
    await Hive.openBox<settings_schema.SettingsSchema>(
      DataStoreBoxNames.settings,
    );
    Logger.of(DataStore)
        .info('Registered ${StringUtils.type(settings_schema.SettingsSchema)}');

    Hive.registerAdapter(credentials_schema.CredentialsSchemaAdapter());
    await Hive.openBox<credentials_schema.CredentialsSchema>(
      DataStoreBoxNames.credentials,
    );
    Logger.of(DataStore).info(
      'Registered ${StringUtils.type(credentials_schema.CredentialsSchema)}',
    );

    Hive.registerAdapter(preferences_schema.PreferencesSchemaAdapter());
    await Hive.openBox<preferences_schema.PreferencesSchema>(
      DataStoreBoxNames.preferences,
    );
    Logger.of(DataStore).info(
      'Registered ${StringUtils.type(preferences_schema.PreferencesSchema)}',
    );

    Hive.registerAdapter(cache_schema.CacheSchemaAdapter());
    await Hive.openBox<cache_schema.CacheSchema>(
      DataStoreBoxNames.cache,
    );
    Logger.of(DataStore)
        .info('Registered ${StringUtils.type(cache_schema.CacheSchema)}');
  }

  static settings_schema.SettingsSchema get settings {
    final settings_schema.SettingsSchema defaultValue =
        settings_schema.SettingsSchema();

    return DataBox.settings.get(
          DataStoreKeys.settings,
          defaultValue: defaultValue,
        ) ??
        defaultValue;
  }

  static credentials_schema.CredentialsSchema get credentials {
    final credentials_schema.CredentialsSchema defaultValue =
        credentials_schema.CredentialsSchema();

    return DataBox.credentials.get(
          DataStoreKeys.credentials,
          defaultValue: defaultValue,
        ) ??
        defaultValue;
  }

  static preferences_schema.PreferencesSchema get preferences {
    final preferences_schema.PreferencesSchema defaultValue =
        preferences_schema.PreferencesSchema();

    return DataBox.preferences.get(
          DataStoreKeys.preferences,
          defaultValue: defaultValue,
        ) ??
        defaultValue;
  }
}
