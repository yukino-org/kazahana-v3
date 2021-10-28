import 'dart:io';
import '../database/database.dart';
import '../state/eventer.dart';

abstract class AppState {
  static final ReactiveEventer<SettingsSchema> settings =
      ReactiveEventer<SettingsSchema>();

  static Future<void> initialize() async {
    AppState.settings.value = SettingsBox.get();
  }

  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
