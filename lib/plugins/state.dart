import 'dart:io' show Platform;
import 'package:flutter/services.dart' show SystemChrome;
import './database/database.dart' as database;
import './database/schemas/settings/settings.dart' as settings_schema;
import './helpers/eventer.dart';
import './helpers/stater.dart';

abstract class AppState {
  static final SubscriberManager<settings_schema.SettingsSchema> settings =
      SubscriberManager<settings_schema.SettingsSchema>();
  static final Eventer<bool> uiStyleNotifier = Eventer<bool>();

  static Future<void> initialize() async {
    final settings_schema.SettingsSchema settings = database.DataStore.settings;
    AppState.settings.initialize(settings);

    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setSystemUIChangeCallback((final bool isOnFullscreen) async {
        uiStyleNotifier.dispatch(isOnFullscreen);
      });
    }
  }
}
