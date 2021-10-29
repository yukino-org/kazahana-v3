import 'dart:io';
import '../database/database.dart';
import '../state/eventer.dart';

abstract class AppState {
  static late final ReactiveEventer<SettingsSchema> settings;

  static Future<void> initialize() async {
    settings = ReactiveEventer<SettingsSchema>(SettingsBox.get());
  }

  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
