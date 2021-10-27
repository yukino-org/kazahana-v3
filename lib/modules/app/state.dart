import 'dart:io';
import '../database/database.dart';
import '../database/schemas/settings/settings.dart';
import '../helpers/stater.dart';

abstract class AppState {
  static final SubscriberManager<SettingsSchema> settings =
      SubscriberManager<SettingsSchema>();

  static Future<void> initialize() async {
    final SettingsSchema settings = DataStore.settings;
    AppState.settings.initialize(settings);
  }

  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
