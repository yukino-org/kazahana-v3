import '../database/exports.dart';
import '../paths.dart';
import '../tenka/exports.dart';
import '../translator/exports.dart';

abstract class AppLoader {
  static bool ready = false;

  static Future<void> initialize() async {
    await Paths.initialize();
    await SettingsDatabase.initialize();
    await CacheDatabase.initialize();
    await TenkaManager.initialize();
    await Translator.initialize();
    ready = true;
  }
}
