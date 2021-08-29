import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import './schemas/cached_result/cached_result.dart' as cached_result_schema;
import './schemas/credentials/credentials.dart' as credentials_schema;
import './schemas/settings/settings.dart' as settings_schema;
import '../../config.dart';

abstract class TypeIds {
  static const int settings = 1;
  static const int mangaDirections = 2;
  static const int mangaSwipeDirections = 3;
  static const int mangaMode = 4;
  static const int cachedResult = 5;
  static const int credentials = 6;
}

abstract class DataStoreBoxNames {
  static const String settings = 'settings_box';
  static const String cachedAnimeInfo = 'cached_anime_box';
  static const String cachedMangaInfo = 'cached_manga_box';
  static const String credentials = 'credentials_box';
}

abstract class DataStoreKeys {
  static const String settings = 'settings';
  static const String credentials = 'credentials';
}

abstract class DataBox {
  static Box<settings_schema.SettingsSchema> get settings =>
      Hive.box<settings_schema.SettingsSchema>(DataStoreBoxNames.settings);

  static Box<cached_result_schema.CachedResultSchema> get animeInfo =>
      Hive.box<cached_result_schema.CachedResultSchema>(
        DataStoreBoxNames.cachedAnimeInfo,
      );

  static Box<cached_result_schema.CachedResultSchema> get mangaInfo =>
      Hive.box<cached_result_schema.CachedResultSchema>(
        DataStoreBoxNames.cachedMangaInfo,
      );

  static Box<credentials_schema.CredentialsSchema> get credentials =>
      Hive.box<credentials_schema.CredentialsSchema>(
        DataStoreBoxNames.credentials,
      );
}

abstract class DataStore {
  static Future<void> initialize() async {
    await Hive.initFlutter(p.join(Config.code, 'data'));

    Hive.registerAdapter(settings_schema.SettingsSchemaAdapter());
    Hive.registerAdapter(settings_schema.MangaDirectionsAdapter());
    Hive.registerAdapter(settings_schema.MangaSwipeDirectionsAdapter());
    Hive.registerAdapter(settings_schema.MangaModeAdapter());
    await Hive.openBox<settings_schema.SettingsSchema>(
      DataStoreBoxNames.settings,
    );

    Hive.registerAdapter(cached_result_schema.CachedResultSchemaAdapter());
    await Hive.openBox<cached_result_schema.CachedResultSchema>(
      DataStoreBoxNames.cachedAnimeInfo,
    );
    await Hive.openBox<cached_result_schema.CachedResultSchema>(
      DataStoreBoxNames.cachedMangaInfo,
    );

    Hive.registerAdapter(credentials_schema.CredentialsSchemaAdapter());
    await Hive.openBox<credentials_schema.CredentialsSchema>(
      DataStoreBoxNames.credentials,
    );
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
}
