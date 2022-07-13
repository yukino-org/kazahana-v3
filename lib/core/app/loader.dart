import '../database/exports.dart';
import '../paths.dart';
import '../tenka/exports.dart';
import '../translations/exports.dart';

abstract class AppLoader {
  static bool ready = false;

  static Future<void> initialize() async {
    await Paths.initialize();
    await SettingsDatabase.initialize();
    await TenkaManager.initialize();
    await Translations.initialize();
    ready = true;
  }
}
